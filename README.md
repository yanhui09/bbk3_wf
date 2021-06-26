# Run biobakery3 workflow at KU FOOD
This is simplied use of biobakery3 workflow at KU FOOD.
It contains the installation instruction, and a tutorial to run the workflow using the example data provided by the biobakery team.

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