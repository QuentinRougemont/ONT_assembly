#!/bin/bash
##SBATCH --job-name=mercury             
##SBATCH --output=merc-%J.out                  
##SBATCH --cpus-per-task=4                   
##SBATCH --mem=8G                           
                                             
# Move to directory where job was submitted  
cd $SLURM_SUBMIT_DIR                         

#date: 13/01/23
#AUTHOR: QR
#Script to run mercury
#to install see: https://github.com/marbl/merqury/wiki/

genome=$1 #test that a genome basename is provided or exit

#--- create architecture ---- #
mkdir -p 06.merqury/$genome 2>/dev/null
cd 06.merqury/$genome


#preliminary step: -- get K -- 
#genome_size=29999655 #size of the genome is ~30 mb
#~/software/merqury-1.3/best_k.sh $genome_size


#step1: -- build k-mer dbs ---
meryl k=17.34 count ../../02.Trimmed_illumina/$genome/*fq.gz output "$genome".meryl

#step2:
~/software/merqury-1.3/merqury.sh $genome.meryl ../../05.pilon/$genome/pilon.fasta  $genome > hifi.log

#step3 -- make some plot:
~/software/merqury-1.3/eval/spectra-cn.sh "$genome".meryl/ ../../05.pilon/$genome/pilon.fasta "$genome".out
