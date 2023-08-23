#!/bin/bash

# variables
TARGET_JOBS=("wes_hg38" "snp_hg19" "wes_hg19" "snp_hg38" "wgs_hg38" "wgs_hg19") # TODO: change this to the job you want to run
MG_PATH="/home/youn/workspace/mg/src"
DEBUG_PATH="/home/youn/workspace/debug"
MEMORY_OUTPUT_PATH="${DEBUG_PATH}/${TARGET_JOB}/memory_output"
CONSOLE_OUTPUT_PATH="${DEBUG_PATH}/${TARGET_JOB}/console_output"

# os environment variables
export GRAPHYTE_BATCH_SIZE="100"
export UKB_OMOP_CDM_DB_HOST="mimic.db.tech.cipherome.com",
export UKB_OMOP_CDM_DB_PORT="7369",
export UKB_OMOP_CDM_DB_NAME="knu_copd",
export UKB_OMOP_CDM_DB_SCHEMA="cdm",
export UKB_OMOP_CDM_DB_USERNAME="postgres",
export OMOP_CDM_DB_ENV_PREFIX="UKB"
export UKB_OMOP_CDM_DB_PASSWORD="eldest-detail-irritably",

cohort_size_list=(2000 5000 8000 10000 20000 30000)

# create output directory
mkdir -p $MEMORY_OUTPUT_PATH
mkdir -p $CONSOLE_OUTPUT_PATH

cd $MG_PATH

for TARGET_JOB in "${TARGET_JOBS[@]}"; do

    for num_patients in "${cohort_size_list[@]}"; do
        echo "Generating dataset using cohort size ${num_patients}"

        head -${num_patients} ../saved_output/genomic/memory/cohort.csv > ../saved_output/genomic/memory/temp.csv

        MEMORY_LOG_PATH="${MEMORY_OUTPUT_PATH}/memory_${num_patients}.log"
        free -s 1 | grep "Mem" > $MEMORY_LOG_PATH &

        /usr/bin/env /home/youn/venv/mg/bin/python3 -m mg.main ../configs/sample_configs/dataset_genomic_pipeline_${TARGET_JOB}.json | tee ${CONSOLE_OUTPUT_PATH}/genomic_memory_${num_patients}.log

        pkill free

        awk '{print $3;}' $MEMORY_LOG_PATH > ${MEMORY_OUTPUT_PATH}/memory_free_memory_${num_patients}.log

        echo $num_patients $TARGET_JOB
    done

done
