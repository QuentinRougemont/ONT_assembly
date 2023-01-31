#!/bin/bash



# Global variables
GENOME=$1

LENGTH=120
QUAL=30
INPUT="01.RawData_illumina/$GENOME"
OUTPUT="02.Trimmed_illumina/$GENOME"

mkdir -p $OUTPUT 2>/dev/null
mkdir -p $OUTPUT/01_report 2>/dev/null


NUMCPUS=8

# Trim reads with fastp 
# may have to change fq into fastq 
ls "$INPUT"/*_1.fq.gz | perl -pe 's/[12]\.fq\.gz//g' |
parallel -j "$NUMCPUS" \
    fastp -i {}1.fq.gz -I {}2.fq.gz \
        -o $OUTPUT/{/}trimmed_1.fq.gz \
        -O $OUTPUT/{/}trimmed_2.fq.gz  \
        --length_required="$LENGTH" \
        --qualified_quality_phred="$QUAL" \
        --correction \
        --trim_tail1=1 \
        --trim_tail2=1 \
        --json $OUTPUT/01_report/{/}.json \
        --html $OUTPUT/01_report/{/}.html  \
        --report_title={/}.html


