#!/bin/bash
# A script to build host/phiX bowtie2 database for kneaddata.
# Revised on https://github.com/maubarsom/maars-shotgun/blob/master/1_read_preprocessing/3_human_rm/build_humanrm_idx.sh
# University of Copenhagen
# 2021/06/22
# Yan Hui
# huiyan@food.ku.dk
#---------------------------------------------------------------------------------

# Wrapped function, e.g. usage()
usage () {
    echo ""
    echo "Note: Build bowtie2 databsed for the kneaddata."
    echo ""
    echo "Usage: $0 [-i -t -l -s -o -h]"
    echo "  -i, --host    Required, ftp link of host genome on ensembl, etc."
    echo "  E.g. ftp://ftp.ensembl.org/pub/release-103/fasta/gallus_gallus/dna/Gallus_gallus.GRCg6a.dna.toplevel.fa.gz"
    echo "  -t, --threads    Required, the number of the threads. Default: 6."
    echo "  -l, --location    Required, a custom location to hold the built bowtie2 database."
    echo "  -s, --skip_phix    Optional, not including phix genome."
    echo "  -o, --only_phix    Optional, only phix genome."
    echo "  -h, --help      Optional, help message."   
    echo ""
    echo "Example:"
    echo "$0 -i /link/to/host_fa -l /path/to/output"
    echo "$0 -l /path/to/output -o"
    echo "";}

#############################################################################
# Check input, ensure alphabet/numbers behind -/--, and at least one option
if [ $# -eq 0 ] || ! [[ $* =~ ^(-|--)[a-z] ]]; then 
    echo "Invalid use: please check the help message below." ; usage; exit 1; fi
# Params loading
args=$(getopt --long "host:,threads:,location:,skip_phix,only_phix,help" -o "i:t:l:soh" -n "Input error" -- "$@")
# Ensure corrected input of params
if [ $? -ne 0 ]; then usage; exit 1; fi

eval set -- "$args"

while true; do
        case "$1" in
                -i|--host) HOST="$2"; shift 2;;
                -t|--threads) THREADS="$2"; shift 2;;
                -l|--location) LOCATION="$2"; shift 2;;
                -s|--skip_phix) SKIP=true; shift 1;; # indicator changed 
                -o|--only_phix) ONLY=true; shift 1;; # indicator changed 
                -h|--help) usage; exit 1; shift 1;;
                *) break;;    
        esac
done

# create a directory if not existed.
if [ ! -d "$LOCATION" ]; then
    echo "$LOCATION is created."
fi
mkdir -p "$LOCATION"

# Download phiX174 genome (illumina spikein) if needed
if [ "$SKIP" != true ]; then
    wget -N 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=9626372&rettype=fasta&retmode=text' -O "$LOCATION/phiX174.fa"
fi

# Download host genome if needed
# E.g. Download sus scrofa (pig) whole genome
# wget -N ftp://ftp.ensembl.org/pub/release-95/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa.gz -O "$LOCATION/host.fa.gz"
if [ "$ONLY" != true ]; then
    wget -N "$HOST" -O "$LOCATION/host.fa.gz"
    gzip -d "$LOCATION/host.fa.gz"
fi

# THREADS
if [ -z "$THREADS" ]; then
    THREADS=6
fi

# Build bowtie2 index
bowtie2-build $(echo "$LOCATION/*.fa" | sed "s/ /,/g") "$LOCATION/ref" --threads $THREADS


# Clean fasta files and print the bowtie2 database location
rm "$LOCATION/*.fa" -f
tput setaf 4
echo "The Bowtie2 database is located at $LOCATION."
echo "Please assign $LOCATION to environmental viriable \$KNEADDATA_DB_HUMAN_GENOME."

exit
