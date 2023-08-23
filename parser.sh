#!/bin/bash

awk '$1 ~ /[0-9]/ {print $4;}' vmstat.log > temp.txt
awk '{print NR " " $0}' temp.txt > vmstat_free_memory.log
