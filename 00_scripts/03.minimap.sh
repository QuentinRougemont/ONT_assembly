#!/bin/bash

input=$1 #genome basename 
ref=assembly.fasta

cd 03.genome
minimap2 -ax map-ont $input/"$input"_flye/$ref  $input/*.fastq.gz |\
	 samtools view -Sb - |samtools sort - > $input/"$input".aligned.sorted.bam
