#!/bin/bash
#SBATCH --job-name=mini                
#SBATCH --output=log_mini-%J.out                  
#SBATCH --cpus-per-task=8                   
#SBATCH --mem=20G                           
                                             
# Move to directory where job was submitted  
cd $SLURM_SUBMIT_DIR                         

source /local/env/envgcc-9.3.0.sh
source /local/env/envconda3.sh 
conda activate /home/genouest/cnrs_umr5175/qrougemont/mes_envs/samtools1.15/
. /local/env/envminimap2-2.15.sh
input=$1
ref=assembly.fasta

cd 03.genome
minimap2 -ax map-ont $input/"$input"_flye/$ref  $input/*.fastq.gz |\
	 samtools view -Sb - |samtools sort - > $input/"$input".aligned.sorted.bam
