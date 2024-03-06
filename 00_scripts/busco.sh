#!/bin/bash

#running busco on genome fasta

input=$1      #fasta name
database=$2   #dataset name for busco from the focal species (can be obtained through busco --list-dataset)
output=busco_${input%.fa**}

busco -c8 -o $output -i $input  -l l$database -m geno
