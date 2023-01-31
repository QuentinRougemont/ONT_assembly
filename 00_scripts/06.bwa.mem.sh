#!/bin/bash
#SBATCH --job-name=bwa                
#SBATCH --output=log_bwa-%J.out                  
#SBATCH --cpus-per-task=8                   
#SBATCH --mem=20G                           
                                             
# Move to directory where job was submitted  
#cd $SLURM_SUBMIT_DIR                         
#source /local/env/envbwa-0.7.17.sh
#source /local/env/envgcc-9.3.0.sh
#conda activate /home/genouest/cnrs_umr5175/qrougemont/mes_envs/samtools1.15/

BASE=$1
# Global variables
GENOMEFOLDER="03.genome"/"$BASE"
GENOME="$BASE".polished.fa #$1 #"genome.fasta"
DATAFOLDER="02.Trimmed_illumina/$BASE"
NCPU="8"

# Test if user specified a number of CPUs
if [[ -z "$NCPU" ]]
then
    NCPU=8
fi

# Index genome if not alread done
#bwa index -p "$GENOMEFOLDER"/"${GENOME%.fa}" "$GENOMEFOLDER"/"$GENOME"
bwa index  "$GENOMEFOLDER"/"$GENOME"

for file in $(ls -1 "$DATAFOLDER"/*trimmed_1.fq.gz)
do
    # Name of uncompressed file
    file2=$(echo "$file" | perl -pe 's/_1\.fq\.gz/_2.fq.gz/')
    echo "Aligning file $file $file2" 

    name=$(basename "$file")
    name2=$(basename "$file2")
    ID="@RG\tID:ind\tSM:ind\tPL:Illumina"

    # Align reads 1 step
    bwa mem -t "$NCPU" -R "$ID" "$GENOMEFOLDER"/"$GENOME" "$DATAFOLDER"/"$name" "$DATAFOLDER"/"$name2" 2> /dev/null | \
	    samtools view -Sb -q 10 - > "$DATAFOLDER"/"${name%.fq.gz}".bam

    # Sort and index
    samtools sort --threads "$NCPU" -o "$DATAFOLDER"/"${name%.fq.gz}".sorted.bam \
        "$DATAFOLDER"/"${name%.fq.gz}".bam

    samtools index "$DATAFOLDER"/"${name%.fq.gz}".sorted.bam
    rm "$DATAFOLDER"/"${name%.fq.gz}".bam
done
