# Giving the necassary configfile with snakemake >> This contains input files as parameters to perfroms scripts/commands. 
configfile: "config_snakemake.yaml"
# Rule to get all the output files and save
rule all:
    input:
        "reports/Results.html"


# Rule to call the porechop program and saving the output in files
# Config makes it possible to parse commands through the command line, it overwrites the config file itself. 
# snakemake --use-conda --cores all --forceall --config start="PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
# Changed so the input file is taken from the config file to process
rule porechopABIcall:
    input: 
        #config['start']
        expand("PorechopABI/{sample}", sample=config["samples"])
    output: 
        reads="PorechopABI/PoreChopReads.fastq",
        statistics="reports/Statistics.txt"
    conda: 
        "envs/porechop_abi.yaml"
    shell: 
        "porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1"
        
# Rule to trim the reads using Prowler and save the output
# Define the script folder in the rule
# Have to format the name of the output file since it is dependant on parameters provided by the config file.  
rule ProwlerTrim:
    input:
        out_fastq="PorechopABI/PoreChopReads.fastq" 
    output:
        out_prow_fasta = expand("ProwlerProcessed/PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax'])
    params:
        clip = config['prowler']['clip'], 
        fragments = config['prowler']['fragments'],
        trimmode = config['prowler']['trimmode'],
        qscore = config['prowler']['qscore'],
        windowsize = config['prowler']['windowsize'],
        minlen = config['prowler']['minlen'],
        datamax = config['prowler']['datamax']
    shell:
        "python3 scripts/TrimmerLarge.py -f {input.out_fastq} -i PorechopABI/ -o ProwlerProcessed -m {params.trimmode} -c {params.clip} -g {params.fragments} -q {params.qscore} -w {params.windowsize} -l {params.minlen} -d {params.datamax} -r '.fasta'"

# Rule to use the SACRA reads
# Again here using a formatted string since it is dependant on certain parameters provided by a script.  
rule SACRAcall:
    input:
        in_sacra = expand("ProwlerProcessed/PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax'])
    output: 
        "SACRAResults/SacraResults.fasta"
    conda:
        "envs/sacra.yaml"
    shell: 
        "scripts/SACRA.sh -i {input.in_sacra} -p {output} -t 6 -c config_sacra.yml"

# Combining all different files used to generate a general report file.  
rule StatisticsToHTML:
    input: 
        poreStat = "reports/Statistics.txt",
        poreFastq = "PorechopABI/PoreChopReads.fastq",
        prow = expand("ProwlerProcessed/PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacra = "SACRAResults/SacraResults.fasta"
    output: 
        "reports/Results.html"
    shell: 
        "python3 scripts/generate_report.py {input.poreStat} {input.poreFastq} {input.prow} {input.sacra}"
