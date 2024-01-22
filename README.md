# ONT_assembly
pipeline to assemble genome from long read, correct with short read (and evaluate quality)

########################################################################
# protocol for genome assembly from ONT READ
########################################################################

## Dependencies: 

all can be installed without root - sometimes with conda

[jellyfish](http://www.genome.umd.edu/jellyfish.html#Release)

[genomescope](https://github.com/schatzlab/genomescope)

[nanofilter](https://github.com/wdecoster/nanofilt)

[flye](https://github.com/fenderglass/Flye)

[marginpolish](https://github.com/UCSC-nanopore-cgl/MarginPolish)


## for short read corrections:

[parallel](https://www.gnu.org/software/parallel/)

[fastp](https://github.com/OpenGene/fastp)

[bwa](https://sourceforge.net/projects/bio-bwa/files/)

[samtools](http://www.htslib.org/)

[fastp](https://github.com/OpenGene/fastp)

[pilon](https://github.com/broadinstitute/pilon)

## for genome evaluation:

[busco](https://gitlab.com/ezlab/busco/-/releases#5.2.1) also available from [conda](https://anaconda.org/bioconda/busco)

[quast](https://sourceforge.net/projects/quast/)

[mercury](https://github.com/marbl/merqury)


tested on Linux only

requires java:

`sudo apt install default-jre`  



## Different steps  


Data are stored in `01.RawData`
each species fastq are stored in different folder
fastq should be compressed  

#  1. jellyfish and genome scope 


purpose: extract various info (het%, genome length, repeat from raw reads)

```sh

cd 01.RawData
ls -d */ > genome_list

for genome in $(cat genome_list ) ; do
	
	echo "working on genome $i" 
	cd "$genome"
	ls *fastq.gz |xargs -n 1 echo gunzip -c > generators

	jellyfish count -g generators -C -m 21 -s 1000000000 -t 2 -o reads.jf
	jellyfish histo -t 40 reads.jf > reads.histo

	#produce the plot:
	genomescope.R reads.histo 21 100 ./
	cd ../
	
	echo "genome $genome done"

done
```

#  2. read trimming (length and qual)

purpose: trimm read

```sh
cp 01.RawData/genome_list .
for file in $(cat genome_list ) ; do 
	for fastq in 01.RawData/"$file"/*gz ; do
		./awk_fastq_lenth.sh "$file" "$fastq" ; 
	done 
done

for genome in $(cat genome_list ) ; do 
	mkdir -p 02.FilteredRaw/$genome
	for fastq in $(ls 01.RawData/"$genome"/*fastq.gz ) ;   
	do
	    name=$(basename $fastq);
	    echo processing $name   ; 
	    zcat $fastq | \
			chopper -q 10 -l 900 |  \
			          gzip > 02.FilteredRaw/"$genome"/"${name%.fastq.gz}".trimmed.fastq.gz ;
      done; 
done 
``` 

# 3. run flye

purpose: assemble the genome into a reference  

see  `00_scripts/02.flye.sh` adjust parameters following your needs  



# 4. align ONT read with Minimap to their references

```
for i in $(cat genome_list ) ; do ./00_scripts/03.minimap.sh $i ; done
```

(or launch these scripts with sbatch on SLURM or similar)


# 5. run marginPolish

purpose: genome polishing from the ONT read  
 
/!\ beware to modify the json params files according to your needs


dependencies: I run it through Docker singularity

```
cp ~/.software/marginpolish/allParams.np.microbial.r94-g305.json .
```
edit line 34 "chunkSize" and set it to the desired size (I used 5000 for fungus).

`for i in $(cat genome_list ) ; do ./00_scripts/03.minimap.sh $i ; done `


# 6. assess quality with busco

```
for genome in $(cat genome_list ) ; do 
	cd 02.FilteredRaw/$genome
	./00_scripts/busco.sh $genome.polished.fa database ; 
done 
```

# 7. run pilon

purpose: perform error correction based on short and more accurate reads

* trimm short reads 

see `00_scripts/05.fastp.sh`

* align them with bwa-mem

see `00_scripts/06.bwa.mem.sh`

* run pilon

see `00_scripts/07.pilon.sh`


# 8. run busco again 

and look at the improvment...


# 9. ragTag for superscaffolding if relevant

purpose: superscaffolding

install [ragTag](https://github.com/malonge/RagTag) and run it if you have a good reference assembly for that


# 10. run merqury

purpose: evaluate quality using various metrics

see scripts: 00_scripts/mercury.sh

details are here: https://github.com/marbl/merqury/wiki

some dependancies needed:
* [meryl](https://github.com/marbl/meryl)
* [R](https://www.r-project.org/) + install.packages(c("argparse", "ggplot2", "scales")) 
* java
* [bedtools](https://bedtools.readthedocs.io/en/latest/content/installation.html)

# 11. Run [quast](https://quast.sourceforge.net/docs/manual.html#sec1)

install through pip or conda (pip install quast) 

quast.py your.genome.fa


# 12. annotate the genomes

see genome_annotation [pipeline](https://github.com/QuentinRougemont/genome_annotation)


# To Do: 
add single script for step 1 to 8
