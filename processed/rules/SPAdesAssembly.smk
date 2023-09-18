#################### MODULES ####################
import os, glob

################# SPADES ####################
# For MDA data can add the --sc flag on the command line. 
rule SPAdes:
    input: 
        os.path.join(DATA_DIR, "{META_DIR}/AssemblyFasta/{SAMPLE}FastaForAssembly-@-Removed.fasta")
    output: 
        SPAdesFasta = os.path.join(DATA_DIR, "{META_DIR}/SPAdesResults/{SAMPLE}/contigs.fasta"),
        SPAdesGraph = os.path.join(DATA_DIR, "{META_DIR}/SPAdesResults/{SAMPLE}/assembly_graph.fastg")
    conda:
        "envs/SPAdes.yaml"
    params:
        # Define folders under params and not as output otherwise will get an error.
        SpadesFolder = os.path.join(DATA_DIR, "{META_DIR}/SPAdesResults/{SAMPLE}/")
    threads: 
        8
    shell:
        """
        spades.py --only-assembler -s {input} -o {params.SpadesFolder} -t 8
        """
