#!/bin/bash

#microscript to run minimap
if [ $# -ne 1  ]; then
    echo "USAGE: $0 <input_basename>"
    echo "Expecting a name corresponding to the genome of your study species"
    exit 1
else
    input=$1
    echo "genome name : ${input}"
    echo -e "\n"
    echo running minimap on $input 

fi

ref=assembly.fasta


mkdir 03.alignment 2>/dev/null

minimap2 -ax map-ont 02.FilteredRaw/$input/"$input"_flye/$ref  02.FilteredRaw/$input/*.fastq.gz |\
	 samtools view -Sb - |samtools sort - > 03.alignment/$input/"$input".aligned.sorted.bam

samtools depth 03.alignment/$input/"$input".aligned.sorted.bam |gzip > 03.alignment/"$input"/depth.txt.gz

#compute mean depth: 
zcat 03.alignment/"$input"/depth.txt.gz |awk -F'\t' ' { sum[$1] += $3; N[$1]++ } 
          END     { for (key in sum) {
                        avg = sum[key] / N[key];
                        printf "%s %f\n", key, avg;
                    } }'  > 03.alignment/"$input"/mean_dp.txt


#make a nice plot of depth along the genome : 
cd 03.alignment/$input
Rscript ../00_scripts/plot_depth.R 
