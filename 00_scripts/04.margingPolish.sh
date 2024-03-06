#!/bin/bash

#microscript for marginpolish

genome=$1 #name of the genome

bam=03.alignment/"$genome".aligned.sorted.bam
fasta=02.FilteredRaw/"$genome"_flye/assembly.fasta
model=allParams.np.microbial.r94-g305.json


mkdir -p 04.polished/$genome 2>/dev/null

cd 04.polished/$genome
cp /path/to/$model .

samtools index $bam

singularity exec -B /path/to/03.genome/$genome:/path/to/03.genome/$genome  \
	docker:margin_polish:latest marginPolish \
	$bam \
	$fasta \
	$model \
	-t 8 -o "${genome}".polished 
	
