#!/bin/bash

#microscript to run fastp

# Global variables
if [ $# -ne 3  ]; then
    echo "USAGE: $0 <input_basename> <length> <qual>"
    echo -e "Expecting the three following arguments: \n 
    	\t 1: <input_basename> : a name corresponding to the genome of your study species\n
	\t 2: <length> :  minimal length for read trimming \n
        \t 3: <qual> : minimal read quality\n"
    exit 1
else
    genome=$1
    length=$2 #by default we could set it to 120
    qual=$3   #by default we could set it to 30
    echo "genome name : ${genome}"
    echo -e "\n"
    echo running fastp on $genome 
    echo minimal length is $length
    echo minimal quality is $qual
    echo -e "\n"
fi


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


