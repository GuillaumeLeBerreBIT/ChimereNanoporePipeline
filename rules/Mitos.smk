#################### MODULES ####################
import os, glob

################# MITOS ####################
# This is a mitogenome annotator. Detecting the genes present in the addembly made by SPAdes.   
# Can define the output file in the rule without parsing it on the command line. Using params to give the folder on the command line.
# There were some conflicts with _JAVA_OPTIONS which got resolved by unset these. It works without if there is no JAVA version present, but when having Java (different verion) it  confilcts. 
rule MITOS:
    input: 
        os.path.join(DATA_DIR, "{META_DIR}/SPAdesResults/{SAMPLE}/contigs.fasta")
    output: 
        # Will define the output of the first folder since the amount of contigs is variable. 
        os.path.join(DATA_DIR, "{META_DIR}/MITOS2Results/{SAMPLE}/0/result.faa")
        
    conda:
        "../envs/mitos2.yaml"
    params:
        # Define folders under params and not as output otherwise will get an error.
        MitosFolder = "MITOS2Results/{SAMPLE}/",
        RefFolder = "resources/MITOS2-DB/",
        MitRefSeq = "refseq89m/",
        gencode = config["mitos2"]['gencode']

    threads: 
        4
    shell:
        """
        unset _JAVA_OPTIONS
        runmitos.py -i {input} -c {params.gencode} -r {params.MitRefSeq} -o {params.MitosFolder} --refdir {params.RefFolder}
        """