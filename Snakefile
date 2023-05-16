#################### MODULES ####################
import os
#################### CONFIG FILE ####################
configfile: "config_snakemake.yaml"
#################### CONFIG VARIABLES ####################
# Calling for the starting folder as variable from the config file. 
inputfolder = config['startfolder']
# The files as input 
FASTQFOL = os.listdir(inputfolder)
FILES = []
# Iterate over the folder to get the extension removed
for fastq in FASTQFOL:
    stripped_fastq = fastq.replace(".fastq", "")
    FILES.append(stripped_fastq)

# Calling a identifier to use for the folders where files are created. 
identifier = config["identifier"]

clip = config['prowler']['clip']

fragments = config['prowler']['fragments']

trimmode = config['prowler']['trimmode']

qscore = config['prowler']['qscore']

windowsize = config['prowler']['windowsize']

minlen = config['prowler']['minlen']

datamax = config['prowler']['datamax']

gene = config['genes']

#################### RULE ALL ####################
rule all:
    input:
        # This is to make sure everything for the last "FOR" loop is completed == TARGETS
        expand("SACRAResults/{identifier}/{i}SacraResults.fasta", identifier = identifier, i = FILES),
        # Set the actual target file == TARGET
        f"reports/{identifier}/{identifier}Results.html"


#################### PORECHOP ABI ####################
# Config makes it possible to parse commands through the command line, it overwrites the config file itself. 
# Changed so the input file is taken from the config file to process
# When using loops con not name them
for i in FILES:
    rule:
        input: 
            f"{inputfolder}/{i}.fastq"
        output: 
            reads = f"PorechopABI/{identifier}/{i}PoreChopReads.fastq",
            statistics = f"reports/{identifier}/PorechopABI/{i}Statistics.txt"
        conda: 
            "envs/porechop_abi.yaml"
        shell: 
            """
            porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1
            """
    

#################### PROWLER TRIMMING ####################
# Have to format the name of the output file since it is dependant on parameters provided by the config file.  
for i in FILES:    
    rule:
        input:
            out_fastq = f"PorechopABI/{identifier}/{i}PoreChopReads.fastq" 
        output:
            out_prow_fasta = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta" 
                
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
            """
            python3 scripts/TrimmerLarge.py -f {input.out_fastq} -i PorechopABI/{params.folder}/ -o ProwlerProcessed/{params.folder}/ -m {params.trimmode} -c {params.clip} -g {params.fragments} -q {params.qscore} -w {params.windowsize} -l {params.minlen} -d {params.datamax} -r '.fasta'
            """
#################### SACRA ####################
# Makes use of a script to filter the fasta files based on the length of the reads, to only retain above certain treshold.
for i in FILES:    
    rule:
        input:
            in_sacra = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta"
                
        output: 
            sacraFull = f"SACRAResults/{identifier}/{i}SacraResults.fasta"    
        conda:
            "envs/sacra.yaml"
        params:
            blasttab = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.blasttab",
            bck = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.bck",
            des = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.des",
            prj = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.prj",
            sds = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.sds",
            ssp = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.ssp",
            suf = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.suf",
            tis = f"ProwlerProcessed/{identifier}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.tis"
        shell: 
            """
            scripts/SACRA.sh -i {input.in_sacra} -p {output.sacraFull} -t 6 -c config_snakemake.yaml
            rm {params.blasttab}* {params.bck} {params.des} {params.prj} {params.sds} {params.ssp} {params.suf} {params.tis}
            """

################# CONCAT FILES ####################
# Can experiment with this may not even have to wait, extra security check
# First file
first_file = FILES[0]
# The target number of files 
target_number = len(FILES) 

rule ConcatFiles:
    input: 
        filesSacra = f"SACRAResults/{identifier}/{first_file}SacraResults.fasta",
        #dummySacra = expand("SACRAResults/{identifier}/{i}SacraResults.fasta", identifier = config['identifier'], i = FILES)
    output: 
        outputFile = f"SACRAResults/{identifier}Concatfiles.fasta"
    params:
        target_num = target_number
    threads: 1
    shell: 
        """
        python3 scripts/ConcatFiles.py {input.filesSacra} {output.outputFile} {params.target_num}
        """

