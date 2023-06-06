# Snakemake workflow: ChimereNanoporePipeline

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)


A Snakemake workflow for removing chimeras from Oxford Nanopore data.

## Installation

Can start by cloning the repository to your local system. 
```
git clone git@github.com:GuillaumeLeBerreBIT/ChimereNanoporePipeline.git
```

Snakemake requires to have a conda installation on your system. The preferred conda distribution is mambaforge since it has the required python commands & mamba which is a very fast installation. 
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```
When the download of miniconda is complete can start the local installation. The installation can be completly up to you where to install it on your system. 
```
bash Miniconda3-latest-Linux-x86_64.sh
```
Snakemake will make use of the conda environment to install envs provided by yaml files. The configuration of the .condarc file is very important for Snakemake!
```
conda config --add channels conda-forge
conda config --add channels bioconda
```
The resulting .condarc file looks like this.
```
auto_activate_base: false
channels:
  - bioconda
  - conda-forge
  - defaults
```

Snakemake can be instsalled using a conda. Mamba is possible to use as well if installed. 
```
conda create -c conda-forge -c bioconda -n snakemake snakemake=7.25.0
```
Can check if snakemake is installed. The version should be 7.25 if installed using previous command. 
```
conda activate snakemake
snakemake --help
snakemake --version
```

Snakemake uses multiple scripts, one of the scripts SACRA.sh uses multiple other scripts. Need to provide the path to the .bashrc file of the scripts folder.
```
nano ~/.bashrc
```
Can add the path to the scripts folder using PATH variable. The path is dependant on where the folder was cloned/placed. This is an example when the folder is placed in the "home" directory.
```
export PATH=$PATH:~/ChimereNanoporePipeline/workflow/scripts/
```

## Folder strcuture

```
├── Cmaenas_minion_data
├── config
├── resources
│   ├── DIAMOND-DB
│   ├── DIAMOND-Genes
│   ├── MITOS2-DB
│   ├── Styles
│   └── software
├── results
│   └── fastq_runid_211
├── tuning-params
│   ├── config
│   ├── input-file
│   └── scripts
└── workflow
    ├── AssemblyFasta
    ├── Diamond
    ├── FlyeResults
    ├── MITOS2Results
    ├── PorechopABI
    ├── ProwlerProcessed
    ├── SACRAResults
    ├── envs
    ├── scripts
    └── snakefile-tests
```


## Usage


## Credits

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) <repo>sitory and its DOI (see above).


