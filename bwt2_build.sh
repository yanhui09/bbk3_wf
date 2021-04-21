#!/bin/bash
# Revised on https://github.com/maubarsom/maars-shotgun/blob/master/1_read_preprocessing/3_human_rm/build_humanrm_idx.sh
# Yan Hui
# huiyan@food.ku.dk

source activate kneaddata

# ADD the host ref

# Download sus scrofa (pig) whole genome
wget -N ftp://ftp.ensembl.org/pub/release-95/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa.gz
gzip -d *fa.gz
mv *fa host.fa

# Download GRCh38 chromosomes
#wget -N ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
#gzip -d *fna.gz
#mv *fna GRch38.fa

# Download phiX174 reference (illumina spikein)
wget -N 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=9626372&rettype=fasta&retmode=text' -O phiX174.fa

# gunzip *.fa.gz
mkdir -p fasta-host_phix
mv *.fa fasta-host_phix/

# Build bowtie2 index
mkdir -p bowtie2
bowtie2-build $(echo fasta-host_phix/*.fa | sed "s/ /,/g") bowtie2/host_phix

# Build bwa index
#mkdir -p bwa
#bwa index -p bwa/grch38_phix fasta/*.fa

source deactivate
exit
