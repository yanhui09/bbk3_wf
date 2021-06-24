#!/bin/bash
# Merge different lanes of reads and rename fastqs to follow the biobakery workflow requirements
# University of Copenhagen
# 2021/06/22
# Yan Hui
# huiyan@food.ku.dk
#---------------------------------------------------------------------------------

# Wrapped function, e.g. usage()
usage () {
    echo ""
    echo "Note: Merge different lanes of reads and rename fastqs to follow biobakery format (*.R{1,2}.fq.gz)."
    echo ""
    echo "Usage: $0 [-i -r -o -h]"
    echo "  -i, --input    Required, path to the sample-wise diretories holding R1 and R2 fastqs"
    echo "  E.g. /path/to/dir contains s*/*_{1,2}.fq.gz"
    echo "  -r, --regex_r1    Required, regex expression to match r1 reads"
    echo "  -o, --output    Required, path to a custom output location"
    echo "  -h, --help      Optional, help message"   
    echo ""
    echo "Example:"
    echo "$0 -i /path/to/input -regex_r1 \"*_1.fq.gz\" -o /path/to/output"
    echo "";}

#############################################################################
# Check input, ensure alphabet/numbers behind -/--, and at least one option
if [ $# -eq 0 ] || ! [[ $* =~ ^(-|--)[a-z] ]]; then 
    echo "Invalid use: please check the help message below." ; usage; exit 1; fi
# Params loading
args=$(getopt --long "input:,regex_r1:,output:,help" -o "i:r:o:h" -n "Input error" -- "$@")
# Ensure corrected input of params
if [ $? -ne 0 ]; then usage; exit 1; fi

eval set -- "$args"

while true; do
        case "$1" in
                -i|--input) INPUT="$2"; shift 2;;
                -r|--regex_r1) REGEX_R1="$2"; shift 2;;
                -o|--output) OUTPUT="$2"; shift 2;;
                -h|--help) usage; exit 1; shift 1;;
                *) break;;    
        esac
done

REGEX_R2=${REGEX_R1//_1/_2}

# Check if output location exists
if [ ! -d "$OUTPUT" ]; then
    echo "$OUTPUT is created."
fi
mkdir -p "$OUTPUT"

for directory in "$INPUT"/*/
do 
name=$(basename "$directory")
cat "$directory"${REGEX_R1} > "$OUTPUT/$name".R1.fq.gz
cat "$directory"${REGEX_R2} > "$OUTPUT/$name".R2.fq.gz
# respond the file processing
tput setaf 4
echo "$name gzipped fastqs have been merged as $name.R1.fq.gz and $name.R2.fq.gz under $OUTPUT."
done
