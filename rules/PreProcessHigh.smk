#################### MODULES ####################
import os, glob

################# CONCAT FILES ####################
# Combining all fasta files after SACRA in to one big file. 
# Can experiment with this may not even have to wait, extra security check

rule ConcatFiles:
    input: 
        expand(
            os.path.join(DATA_DIR, f"{SEQ_DIR}/{SAMPLE}.fastq"), 
            file = FILES, META_DIR = META_DIR, SAMPLE = SAMPLE)

    output: 
        os.path.join(DATA_DIR, "{META_DIR}/Concatted_File/{SAMPLE}Concattedfiles.fasta")
    conda:
        "../envs/pythonChimereWorkflow.yaml"
    threads: 
        4
    shell: 
        """
        python3 scripts/ConcatFiles.py {input} {output} 
        """


#################### PORECHOP ABI ####################
# Porechop ABI will detect and remove the adapters present on Nanopore reads. 
# -abi flag allows to first guess the adapters from the reads, add the adapters to the list of Porechop adapters and then run Porechop. 
# The output fastq files saved in a folder & statistical report from terminal in another folder. 
# THE AMOUNT OF THREADS MORE THEN THE BASH COMMAND PORECHOP

rule PorechopABI:
    input: 
        os.path.join(DATA_DIR, "{META_DIR}/Concatted_File/{SAMPLE}Concattedfiles.fasta")
    output: 
        reads = os.path.join(DATA_DIR, f"{META_DIR}/PorechopABI/{SAMPLE}/{SAMPLE}PoreChopReads.fastq"),
        statistics = os.path.join(DATA_DIR, f"{META_DIR}/results/{SAMPLE}/PorechopABI/{SAMPLE}Statistics.txt")
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
  
rule Prowler:
    input:
        out_fastq = os.path.join(DATA_DIR, f"{META_DIR}/PorechopABI/{SAMPLE}/{SAMPLE}PoreChopReads.fastq"), 
    output:
        out_prow_fasta = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta") 
            
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

#################### SACRA ####################
# SACRA splits the chimeric reads to the non-chimeric reads in long reads of MDA-treated sample. 
# Make sure the path to the scripts folder is added onto the path, otherwise SACRA won't be able to find the subscripts. 
# This will be noticed as the output files will be empty & in the terminal says to the steps 3 & 4 command not found. 

rule SACRA:
    input:
        os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta")
            
    output: 
        os.path.join(DATA_DIR, f"{META_DIR}/SACRAResults/{SAMPLE}/{SAMPLE}SacraResults.fasta")

    conda:
        "../envs/sacra.yaml"
    # Could be the values need to be restored or set the variables in the Snakefile
    params:
        blasttab = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.blasttab"),
        bck = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.bck"),
        des = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.des"),
        prj = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.prj"),
        sds = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.sds"),
        ssp = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.ssp"),
        suf = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.suf"),
        tis = os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{SAMPLE}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.tis")
    threads:
        4

    shell: 
        """
        SACRA.sh -i {input} -p {output} -t 4 -c scripts/config.yml
        rm {params.blasttab}* {params.bck} {params.des} {params.prj} {params.sds} {params.ssp} {params.suf} {params.tis}
        """

