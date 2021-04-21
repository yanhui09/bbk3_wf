#!/bin/bash
# environment varibles for database
#export BIOBAKERY_WORKFLOWS_DATABASES=/mnt/md0/Database/biobakery
export KNEADDATA_DB_HUMAN_GENOME=/mnt/md0/Database/biobakery/kneaddata_db_human_genome
#KNEADDATA_DB_RIBOSOMAL_RNA
#KNEADDATA_DB_HUMAN_TRANSCRIPTOME
export STRAINPHLAN_DB_REFERENCE=/mnt/md0/Database/biobakery/strainphlan_db_reference
export STRAINPHLAN_DB_MARKERS=/mnt/md0/Database/biobakery/strainphlan_db_markers

# parameters in workflows
#INPUT=examples/wmgx/paired/
INPUT=examples/tutorial/input
OUTPUT=workflow_output
THREADS=6
LOCAL_JOBS=1

QC_OPTIONS='--run-fastqc-start --run-fastqc-end --trimmomatic /home/yanhui/anaconda3/envs/biobakery3/share/trimmomatic-0.39-2 --trimmomatic-options "ILLUMINACLIP:/TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50"'

HUMAnN_OPTIONS='--nucleotide-database /mnt/md0/Database/biobakery/humann/chocophlan --protein-database /mnt/md0/Database/biobakery/humann/uniref'

MetaPhlAn_OPTIONS='--bowtie2db /mnt/md0/Database/biobakery/metaphlan --add_viruses'

biobakery_workflows wmgx --input $INPUT --output $OUTPUT --qc-options "$QC_OPTIONS" --functional-profiling-options "$HUMAnN_OPTIONS" --taxonomic-profiling-options "$MetaPhlAn_OPTIONS" --threads $THREADS --local-jobs $LOCAL_JOBS
