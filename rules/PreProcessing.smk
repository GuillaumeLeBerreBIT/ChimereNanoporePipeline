#################### MODULES ####################
import os, glob

#################### PORECHOP ABI ####################
# Porechop ABI will detect and remove the adapters present on Nanopore reads. 
# -abi flag allows to first guess the adapters from the reads, add the adapters to the list of Porechop adapters and then run Porechop. 
# The output fastq files saved in a folder & statistical report from terminal in another folder. 
# THE AMOUNT OF THREADS MORE THEN THE BASH COMMAND PORECHOP
for i in FILES:
    rule:
        input: 
            os.path.join(DATA_DIR, f"{SEQ_DIR}/{i}.fastq")
        output: 
            reads = os.path.join(DATA_DIR, f"{META_DIR}/PorechopABI/{SAMPLE}/{i}PoreChopReads.fastq"),
            statistics = os.path.join(DATA_DIR, f"{META_DIR}/results/{SAMPLE}/PorechopABI/{i}Statistics.txt")
        conda: 
            "../envs/porechop_abi.yaml"
        threads: 
            8
        shell: 
            """
            porechop_abi -abi --no_split -i {input} -o {output.reads} -t 8 > {output.statistics} 2>&1
            """
    

#################### PROWLER TRIMMING ####################
# Have to format the name of the output file since it is dependant on parameters provided by the config file.  
# Trimming tool for oxford nanopore sequences. Based on given parameters it will perform quality trimming of the fastq reads, directly coverting it to FASTA file. 
# Can define the output file in the rule without parsing it on the command line. Using params to give the folder on the command line. 
for i in FILES:    
    rule:
        input:
            out_fastq = os.path.join(DATA_DIR, f"{META_DIR}/PorechopABI/{SAMPLE}/{i}PoreChopReads.fastq"), 
        output:
            out_prow_fasta = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta") 
                
        params:
            clip = config['prowler']['clip'], 
            fragments = config['prowler']['fragments'],
            trimmode = config['prowler']['trimmode'],
            qscore = config['prowler']['qscore'],
            windowsize = config['prowler']['windowsize'],
            minlen = config['prowler']['minlen'],
            datamax = config['prowler']['datamax'],
            infolder = os.path.join(DATA_DIR, f"{META_DIR}/PorechopABI/{SAMPLE}/"),
            outfolder = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/")
        conda:
            "../envs/pythonChimereWorkflow.yaml"
        threads:
            1
        shell:
            """
            python3 scripts/TrimmerLarge.py -f {input.out_fastq} -i {params.infolder}/ -o {params.outfolder}/ \
            -m {params.trimmode} -c {params.clip} -g {params.fragments} -q {params.qscore} -w {params.windowsize} -l {params.minlen} \
            -d {params.datamax} -r '.fasta'
            """