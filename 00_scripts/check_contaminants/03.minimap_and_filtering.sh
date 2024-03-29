#!/bin/bash
#Author: QR
#date: 2022
#update: 2024
#purpose: 
# 1 - align long read against a reference set of sequence to search for putative contaminant.
# 2 - remove the contaminant if there is not a better overlapping match with known sequence closely related to the focal species of interest
# 3 - mask the contaminant in the fasta (insert NNNN) (a new fasta is created) 
# 4 - prepare the data for launching blast 

#-------- input data -----------------------#
species=$1 #e.g. fungi #the name of the species to be studied and for which genome data have been download in previous scripts 
genome=$2
contam=/home/quentin/genome_assembly/hifi/fungi_human_contam.fa #"$species"_human_contam.fa
type=$3  #either PB or ONT

cd 02.FilteredRaw/"$genome"

for fastq in $(ls *fastq* ) ;   
    do
    name=$(basename $fastq);
    #check compression
    if file --mime-type "$fastq" | grep -q gzip$; then
   	echo processing $name   ; 
        zcat $fastq |gzip >> genome.fastq.gz
    else
        cat $fastq  |gzip >> genome.fastq.gz
    fi
done

#--------- step 1 -- run minimap ----------#
if [[ $type = "PB" ]]
then
	minimap2 -c -x map-pb  -t 24 -Q $contam genome.fastq.gz |gzip  > minimap2.paf.gz

else 
	echo "assuming reads are ONT" 
	minimap2 -c -x map-ont -t 24 -Q $contam genome.fastq.gz |gzip > minimap2.paf.gz
fi

#--------- step 2 -- reshape data----------#

#print only wanted columns:
zcat minimap2.paf.gz |awk '$12 > 29 && $6 ~/contam/ {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$12}' > contam.tmp
zcat minimap2.paf.gz |awk -v spe=$species '$12 > 29 && $6 ~ spe {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$12}' > spe.tmp 

#run Rscript to extract contaminant: 
Rscript 01.scripts/Rscripts/paf_extract_contam.R

#check input compression :
echo -e "\n\n"

zcat genome.fastq.gz |sed -n '1~4s/^@/>@/p;2~4p'  |sed 's/ runid.*//' > genome.fasta

#--------- step 3 -- insert NNNNN----------#
fasta=rawreads.fasta
masked_fasta=rawreads.masked.fasta

#use bedtools maskfasta for our purpose: 
#the file putative_contaminant.withnospecies_overlap.bed is generate from the above Rscript 
bedtools maskfasta -fi $fasta -bed putative_contaminant.withnospecies_overlap.bed -fo "$masked_fasta"

#----- step 4 -- run blast ---------------#
#grep also the sequence from within the fasta to blast them:
grep -A1 -Ff <(cut -f1 putative_contaminant.withnospecies_overlap.bed ) $fasta  > putative_contaminant.withnospecies_overlap.toblast.fa

./01.scripts/04.makeblastdb.sh $contam $contam
./01.scripts/05.blast.sh  putative_contaminant.withnospecies_overlap.toblast.fa $contam 

#keep high quality blasts:
grep -v "$species" blasts/putative_contaminant.withnospecies_overlap.toblast.fa."$species"_human_contam.fa |\
	awk '$3>80 && $4>300 && $10<1e-20 {print $1"\t"$5"\t"$6}' |\
	sort -k1  |uniq > putative_contaminant_from_blast.bed

#use bedtools to re-insert additional NNNN :
masked_fasta2=rawreads.maskedfull.fasta

bedtools maskfasta -fi $masked_fasta -bed putative_contaminant_from_blast.bed -fo "$masked_fasta2"
