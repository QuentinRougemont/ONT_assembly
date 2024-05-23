#!/bin/bash

#microscript to run bwa-mem

if [ $# -ne 1  ]; then
    echo "USAGE: $0 <base> input_basename"
    echo "Expecting a name corresponding to the genome of your study species"
    exit 1
else
    base=$1
    echo "genome name : ${base}"
    echo -e "\n"
    echo running flye on $base 

fi

# Global variables
basefolder="04.polished"/"$base"
genome="$base".polished.fa      #genome from marginPolish 
datafolder="02.Trimmed_illumina/$base"
NCPU="8"

# Test if user specified a number of CPUs
if [[ -z "$NCPU" ]]
then
    NCPU=8
fi

# Index base if not alread done
#bwa index -p "$basefolder"/"${genome%.fa}" "$basefolder"/"$genome"
bwa-mem2 index  "$basefolder"/"$genome"

for file in $(ls -1 "$datafolder"/*trimmed_1.fq.gz)
do
    # Name of uncompressed file
    file2=$(echo "$file" | perl -pe 's/_1\.fq\.gz/_2.fq.gz/')
    echo "Aligning file $file $file2" 

    name=$(basename "$file")
    name2=$(basename "$file2")
    ID="@RG\tID:ind\tSM:ind\tPL:Illumina"

    # Align reads 1 step
    bwa-mem2 mem -t "$NCPU" -R "$ID" "$basefolder"/"$genome" "$datafolder"/"$name" "$datafolder"/"$name2" 2> /dev/null | \
    	samtools view -Sb -q 10 - |\ 
    # Sort and index
    	samtools sort --threads "$NCPU" -o "$datafolder"/"${name%.fq.gz}".sorted.bam -

    samtools index "$datafolder"/"${name%.fq.gz}".sorted.bam
done
