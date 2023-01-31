#!/bin/bash
#SBATCH --job-name=pilon
#SBATCH --output=log_pilo-%J.out
#SBATCH --cpus-per-task=8
#SBATCH --mem=89G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR
source /local/env/envjava-1.8.0.sh

BASE=$1

mkdir -p 05.pilon/$BASE

genome=03.genome/"$BASE"/"$BASE".polished.fa
#bam=02.Trimmed/"$BASE"/"$BASE"_trimmed_1.sorted.bam
bam=02.Trimmed_illumina/$BASE/"$BASE"_Rtrimmed_1.sorted.bam

time java -Xms100g -Xmx210g -jar 01.scripts/pilon-1.24.jar --genome $genome \
--frags "$bam" \
--outdir 05.pilon/$BASE/ --changes --tracks --diploid --fix all --mindepth 5
#--outdir 05.pilon/ --changes --tracks --diploid --fix indels,gaps,local --mindepth 5

. /local/env/envquast-5.0.2.sh

cd 05.pilon/"$BASE"/
quast.py pilon.fasta

