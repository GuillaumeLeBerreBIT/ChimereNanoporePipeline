# Snakemake workflow: ChimereNanoporePipeline

A snakemake workflow that takes fastq files as input and creates a mitochondrial genome assembly. As mentioned the workflow is made in Snakemake, integrating different bio-informatic tools as Porechop ABI, Prowler, SACRA, ... with many other Python scripts to gathering output, generating a HTML report file to visualize results of each step in the pipeline. 

The main purpose is to detect chimeric reads in a dataset and split the sequences in non-chimeric sequences. Using the corrected sequences to generate mitochondrial genome assembly. 

## Table of Contents 

- [WGA - Chimera reads](#wga---chimera-reads)
- [Installation](#installation)
- [Repository structure](#repository-structure)
- [Usage](#usage)
- [Credits](#credits)

## WGA - Chimera reads

Multiple displacement amplification (MDA) is Whole Genome Amplification method to rapdily amplify DNA samples. It is very efficient to increase small amounts of DNA with a high genome coverage due to the strand displacement and a low error rate. The process starts by annealing random hexamer primers on the ssDNA template. The synthesis will start on multiple sites on the template DNA. Chain-elongation is mediated by polymerase phi 29. Polymerase phi 29 has a high proofreading and strong displacement activity. When phi 20 polymerase encounters a downstream primer, due to it's strong strand displacement activity, it will cause the downstream strand to be gradually displaced of it's 5'-end. The chain-elongation continous as multiple rounds of hexamer primers and polymeases are added to the newly generated ssDNA strands. The exponential growth of DNA, has branched structure generating clusters of DNA molecules. 

In the process of MDA creating a branched structure, the displaced ssDNA strands goes in competition with the newly generated template. When the displaced strand re-attaches to the template, the newly generated strand at 3'-end falls off. What happens is the extended strand at 3' will bind with other secondary structures creating these chimera reads. Chimeras are multiple transcripts of DNA sequences joined toghete, also called split reads.   

When the phi 29 polymerase of the newly generated strand attaches to another ssDNA displaced strand. The chain-elongation continous along the new template, creating a ssDNA of 2 or more regions that do not belong togehter. These ssDNA are inverted chimeras. It is also possible that the phi 29 polymerase binds with the original template in a region with a similar base sequence but not identical. It skips the elongation from the displaced 3'-end of ssDNA and to new annealed position of phi 29 polymerase. 

## Installation

Can start by cloning the repository to your local system either using the SSH but then you need a keypair on your local computer and add the public key to your account. 
```
git clone git@github.com:GuillaumeLeBerreBIT/ChimereNanoporePipeline.git
```
Can also use the HTTPS link. 
```
git clone https://github.com/GuillaumeLeBerreBIT/ChimereNanoporePipeline.git
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
WATCH OUT! If channel_priority is set to strict, it will not be able to do the conda installations. Can delete it from the .condarc file. 

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
Need to source or restart terminal to configure the PATH variable. 
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

To run the pipeline, go to the `workflow` folder. From there can use the following command (not recommended). When running the pipeline for the first time it will need to install all the programs used, which is done by installing all dependencies through conda from a YAML-file. The conda installations can take a long time to install. NOTE! Activate the snakemake conda environment to run.
```
snakemake --use-conda 
```
Depending the system using, will have a limited amount of resources. Can limit the amount of threads used, using the `--jobs` command. Using `--jobs 8` will use 8 threads in parallel to perform snakemake, depending on your system can lower or make it higher. 
```
snakemake --use-conda --jobs 8
```
Depending on the amount of cores can use need to lower it. It is very important to set the right amount of threads/jobs it can use. When the jobs is set differently then given here, NEED to change the amount of threads Porechop ABI rule can use. When there aren't enough threads available to perform the Porechop ABI rule or too many Porechop rules are running in parallell, results in the pipeline crashing.

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

Credits to the authors of the different tools, that have been used for creating this pipeline.

Bio-informatics tool for adapter removal: [Porechop ABI](https://github.com/bonsai-team/Porechop_ABI)

Bio-informatics tool for quality trimming: [ProwlerTrimmer](https://github.com/ProwlerForNanopore/ProwlerTrimmer)

Bio-informatics tool for chimera removal: [SACRA](https://github.com/hattori-lab/SACRA) [Paper](https://doi.org/10.1093/dnares/dsab019)

Bio-informatics tool for BLASTX: [DIAMOND](https://github.com/bbuchfink/diamond) [Paper](https://www.nature.com/articles/s41592-021-01101-x)

Bio-informatics tool for assembly: [Flye](https://github.com/fenderglass/Flye) 

Bio-informatics tool for assembly: [SPAdes](https://github.com/ablab/spades)

Bio-informatics tool for gene annotation: [MITOS2](https://gitlab.com/Bernt/MITOS/-/tree/mitos2)