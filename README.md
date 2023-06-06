# Snakemake workflow: ChimereNanoporePipeline

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
Need to source or restart terminal to configure the PATH variable
```
source ~/.bashrc
```
## Repository structure

To show an overview of how the respoitory is set up. The results of the pipeline will be collected in the `results` folder, containing subfolders dependant on the identifier. The config file used by snakemake is in the `config`, containing all different parameters used in the Snakefile. The `Snakefile` is present in the workflow folder. The `workflow` contain data generated by all different rules from the pipeline. The `workflow` folder has a `scripts`, `envs` folder which are used by different rules from the Snakefile.  

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
    └── snakefile-templates
```


## Usage

To run the pipeline, go to the `workflow` folder. From there can use the following command (not recommended). NOTE! Activate the snakemake conda environment to run.
```
snakemake --use-conda 
```
Depending the system using, will have a limited amount of resources. Can limit the amount of threads used, using the `--jobs` command. Using `--jobs 8` will use 8 threads in parallel to perfrom snakemake, depending on your system can lower or make it higher. 
```
snakemake --use-conda --jobs 8
```
Depending on the amount of cores can use need to lower it. It is very important to set the right amount of threads/jobs it can use. When the jobs is set differently then given here, NEED to change the amount of threads Porechop ABI rule can use. When there aren't enough threads available to perform the Porechop ABI rule or too many Porechop rules are running in parallell, results in the pipeline crashing.

Flye is also very computational intensive. When encountering memomory problems need to add `--asm-coverage` & `--genome-size` in the command from flye itself. 

Other programs when the amount of cores specified are not available will be able to scale down the processes. 

Snakefile will use the `config_snakemake.yaml` with all different parameters used in from the pipeline. Before starting Snakemake, will need to specify the input folder by `startfolder: ` containing all the fastq files to parse through the pipeline. 
```
startfolder: "../Cmaenas_minion_data"
```

Using a unique `identifier` this for creating folder/file names. Using different names to save the rsults in different runs. WATCH OUT! Previous used identifiers where same files are still present may result in rewriting files or combine files from different experiments. An identifier can also be used as species identifier, to in the future add files of previously used species/files to get more results in addition to previous results. 
```
identifier: "fastq_runid_211"
```

## Credits

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) <repo>sitory and its DOI (see above).


