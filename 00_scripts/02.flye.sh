#!/bin/bash
##SBATCH --job-name=flye                
##SBATCH --output=log_flye-%J.out                  
##SBATCH --cpus-per-task=8                   
##SBATCH --mem=90G                           
                                             
# Move to directory where job was submitted  
conda activate flye

genome=$1 #name of the genome to assemble

# Copy script as it was run                 
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="LOG_FLYE/"
mkdir $LOG_FOLDER 2>/dev/null
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

echo running canu on $genome 

cd 02.Filtered$genome

pwd

flye --nano-raw *fastq.gz --genome-size 30m -o "$genome"_flye -t8


