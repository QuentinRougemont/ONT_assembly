#!/bin/bash

base=$1
BASECALLS=02.FilteredRaw/$base/ont.fasta

NPROC=18 #$(nproc)

#prepare a combined fasta :
#input is the output of chopper:
zcat 02.FilteredRaw/$base/*trimmed.fastq.gz |sed -n '1~4s/^@/>/p;2~4p' > ${BASECALLS}

DRAFT=02.FilteredRaw/$base/${base}_flye_scaffold/assembly.fasta

OUTDIR=medaka_consensus
medaka_consensus -i ${BASECALLS} -d ${DRAFT} -o ${OUTDIR} -t ${NPROC} -m r941_min_high_g303

#to do: try directly on the seaprated sets of fastq.gz
