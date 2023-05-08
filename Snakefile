# Giving the necassary configfile with snakemake >> This contains input files as parameters to perfroms scripts/commands. 
configfile: "config_snakemake.yaml"
# Rule to get all the output files and save
rule all:
    input:
        expand("reports/{identifier}Results.html", identifier = config["identifier"])


# Rule to call the porechop program and saving the output in files
# Config makes it possible to parse commands through the command line, it overwrites the config file itself. 
# snakemake --use-conda --cores all --forceall --config start="PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
# Changed so the input file is taken from the config file to process
rule porechopABIcall:
    input: 
        #config['start']
        expand("PorechopABI/{sample}", sample=config["samples"])
    output: 
        reads = expand("PorechopABI/{identifier}PoreChopReads.fastq", identifier=config["identifier"]),
        statistics = expand("reports/{identifier}Statistics.txt", identifier=config["identifier"])
    conda: 
        "envs/porechop_abi.yaml"
    shell: 
        "porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1"
        
# Rule to trim the reads using Prowler and save the output
# Define the script folder in the rule
# Have to format the name of the output file since it is dependant on parameters provided by the config file.  
rule ProwlerTrim:
    input:
        out_fastq = expand("PorechopABI/{identifier}PoreChopReads.fastq", identifier=config["identifier"]) 
    output:
        out_prow_fasta = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            identifier = config["identifier"],
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
        in_sacra = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax'])
    output: 
        sacraFull = expand("SACRAResults/{identifier}SacraResults.fasta", identifier = config["identifier"]),
        sacraChim = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.split.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraNonChim = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.non_chimera.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax'])
    conda:
        "envs/sacra.yaml"
    shell: 
        "scripts/SACRA.sh -i {input.in_sacra} -p {output.sacraFull} -t 6 -c config_sacra.yml"

rule FilterFastaSACRA:
    input:
        sacraUF = expand("SACRAResults/{identifier}SacraResults.fasta", identifier = config["identifier"])
    output:
        sacraF = expand("SACRAResults/{identifier}SacraResultsFiltered.fasta", identifier = config["identifier"])
    params:
        bases = config['filterSACRA']['bases']
    shell:
        "python3 scripts/Filtering_SACRA_sequences.py -b {params.bases} {input.sacraUF} {output.sacraF}"

rule DiamondAlignmentCOI:
    input: 
        sacraF = expand("SACRAResults/{identifier}SacraResultsFiltered.fasta", identifier = config["identifier"])
    output: 
        DiamondCOI = expand("Diamond/{identifier}DiamondCOI.csv", identifier = config["identifier"])
    params:
        k = config['Diamond']['max-target-seq'],
        f = config['Diamond']['output-format']
    shell: 
        "diamond blastx -d Diamond/COI -q  {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondCOI}"

# Combining all different files used to generate a general report file.  
rule StatisticsToHTML:
    input: 
        poreStat = expand("reports/{identifier}Statistics.txt", identifier=config["identifier"]),
        poreFastq = expand("PorechopABI/{identifier}PoreChopReads.fastq", identifier=config["identifier"]),
        prow = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            identifier = config['identifier'],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraChim = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.split.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraNonChim = expand("ProwlerProcessed/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.non_chimera.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraF = expand("SACRAResults/{identifier}SacraResultsFiltered.fasta", identifier = config["identifier"])
    output: 
        expand("reports/{identifier}Results.html", identifier = config["identifier"])
    shell: 
        "python3 scripts/StatisticalReportGenerator.py {output} {input.poreStat} {input.poreFastq} {input.prow} {input.sacraChim} {input.sacraNonChim} {input.sacraF}"
