#!/bin/bash
                                             

genome=$1
# Global variables
genomefolder="03.genome"/"$genome"
GENOME="$genome".polished.fa #$1 #"genome.fasta"
datafolder="02.Trimmed_illumina/$genome"
NCPU="8"

# Test if user specified a number of CPUs
if [[ -z "$NCPU" ]]
then
    NCPU=8
fi

# Index genome if not alread done
#bwa index -p "$genomefolder"/"${GENOME%.fa}" "$genomefolder"/"$GENOME"
bwa index  "$genomefolder"/"$GENOME"

for file in $(ls -1 "$datafolder"/*trimmed_1.fq.gz)
do
    # Name of uncompressed file
    file2=$(echo "$file" | perl -pe 's/_1\.fq\.gz/_2.fq.gz/')
    echo "Aligning file $file $file2" 

    name=$(basename "$file")
    name2=$(basename "$file2")
    ID="@RG\tID:ind\tSM:ind\tPL:Illumina"

    # Align reads 1 step
    bwa mem -t "$NCPU" -R "$ID" "$genomefolder"/"$GENOME" "$datafolder"/"$name" "$datafolder"/"$name2" 2> /dev/null | \
    	samtools view -Sb -q 10 - |\ 
    # Sort and index
    	samtools sort --threads "$NCPU" -o "$datafolder"/"${name%.fq.gz}".sorted.bam -

    samtools index "$datafolder"/"${name%.fq.gz}".sorted.bam
done
