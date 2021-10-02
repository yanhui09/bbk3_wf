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
    echo "Usage: $0 [-b -i -o -k -m -u -t -l -s -h]"
    echo "  -b, --biobakery_db    Required, path to the biobakery database directory."
    echo "  -i, --input_fqs    Required, path to the fastq files, cleaned by rename_fq.sh."
    echo "  -o, --output    Required, path to a output directory."
    echo "  -k, --knead_db    Required, path to the keaddata database directory."
    echo "  -m, --metaphlan_db    Required, path to the metaphlan database directory."
    echo "  -u, --humann_db    Required, path to the humann database directory."
    echo "  -t, --threads    Required, the number of the threads. Default: 4."
    echo "  -l, --local_jobs    Required, the number of local jobs. Default: 1."
    echo "  -s, --skip    Optional, skip setting environment variables."
    echo "  -h, --help      Optional, help message."   
    echo ""
    echo "Example:"
    echo "$0 -b /path/to/biobakery_db -k /path/to/knead_db -m /path/to/metaphlan_db -u /path/to/humann_db -i /path/to/fqs -o /path/to/output"
    echo "";}

#############################################################################
# Check input, ensure alphabet/numbers behind -/--, and at least one option
if [ $# -eq 0 ] || ! [[ $* =~ ^(-|--)[a-z] ]]; then 
    echo "Invalid use: please check the help message below." ; usage; exit 1; fi
# Params loading
args=$(getopt --long "biobakery_db:,input_fqs:,output:,knead_db:,metaphlan_db:,humann_db:,threads:,local_jobs:,skip,help" -o "b:i:o:k:m:u:t:l:sh" -n "Input error" -- "$@")
# Ensure corrected input of params
if [ $? -ne 0 ]; then usage; exit 1; fi

eval set -- "$args"

while true; do
        case "$1" in
                -b|--biobakery_db) BIOBAKERY_DB="$2"; shift 2;;
                -i|--input_fqs) INPUT_FQS="$2"; shift 2;;
                -o|--output) OUTPUT="$2"; shift 2;;
                -k|--knead_db) KNEAD_DB="$2"; shift 2;;
                -m|--metaphlan_db) METAPHLAN_DB="$2"; shift 2;;
                -u|--humann_db) HUMANN_DB="$2"; shift 2;;
                -t|--threads) THREADS="$2"; shift 2;;
                -l|--local_jobs) LOCAL_JOBS="$2"; shift 2;;
                -s|--skip) SKIP=true; shift 1;; # indicator changed 
                -h|--help) usage; exit 1; shift 1;;
                *) break;;    
        esac
done
#############################################################################
if [ "$SKIP" == true ]; then
    # warning notes
    tput setaf 4
    echo "Make sure Biobakery environment variables were set manually."
    tput sgr0
else
    # environment varibles for database
    export KNEADDATA_DB_HUMAN_GENOME="$KNEAD_DB"
    export STRAINPHLAN_DB_REFERENCE="$BIOBAKERY_DB/strainphlan_db_reference"
    export STRAINPHLAN_DB_MARKERS="$BIOBAKERY_DB/strainphlan_db_markers"
fi    

# THREADS
if [ -z "$THREADS" ]; then
    THREADS=4
fi

# LOCAL JOBS
if [ -z "$LOCAL_JOBS" ]; then
    LOCAL_JOBS=1
fi

# Check if output location exists
if [ ! -d "$OUTPUT" ]; then
    # reminding notes
    tput setaf 4
    echo "$OUTPUT is created."
    tput sgr0
fi
mkdir -p "$OUTPUT"

# parameters in workflows
#INPUT=examples/wmgx/paired/

# Trimmomatic option (The biobakery wf couldn't automatically find trimmomatic) 
TRIMMOMATIC=$(readlink -f `which trimmomatic`) # get the orginal file path
TRIMMOMATIC=${TRIMMOMATIC%/trimmomatic}
QC_OPTIONS='--run-fastqc-start --run-fastqc-end --trimmomatic '
QC_OPTIONS+=$TRIMMOMATIC
QC_OPTIONS+=' --trimmomatic-options "ILLUMINACLIP:/TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50"'

# HUMAnN options
HUMAnN_OPTIONS='--nucleotide-database '
HUMAnN_OPTIONS+=$HUMANN_DB
HUMAnN_OPTIONS+='/chocophlan --protein-database '
HUMAnN_OPTIONS+=$HUMANN_DB
HUMAnN_OPTIONS+='/uniref'

# MetaPhlAn options
MetaPhlAn_OPTIONS='--bowtie2db '
MetaPhlAn_OPTIONS+=$METAPHLAN_DB
MetaPhlAn_OPTIONS+=' --add_viruses'

# StrainPhlan options
StrainPhlAn_DB=$(find $METAPHLAN_DB -name '*.pkl')
StrainPhlAn_OPTIONS='-d '
StrainPhlAn_OPTIONS+=$StrainPhlAn_DB # couldn't define database, keep the default one

biobakery_workflows wmgx --input "$INPUT_FQS" --output "$OUTPUT" --qc-options "$QC_OPTIONS" \
--functional-profiling-options "$HUMAnN_OPTIONS" \
--taxonomic-profiling-options "$MetaPhlAn_OPTIONS" \
--strain-profiling-options "$StrainPhlAn_OPTIONS" \
--threads $THREADS --local-jobs $LOCAL_JOBS \
--remove-intermediate-output

exit
