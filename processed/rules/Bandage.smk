#################### MODULES ####################
import os, glob

################# BANDAGE ####################
# Flye generates different output files, summary of the assembly results. One of the files is a .gfa file. 
# BANDAGE can visualize the assemblys using the .gfa files. With a command line argument can save the image as png. 
rule BANDAGE:
    input: 
        os.path.join(DATA_DIR, "{META_DIR}/SPAdesResults/{SAMPLE}/assembly_graph.fastg")
    output:
        os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}BANDAGE-SPAdesAssembly.jpg")
    conda:
        "envs/bandage.yaml"
    threads: 
        4
    shell:
        """
        Bandage image {input} {output} --names --lengths --depth --fontsize 4
        """
