!/bin/bash

#script to compute the length of a fasta
#Author: QR
#Date: 2023 + update 01/2024
genome=$1
fastq=$2
base=$(basename $fastq)

OUTFOLDER=00.length_distrib
mkdir -p $OUTFOLDER/$genome/ 2>/dev/null


#compute length with awk
# ----- check compression of fasta  ------ ##
#check compression
if file --mime-type "$fastq" | grep -q gzip$; then
   echo "$fastq is gzipped"
   zcat "$fastq" |\
      awk 'BEGIN {FS = "\t" ; OFS = "\n"} {header = $0 ; getline seq ; getline qheader ; getline qseq ;  {print header "\t" length(seq)}}' \
                 > "$OUTFOLDER"/"$genome"/"${base%.fastq.gz}".length.txt
else
   echo "$fastq is not gzipped"
   cat "$fastq" |\
      awk 'BEGIN {FS = "\t" ; OFS = "\n"} {header = $0 ; getline seq ; getline qheader ; getline qseq ;  {print header "\t" length(seq)}}' \
                 > "$OUTFOLDER"/"$genome"/"${base%.fastq}".length.txt
fi

#then run Rscript to plot de length distributions
