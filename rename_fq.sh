#########for merging different lanes of reads
#Yan Hui
#huiyan@food.ku.dk

#!/bin/sh
for directory in ./D[A-Z]
do 
cd $directory
name=$(basename "$PWD")
gzip -dc *_1.fq.gz > ../$name.R1.fastq
gzip -dc *_2.fq.gz > ../$name.R2.fastq
# respond the file processing
tput setaf 4
echo "$name has been merged as $name.R1.fastq and $name.R2.fastq"
cd ..
done
