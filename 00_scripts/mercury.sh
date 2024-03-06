#!/bin/bash
#date: 13/01/23
#AUTHOR: QR
#Script to run mercury
#to install see: https://github.com/marbl/merqury/wiki/

genome=$1       #test that a genome basename is provided or exit
genome_size=$2 #the size of the genome in base pair

#--- create architecture ---- #
mkdir -p 06.merqury/$genome 2>/dev/null
cd 06.merqury/$genome


#preliminary step: -- get K -- 
#genome_size=30000000 #size of the genome is ~30 mb
bestK=$(~/software/merqury/best_k.sh $genome_size |tail -n1 )


#step1: -- build k-mer dbs ---
meryl k=$bestK count ../../02.Trimmed_illumina/$genome/*fq.gz output "$genome".meryl

#step2:
~/software/merqury/merqury.sh $genome.meryl ../../05.pilon/$genome/pilon.fasta  $genome > hifi.log

#step3 -- make some plot:
~/software/merqury/eval/spectra-cn.sh "$genome".meryl/ ../../05.pilon/$genome/pilon.fasta "$genome".out
