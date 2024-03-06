#!/bin/bash

#microscript to run fastp

# Global variables
genome=$1
length=120 #to be passed as a variable
qual=30    #to be passed as a variable


input="01.RawData_illumina/$genome" #store your illumina data in this folder
output="02.Trimmed_illumina/$genome"

mkdir -p $output 2>/dev/null
mkdir -p $output/01_report 2>/dev/null


NUMCPUS=8

# Trim reads with fastp 
# may have to change fq into fastq 
ls "$input"/*_1.fq.gz | perl -pe 's/[12]\.fq\.gz//g' |
parallel -j "$NUMCPUS" \
    fastp -i {}1.fq.gz -I {}2.fq.gz \
        -o $output/{/}trimmed_1.fq.gz \
        -O $output/{/}trimmed_2.fq.gz  \
        --length_required="$length" \
        --qualified_quality_phred="$qual" \
        --correction \
        --trim_tail1=1 \
        --trim_tail2=1 \
        --json $output/01_report/{/}.json \
        --html $output/01_report/{/}.html  \
        --report_title={/}.html


