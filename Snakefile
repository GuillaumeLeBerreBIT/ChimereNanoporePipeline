# Giving the necassary configfile with snakemake >> This contains input files as parameters to perfroms scripts/commands. 
configfile: "config_snakemake.yaml"
# Rule to get all the output files and save
rule all:
    input:
        expand("reports/{identifier}/{identifier}Results.html", identifier = config["identifier"])


# Rule to call the porechop program and saving the output in files
# Config makes it possible to parse commands through the command line, it overwrites the config file itself. 
# snakemake --use-conda --cores all --forceall --config start="PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
# Changed so the input file is taken from the config file to process
rule porechopABIcall:
    input: 
        #config['start']
        expand("PorechopABI/{identifier}/{sample}", sample=config["samples"], identifier = config["identifier"])
    output: 
        reads = expand("PorechopABI/{identifier}/{identifier}PoreChopReads.fastq", identifier=config["identifier"]),
        statistics = expand("reports/{identifier}/{identifier}Statistics.txt", identifier=config["identifier"])
    conda: 
        "envs/porechop_abi.yaml"
    shell: 
        "porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1"
        
# Rule to trim the reads using Prowler and save the output
# Define the script folder in the rule
# Have to format the name of the output file since it is dependant on parameters provided by the config file.  
rule ProwlerTrim:
    input:
        out_fastq = expand("PorechopABI/{identifier}/{identifier}PoreChopReads.fastq", identifier=config["identifier"]) 
    output:
        out_prow_fasta = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
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
        datamax = config['prowler']['datamax'],
        folder = config['identifier']
    shell:
        "python3 scripts/TrimmerLarge.py -f {input.out_fastq} -i PorechopABI/{params.folder}/ -o ProwlerProcessed/{params.folder}/ -m {params.trimmode} -c {params.clip} -g {params.fragments} -q {params.qscore} -w {params.windowsize} -l {params.minlen} -d {params.datamax} -r '.fasta'"

# Rule to use the SACRA reads
# Again here using a formatted string since it is dependant on certain parameters provided by a script.  
rule SACRAcall:
    input:
        in_sacra = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax'])
    output: 
        sacraFull = expand("SACRAResults/{identifier}/{identifier}SacraResults.fasta", identifier = config["identifier"]),
        sacraChim = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.split.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraNonChim = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.non_chimera.fasta", 
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

# Makes use of a script to filter the fasta files based on the length of the reads, to only retain above certain treshold.
rule FilterFastaSACRA:
    input:
        sacraUF = expand("SACRAResults/{identifier}/{identifier}SacraResults.fasta", identifier = config["identifier"])
    output:
        sacraF = expand("SACRAResults/{identifier}/{identifier}SacraResultsFiltered.fasta", identifier = config["identifier"])
    params:
        bases = config['filterSACRA']['bases']
    shell:
        "python3 scripts/Filtering_SACRA_sequences.py -b {params.bases} {input.sacraUF} {output.sacraF}"

