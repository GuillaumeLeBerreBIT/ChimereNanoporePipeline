# Rule to get all the output files and save
rule all:
    input:
        "reports/Results.html",
        "reports/Statistics.txt",
        directory("ProwlerProcessed")

# The rule to call the porechop program and saving the output in files
rule porechopABI_call:
    input: 
        "PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
    output: 
        reads="PorechopABI/Output_reads.fastq",
        statistics="reports/Statistics.txt"
    conda: 
        "envs/porechop_abi.yaml"
    shell: 
        "porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1"
        
# Get the output from the terminal into an html file which can be used to generate the report. 
rule StatisticsToHTML:
    input: 
        "reports/Statistics.txt"
    output: 
        "reports/Results.html"
    script: 
        "scripts/generate_report.py"

# Rule to trim the reads using Prowler and save the output
rule ProwlerTrim:
    input:
        "PorechopABI/Output_reads.fastq" 
    output:
        directory("ProwlerProcessed") 
    shell:
        "python3 scripts/TrimmerLarge.py -f {input} -i PorechopABI/ -o {output} -m 'D' -r '.fasta'"
