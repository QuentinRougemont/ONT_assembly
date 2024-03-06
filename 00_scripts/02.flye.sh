#!/bin/bash

#microscript to run flye 
if [ $# -ne 1  ]; then
    echo "USAGE: $0 <input_basename>"
    echo "Expecting a name corresponding to the genome of your study species"
    exit 1
else
    genome=$1
    echo "genome name : ${genome}"
    echo -e "\n"
    echo running flye on $genome 

fi

cd 02.FilteredRaw/$genome

flye --nano-raw *fastq.gz --genome-size 30m -o "$genome"_flye -t8

#other option that may be relevant: --asm 50 
# --meta (in case there's putative contaminants)