# DIAMOND will be used to BLASTX the fasta file against the mitochondriol genes, split up into 13 databases.
# It will generate the output in a folder containing 13 csv files, each containing the BLASTX results against one of the genes. 
rule DiamondAlignment:
    input: 
        sacraF = expand("SACRAResults/{identifier}/{identifier}SacraResultsFiltered.fasta", 
                        identifier = config["identifier"])
    output: 
        DiamondATP6 = expand("Diamond/{identifier}/{identifier}Diamond_ATP6.csv", identifier = config['identifier']),
        DiamondATP8 = expand("Diamond/{identifier}/{identifier}Diamond_ATP8.csv", identifier = config['identifier']),
        DiamondCOX1 = expand("Diamond/{identifier}/{identifier}Diamond_COX1.csv", identifier = config['identifier']),
        DiamondCOX2 = expand("Diamond/{identifier}/{identifier}Diamond_COX2.csv", identifier = config['identifier']),
        DiamondCOX3 = expand("Diamond/{identifier}/{identifier}Diamond_COX3.csv", identifier = config['identifier']),
        DiamondCYTB = expand("Diamond/{identifier}/{identifier}Diamond_CYTB.csv", identifier = config['identifier']),
        DiamondNAD1 = expand("Diamond/{identifier}/{identifier}Diamond_NAD1.csv", identifier = config['identifier']),
        DiamondNAD2 = expand("Diamond/{identifier}/{identifier}Diamond_NAD2.csv", identifier = config['identifier']),
        DiamondNAD3 = expand("Diamond/{identifier}/{identifier}Diamond_NAD3.csv", identifier = config['identifier']),
        DiamondNAD4 = expand("Diamond/{identifier}/{identifier}Diamond_NAD4.csv", identifier = config['identifier']),
        DiamondNAD4L = expand("Diamond/{identifier}/{identifier}Diamond_NAD4L.csv", identifier = config['identifier']),
        DiamondNAD5 = expand("Diamond/{identifier}/{identifier}Diamond_NAD5.csv", identifier = config['identifier']),
        DiamondNAD6 = expand("Diamond/{identifier}/{identifier}Diamond_NAD6.csv", identifier = config['identifier'])
    params:
        k = config['Diamond']['max-target-seq'],
        f = config['Diamond']['output-format'],
        folder = config['identifier']
    # Will create a folder with the identifier, since then only the resulst to a specific run belong to that folder. 
    # To generate statistical output its easier to handel the files in a  determined directory.  
    # Using """ Can all have different bash commands each executed on seperate line.
    # Do not have to set a "mkdir folder" since the path defined will automatically create a destined folder. 
    shell: 
        """
        diamond blastx -d Diamond/DB/ATP6 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondATP6}
        diamond blastx -d Diamond/DB/ATP8 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondATP8}
        diamond blastx -d Diamond/DB/COX1 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondCOX1}
        diamond blastx -d Diamond/DB/COX2 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondCOX2}
        diamond blastx -d Diamond/DB/COX3 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondCOX3}
        diamond blastx -d Diamond/DB/CYTB -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondCYTB}
        diamond blastx -d Diamond/DB/NAD1 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD1}
        diamond blastx -d Diamond/DB/NAD2 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD2}
        diamond blastx -d Diamond/DB/NAD3 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD3}
        diamond blastx -d Diamond/DB/NAD4 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD4}
        diamond blastx -d Diamond/DB/NAD4L -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD4L}
        diamond blastx -d Diamond/DB/NAD5 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD5}
        diamond blastx -d Diamond/DB/NAD6 -q {input.sacraF} -k {params.k} -f {params.f} -o {output.DiamondNAD6}
        """

# Having all the BLASTX results in a csv file, all gathered in a folder. The script will scan folder for all files being a csv file and extract the results. 
# In the config file can set up filters: ID percentage, Length of residues and e-value. 
# It will generate statistical figures & rewrite the BLAST hits to a new FASTA file for ASSEMBLY.  
rule FilteringDIAMOND:
    input: 
        Diamond = expand("Diamond/{identifier}/{identifier}Diamond_{gene}.csv", identifier = config['identifier'], gene = config['genes']),
        #inFol = expand("Diamond/{fold}", fold = config['identifier']),
        sacraF = expand("SACRAResults/{identifier}/{identifier}SacraResultsFiltered.fasta", identifier = config["identifier"])
    output: 
        assem = expand("AssemblyFasta/{identifier}FastaForAssembly.fasta", identifier = config['identifier'])
    params:
        # Define folders under params and not as output otherwise will get an error.
        folder = config['identifier'],
        idper = config['filtDIA']['idperc'],
        length = config['filtDIA']['len'],
        evalue = config['filtDIA']['eval']
    shell:
        "python3 scripts/DiamondToAssembly.py -i {params.idper} -l {params.length} -e {params.evalue} Diamond/{params.folder} {input.sacraF} {output.assem}"


# Combining all different files used to generate a general report file.  
rule StatisticsToHTML:
    input: 
        poreStat = expand("reports/{identifier}/{identifier}Statistics.txt", identifier=config["identifier"]),
        poreFastq = expand("PorechopABI/{identifier}/{identifier}PoreChopReads.fastq", identifier=config["identifier"]),
        prow = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta", 
            identifier = config['identifier'],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraChim = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.split.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraNonChim = expand("ProwlerProcessed/{identifier}/{identifier}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.non_chimera.fasta", 
            identifier = config["identifier"],
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax']),
        sacraF = expand("SACRAResults/{identifier}/{identifier}SacraResultsFiltered.fasta", identifier = config["identifier"]),
        Diamond = expand("Diamond/{identifier}/{identifier}Diamond_{gene}.csv", identifier = config['identifier'], gene = config['genes']),
        assem = expand("AssemblyFasta/{identifier}FastaForAssembly.fasta", identifier = config['identifier'])
    output: 
        expand("reports/{identifier}/{identifier}Results.html", identifier = config["identifier"])
    shell: 
        "python3 scripts/StatisticalReportGenerator.py {output} {input.poreStat} {input.poreFastq} {input.prow} {input.sacraChim} {input.sacraNonChim} {input.sacraF}"
