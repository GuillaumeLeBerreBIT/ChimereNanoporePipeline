#################### MODULES ####################
import os, glob

################# CONCAT FILES ####################
# Combining all fasta files after SACRA in to one big file. 
# Can experiment with this may not even have to wait, extra security check

rule ConcatFiles:
    input: 
        expand(
            os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}/{file}SacraResults.fasta"), 
            file = FILES, META_DIR = META_DIR, SAMPLE = SAMPLE)



    output: 
        os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}Concattedfiles.fasta")
    conda:
        "../envs/pythonChimereWorkflow.yaml"
    params:
        fileSacra = expand(
            os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}/{FIRST_FILE}SacraResults.fasta"),
            META_DIR = META_DIR, SAMPLE = SAMPLE, FIRST_FILE = FIRST_FILE
            )
    threads: 
        4
    shell: 
        """
        python3 scripts/ConcatFiles.py {params.fileSacra} {output} 
        """