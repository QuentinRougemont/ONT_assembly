#!/bin/bash

#read should be located in separate folder (one per species/genome) in 01.RawData

cd 01.RawData 
ls -d */ > list_genome
cd ../
for genome in $(cat list_genome ) ; do
	mkdir -p 02.FilteredRaw/$genome
	for fastq in $(ls 01.RawData/"$genome"/*fastq.gz ) ;
	do
	    name=$(basename $fastq);
	    echo processing $name   ;
	    zcat $fastq | \
		NanoFilt -q7 -l 900 --headcrop 50 |   \
	          gzip > 02.FilteredRaw/"$genome"/"${name%.fastq.gz}".trimmed.fastq.gz ;
      done;
done 

#note: see https://github.com/wdecoster/chopper for a fastest alternative
