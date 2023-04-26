

rule myporechopABI:
    input: "PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
    
    output: "PorechopABI/output_reads.fastq"
    
    conda: "envs/porechopabi.yml"
    
    shell: "porechop_abi -abi -i {input} -o {output} > log_file.txt 2>&1"
    #shell: "~/miniconda3/envs/porechop_abi/bin/porechop_abi -abi -i {input} -o {output} > Log_file.txt 2>&1"