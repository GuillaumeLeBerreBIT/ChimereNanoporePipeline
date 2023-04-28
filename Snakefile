rule all:
    input:
        "reports/Results.html"

rule porechopABI_call:
    input: 
        "PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
    output: 
        reads="PorechopABI/Output_reads.fastq",
        statistics="reports/Statistics.txt"
    conda: 
        "porechop_abi"
    shell: 
        "porechop_abi -abi -i {input} -o {output.reads} > {output.statistics} 2>&1"

rule StatisticsToHTML:
    input: 
        "reports/Statistics.txt"
    output: 
        "reports/Results.html"
    script: 
        "scripts/generate_report.py"