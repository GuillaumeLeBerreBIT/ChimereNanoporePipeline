params.reads_file = "PorechopABI/fastq_runid_211de24bb98b581ec357aee6dd1409fc7b321927_0_0.fastq"
params.trimmer_script = "scripts/TrimmerLarge.py"
params.sacra_script = "scripts/SACRA.sh"
params.sacra_config = "config_sacra.yml"
params.report_generator = "scripts/generate_report.py"

// Rule to call the porechop program and save the output in files
process porechopABIcall {
    input:
    file reads_file
    output:
    file("PorechopABI/Output_reads.fastq"),
    file("reports/Statistics.txt")
    script:
    """
    porechop_abi -i ${reads_file} -o PorechopABI/Output_reads.fastq --stats > reports/Statistics.txt 2>&1
    """
    conda:
    "envs/porechop_abi.yaml"
}

// Rule to trim the reads using Prowler and save the output
process ProwlerTrim {
    input:
    file trimmer_script,
    file("PorechopABI/Output_reads.fastq") 
    output:
    directory("ProwlerProcessed") 
    script:
    """
    python3 ${trimmer_script} -f PorechopABI/Output_reads.fastq -i PorechopABI/ -o ProwlerProcessed/ -m D -r .fasta
    """
}

// Rule to use the SACRA reads
process SACRAcall {
    input:
    file sacra_script,
    file sacra_config,
    file("ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta")
    output:
    file("SACRAResults/sacra_results.fasta")
    script:
    """
    ${sacra_script} -i ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta -o SACRAResults/sacra_results.fasta -t 6 -c ${sacra_config}
    """
    conda:
    "envs/sacra.yaml"
}

// Get the output from the terminal into an html file which can be used to generate the report.
process StatisticsToHTML {
    input:
    file("reports/Statistics.txt"),
    file("PorechopABI/Output_reads.fastq"),
    file("ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta")
    output:
    file("reports/Results.html")
    script:
    """
    ${params.report_generator} -i reports/Statistics.txt -r PorechopABI/Output_reads.fastq -t ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta -o reports/Results.html
    """
}

// Rule to get all the output files and save
workflow {
    main_output = [file("reports/Statistics.txt"), directory("ProwlerProcessed"), file("SACRAResults/sacra_results.fasta")]

    // define input
    input_reads = file(params.reads_file)

    // execute rules
    porechop_out, stats_out = porechopABIcall(input_reads)
    prowler_out = ProwlerTrim(params.trimmer_script, porechop_out)
    sacra_out = SACRAcall(params.sacra_script, params.sacra_config, prowler_out)
