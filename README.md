# Run biobakery3 workflow at KU FOOD
This is simplied use of biobakery3 workflow at KU FOOD.
It contains the installation instruction, and a tutorial to run the workflow using the example data provided by the biobakery team. This repository contains easy-to-use wrapped shell scripts to run biobakery_pipeline. For advanced users, please directly use [biobakery workflows](https://github.com/biobakery/biobakery_workflows).

## Repository structure

```
├── biobakery_wmgx.sh
├── environment.yaml
├── bwt2_build.sh
├── examples
└── rename_fq.sh
```

## Installation

**Create a work enviroment for biobakery 3**

```
conda env create -n biobakery -f environment.yaml
```

[Mamba](https://github.com/mamba-org/mamba) is recommendede due to the improved dependency solving.
```
conda install -n base -c conda-forge mamba
mamba env create -n biobakery -f environment.yaml
```

**Download the required database**
```
conda activate biobakery
metaphlan --install
biobakery_workflows_databases --install wmgx --location /path/to/custom/location
```

By default, Biobakery 3 will use *Homo sapiens* GCRh37 as reference to remove host contamination. You can also set custom host reference with [`bwt2_build.sh`](/bwt2_build.sh).

```
./bwt2_build.sh -h

Note: Build bowtie2 databsed for the kneaddata.

Usage: ./bwt2_build.sh [-i -t -l -s -o -h]
  -i, --host    Required, ftp link of host genome on ensembl, RefSeq etc.(soft-/un-masked primirary assemblies)
  E.g., https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/003/025/GCF_000003025.6_Sscrofa11.1/GCF_000003025.6_Sscrofa11.1_genomic.fna.gz
  E.g., https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/002/315/GCA_000002315.5_GRCg6a/GCA_000002315.5_GRCg6a_genomic.fna.gz
  E.g., http://ftp.ensembl.org/pub/release-104/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz
  -t, --threads    Required, the number of the threads. Default: 6.
  -l, --location    Required, a custom location to hold the built bowtie2 database.
  -s, --skip_phix    Optional, not including phix genome.
  -o, --only_phix    Optional, only phix genome.
  -h, --help      Optional, help message.

Example:
./bwt2_build.sh -i /link/to/host_fa -l /path/to/output
./bwt2_build.sh -l /path/to/output -o

```