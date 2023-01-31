#!/bin/bash
#SBATCH --job-name=BUSCO25
#SBATCH --cpus-per-task=8
#SBATCH --mem=30G

source /local/env/envconda.sh
conda activate /groups/bipaa/env/busco_4.0.6
. /local/env/envaugustus.sh


input=$1   #genome base name
fasta=$input/"$input".polished.fa

echo genome is $input

output=busco_$input  #folderoutput

dataset=basidiomycota_odb10
busco -c8 -o $output -i $fasta  -l $dataset -m geno
