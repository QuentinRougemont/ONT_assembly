#!/bin/bash

input=$1 #genome basename 
ref=assembly.fasta

cd 03.genome
minimap2 -ax map-ont $input/"$input"_flye/$ref  $input/*.fastq.gz |\
	 samtools view -Sb - |samtools sort - > $input/"$input".aligned.sorted.bam

samtools depth $input/"$intpu".aligned.sorted.bam |gzip > "$input"/depth.txt.gz

#compute mean depth: 
zcat "$input"/depth.txt.gz |awk -F'\t' ' { sum[$1] += $3; N[$1]++ } 
          END     { for (key in sum) {
                        avg = sum[key] / N[key];
                        printf "%s %f\n", key, avg;
                    } }'  > "$input"/mean_dp.txt

cd $input
Rscript ../00_scripts/plot_depth.R 
