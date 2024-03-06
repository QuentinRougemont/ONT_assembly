#!/bin/bash

#microscript to run pilon

base=$1

mkdir -p 05.pilon/$base

genome=04.genome/"$base"/"$base".polished.fa
bam=02.Trimmed_illumina/$base/"$base"_trimmed_1.sorted.bam

java -Xms100g -Xmx210g -jar 01.scripts/pilon-1.24.jar \
	--genome $genome \
	--frags "$bam" \
	--outdir 05.pilon/$base/ \
	--changes --tracks --diploid --fix all --mindepth 8

. /local/env/envquast-5.0.2.sh

cd 05.pilon/"$base"/
quast.py pilon.fasta

