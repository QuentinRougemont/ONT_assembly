#!/bin/bash

#running busco on genome fasta

input=$1    #fasta name
database=$2 #name of augustus database 
output=busco_${input%.fa**}

busco -c8 -o $output -i $input  -l l$database -m geno
