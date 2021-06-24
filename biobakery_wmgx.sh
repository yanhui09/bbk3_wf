#!/bin/bash
#---------------------------------------------------------------------------------
# This script to run biobakery3 workflow at KU FOOD.

# University of Copenhagen
# 2021/06/22
# Yan Hui
# huiyan@food.ku.dk
#---------------------------------------------------------------------------------

# Wrapped function, e.g. usage()
usage () {
    echo ""
    echo "Note: The biobakery3 workflow at KU FOOD."
    echo ""
    echo "Usage: $0 [-k -r -m -i -o -h]"
    echo "  -k, --knead_db    Required, path to the keaddata database."
    echo "  -r, --strainphlan_ref    Required, path to the strainphlan reference."
    echo "  -m, --strainphlan_marker    Required, path to the strainphlan markers."
    echo "  -t, --threads    Required, the number of the threads."
    echo "  -l, --local_jobs    Required, the number of local jobs."
    echo "  -i, --input_fqs    Required, path to the fastq files, cleaned by rename_fq.sh."
    echo "  -o, --output    Required, path to a output directory."
    echo "  -s, --skip    Optional, skip loading database (if set already)"
    echo "  -h, --help      Optional, help message."   
    echo ""
    echo "Example:"
    echo "$0 -k /path/to/knead_db -r /path/to/strainphlan_ref -m /path/to/strainphlan_marker -i /path/to/fqs -o /path/to/output"
    echo "$0 -i /path/to/fqs -o /path/to/output -s"
    echo "";}

#############################################################################
# Check input, ensure alphabet/numbers behind -/--, and at least one option
if [ $# -eq 0 ] || ! [[ $* =~ ^(-|--)[a-z] ]]; then 
    echo "Invalid use: please check the help message below." ; usage; exit 1; fi
# Params loading
args=$(getopt --long "knead_db:,strainphlan_ref:,strainphlan_marker:,threads:,local_jobs:,input_fqs:,output:,skip,help" -o "k:r:m:t:l:i:o:sh" -n "Input error" -- "$@")
# Ensure corrected input of params
if [ $? -ne 0 ]; then usage; exit 1; fi

eval set -- "$args"

while true; do
        case "$1" in
                -k|--knead_db) KNEAD_DB="$2"; shift 2;;
                -r|--strainphlan_ref) STRAINPHLAN_REF="$2"; shift 2;;
                -m|--strainphlan_marker) STRAINPHLAN_MARKER="$2"; shift 2;;
                -t|--threads) THREADS="$2"; shift 2;;
                -l|--local_jobs) LOCAL_JOBS="$2"; shift 2;;
                -i|--input_fqs) INPUT_FQS="$2"; shift 2;;
                -o|--output) OUTPUT="$2"; shift 2;;
                -s|--skip) SKIP=true; shift 1;; # indicator changed 
                -p|--preset) PRESET=true; shift 1;; # indicator changed 
                -h|--help) usage; exit 1; shift 1;;
                *) break;;    
        esac
done
#############################################################################
if [ "$SKIP" != true ]; then
    # environment varibles for database
    #export BIOBAKERY_WORKFLOWS_DATABASES=/mnt/md0/Database/biobakery
    export KNEADDATA_DB_HUMAN_GENOME="$KNEAD_DB"
    export STRAINPHLAN_DB_REFERENCE="$STRAINPHLAN_REF"
    export STRAINPHLAN_DB_MARKERS="$STRAINPHLAN_MARKER"
fi    

# parameters in workflows
#INPUT=examples/wmgx/paired/

QC_OPTIONS='--run-fastqc-start --run-fastqc-end --trimmomatic /home/yanhui/anaconda3/envs/biobakery/share/trimmomatic-0.39-2 --trimmomatic-options "ILLUMINACLIP:/TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50"'

HUMAnN_OPTIONS='--nucleotide-database /mnt/md0/Database/biobakery/humann/chocophlan --protein-database /mnt/md0/Database/biobakery/humann/uniref'

MetaPhlAn_OPTIONS='--bowtie2db /mnt/md0/Database/biobakery/metaphlan --add_viruses'

biobakery_workflows wmgx --input "$INPUT_FQS" --output "$OUTPUT" --qc-options "$QC_OPTIONS" --functional-profiling-options "$HUMAnN_OPTIONS" --taxonomic-profiling-options "$MetaPhlAn_OPTIONS" --threads $THREADS --local-jobs $LOCAL_JOBS --bypass-functional-profiling

exit
