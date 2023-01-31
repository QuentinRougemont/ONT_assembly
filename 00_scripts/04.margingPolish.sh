#!/bin/bash
##SBATCH --job-name=marginPolish        
##SBATCH --output=log_marginPolish-%J.out                  
##SBATCH --cpus-per-task=8                   
##SBATCH --mem=10G                           
                                             
# Move to directory where job was submitted  
#cd $SLURM_SUBMIT_DIR                         

input=$1 #M_Sap_1270_A2
bam="$input".aligned.sorted.bam
fasta="$input"_flye/assembly.fasta
model=allParams.np.microbial.r94-g305.json

input=$1
ref=assembly.fasta

cd 03.genome/$input
cp 03.genome/$model .

samtools index $bam

singularity exec -B /path/to/03.genome/$input:/path/to/03.genome/$input  \
	docker:margin_polish:latest marginPolish \
	$bam \
	$fasta \
	$model \
	-t 8 -o "${input}".polished 
	
