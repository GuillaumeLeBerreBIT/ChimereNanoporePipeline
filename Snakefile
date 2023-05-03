# Rule to get all the output files and save
rule all:
    input:
        #"PorechopABI/Output_reads.fastq",
        #"reports/Statistics.txt",
        #directory("ProwlerProcessed"),
        #"SACRAResults/sacra_results.fasta",
        "reports/Results.html"
# Rule to call the porechop program and saving the output in files
rule porechopABIcall:
    input: 
        "PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
    output: 
        reads="PorechopABI/Output_reads.fastq",
        statistics="reports/Statistics.txt"
    conda: 
        "envs/porechop_abi.yaml"
    shell: 
        "porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1"
        
# Rule to trim the reads using Prowler and save the output
# Define the script folder in the rule
rule ProwlerTrim:
    input:
        out_fastq="PorechopABI/Output_reads.fastq" 
    output:
        out_prow="ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta"
    shell:
        "python3 scripts/TrimmerLarge.py -f {input.out_fastq} -i PorechopABI/ -o ProwlerProcessed -m 'D' -r '.fasta'"

#Rule to use the SACRA reads
rule SACRAcall:
    input:
        in_sacra="ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta"
    output: 
        "SACRAResults/sacra_results.fasta"
    conda:
        "envs/sacra.yaml"
    shell: 
        "scripts/SACRA.sh -i {input.in_sacra} -p {output} -t 6 -c config_sacra.yml"

# Get the output from the terminal into an html file which can be used to generate the report. 
rule StatisticsToHTML:
    input: 
        pore="reports/Statistics.txt",
        prow1="PorechopABI/Output_reads.fastq",
        prow2="ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta",
        sacra="SACRAResults/sacra_results.fasta"
    output: 
        "reports/Results.html"
    script: 
        "scripts/generate_report.py"
