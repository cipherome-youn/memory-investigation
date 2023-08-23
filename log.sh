#!/bin/bash

# variables
TARGET_JOBS=("wes_hg38" "snp_hg19" "wes_hg19" "snp_hg38" "wgs_hg38" "wgs_hg19") # TODO: change this to the job you want to run
MG_PATH="/home/youn/workspace/mg/src"
DEBUG_PATH="/home/youn/workspace/debug"
MEMORY_OUTPUT_PATH="${DEBUG_PATH}/output/${TARGET_JOB}/memory_output"
CONSOLE_OUTPUT_PATH="${DEBUG_PATH}/output/${TARGET_JOB}/console_output"

# os environment variables
. .env

cohort_size_list=(2000 5000 8000 10000 20000 30000)

# create output directory
mkdir -p $MEMORY_OUTPUT_PATH
mkdir -p $CONSOLE_OUTPUT_PATH

cd $MG_PATH

for TARGET_JOB in "${TARGET_JOBS[@]}"; do\
    for num_patients in "${cohort_size_list[@]}"; do
        echo "Generating dataset using cohort size ${num_patients}"

        # truncate the cohort.csv file
        head -${num_patients} ../saved_output/genomic/memory/cohort.csv > ../saved_output/genomic/memory/temp.csv

        # log file paths
        MEMORY_LOG_PATH="${MEMORY_OUTPUT_PATH}/memory_${num_patients}.log"
        USED_MEMORY_LOG_PATH="${MEMORY_OUTPUT_PATH}/used_memory_${num_patients}.log"
        PROCESSED_USED_MEMORY_LOG_PATH="${MEMORY_OUTPUT_PATH}/processed_used_memory_${num_patients}.log"

        # start to monitor memory usage
        free -s 1 | grep "Mem" > $MEMORY_LOG_PATH &

        # run the pipeline
        /usr/bin/env /home/youn/venv/mg/bin/python3 -m mg.main ../configs/sample_configs/dataset_genomic_pipeline_${TARGET_JOB}.json | tee ${CONSOLE_OUTPUT_PATH}/genomic_memory_${num_patients}.log

        # stop monitoring memory usage
        pkill free

        # extract the used memory column
        awk '{print $3;}' $MEMORY_LOG_PATH > $USED_MEMORY_LOG_PATH
        
        # read the first value from the file
        first_value=$(head -n 1 $USED_MEMORY_LOG_PATH)

        # subtract the first value from each number in the file
        while read -r number; do
            result=$((number - first_value))
            echo "$result"
        done < $USED_MEMORY_LOG_PATH > $PROCESSED_USED_MEMORY_LOG_PATH
    done
done
