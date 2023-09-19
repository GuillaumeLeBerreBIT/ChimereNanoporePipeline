#################### MODULES ####################
import os, glob

################# FILTER SACRA ####################
# Makes use of a script to filter the fasta files based on the length of the reads, to only retain above certain treshold.

rule FilterFastaSACRA:
    input:
        os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}Concattedfiles.fasta")
    output:
        os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}SacraResultsFiltered.fasta")
    conda:
        "../envs/pythonChimereWorkflow.yaml"
    params:
        bases = config['filterSACRA']['bases']
    threads: 
        4
    shell:
        """
        python3 scripts/Filtering_SACRA_sequences.py -b {params.bases} {input} {output}
        """