################# FILTER SACRA ####################
# Makes use of a script to filter the fasta files based on the length of the reads, to only retain above certain treshold.
rule FilterFastaSACRA:
    input:
        sacraUF = f"SACRAResults/{identifier}Concatfiles.fasta"
    output:
        sacraF = f"SACRAResults/{identifier}SacraResultsFiltered.fasta"
    params:
        bases = config['filterSACRA']['bases']
    shell:
        """
        python3 scripts/Filtering_SACRA_sequences.py -b {params.bases} {input.sacraUF} {output.sacraF}
        """

################# DIAMOND ####################
# DIAMOND will be used to BLASTX the fasta file against the mitochondriol genes, split up into 13 databases.
# It will generate the output in a folder containing 13 csv files, each containing the BLASTX results against one of the genes. 
rule DiamondAlignment:
    input: 
        sacraF = f"SACRAResults/{identifier}SacraResultsFiltered.fasta"
    output: 
        DiamondATP6 = f"Diamond/{identifier}/{identifier}Diamond_ATP6.csv",
        DiamondATP8 = f"Diamond/{identifier}/{identifier}Diamond_ATP8.csv",
        DiamondCOX1 = f"Diamond/{identifier}/{identifier}Diamond_COX1.csv",
        DiamondCOX2 = f"Diamond/{identifier}/{identifier}Diamond_COX2.csv",
        DiamondCOX3 = f"Diamond/{identifier}/{identifier}Diamond_COX3.csv",
        DiamondCYTB = f"Diamond/{identifier}/{identifier}Diamond_CYTB.csv",
        DiamondNAD1 = f"Diamond/{identifier}/{identifier}Diamond_NAD1.csv",
        DiamondNAD2 = f"Diamond/{identifier}/{identifier}Diamond_NAD2.csv",
        DiamondNAD3 = f"Diamond/{identifier}/{identifier}Diamond_NAD3.csv",
        DiamondNAD4 = f"Diamond/{identifier}/{identifier}Diamond_NAD4.csv",
        DiamondNAD4L = f"Diamond/{identifier}/{identifier}Diamond_NAD4L.csv",
        DiamondNAD5 = f"Diamond/{identifier}/{identifier}Diamond_NAD5.csv",
        DiamondNAD6 = f"Diamond/{identifier}/{identifier}Diamond_NAD6.csv"
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

################# FILTER DIAMOND ####################
# Having all the BLASTX results in a csv file, all gathered in a folder. The script will scan folder for all files being a csv file and extract the results. 
# In the config file can set up filters: ID percentage, Length of residues and e-value. 
# It will generate statistical figures & rewrite the BLAST hits to a new FASTA file for ASSEMBLY.  
rule FilteringDIAMOND:
    input: 
        Diamond = expand("Diamond/{identifier}/{identifier}Diamond_{gene}.csv", identifier = config['identifier'], gene = config['genes']),
        #inFol = expand("Diamond/{fold}", fold = config['identifier']),
        sacraF = f"SACRAResults/{identifier}SacraResultsFiltered.fasta"
    output: 
        assem = f"AssemblyFasta/{identifier}FastaForAssembly.fasta"
    params:
        # Define folders under params and not as output otherwise will get an error.
        folder = config['identifier'],
        idper = config['filtDIA']['idperc'],
        length = config['filtDIA']['len'],
        evalue = config['filtDIA']['eval']
    shell:
        "python3 scripts/DiamondToAssembly.py -i {params.idper} -l {params.length} -e {params.evalue} Diamond/{params.folder} {input.sacraF} {output.assem}"


################# STATISTICS TO HTML ####################
# Combining all different files used to generate a general report file.  
rule StatisticsToHTML:
    input: 
        sacraF = f"SACRAResults/{identifier}SacraResultsFiltered.fasta",
        Diamond = expand("Diamond/{identifier}/{identifier}Diamond_{gene}.csv", identifier = config['identifier'], gene = config['genes']),
        assem = expand("AssemblyFasta/{identifier}FastaForAssembly.fasta", identifier = config['identifier'])
    output: 
        f"reports/{identifier}/{identifier}Results.html"
    params:
        # Set the folders as parameters to give on the command line
        poreStat = f"reports/{identifier}/PorechopABI/",
        poreFastq = f"PorechopABI/{identifier}/",
        prowFold = f"ProwlerProcessed/{identifier}/"
    shell: 
        """
        python3 scripts/StatisticalReportGenerator.py {output} {params.poreStat} {params.poreFastq} {params.prowFold} {input.sacraF}
        """