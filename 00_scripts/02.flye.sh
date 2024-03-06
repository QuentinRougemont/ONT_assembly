#!/bin/bash

#microscript to run flye 

genome=$1 #name of the genome to assemble

# Copy script as it was run                 
echo running flye on $genome 

cd 02.FilteredRaw/$genome

flye --nano-raw *fastq.gz --genome-size 30m -o "$genome"_flye -t8

#other option that may be relevant: --asm 50 
# --meta (in case there's putative contaminants)
