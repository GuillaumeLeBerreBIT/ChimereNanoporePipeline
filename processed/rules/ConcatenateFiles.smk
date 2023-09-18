#################### MODULES ####################
import os, glob

################# CONCAT FILES ####################
# Combining all fasta files after SACRA in to one big file. 
# Can experiment with this may not even have to wait, extra security check

rule ConcatFiles:
    input: 
        expand(
            os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}/{file}SacraResults.fasta"), 
            file = FILES)

    output: 
        os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}Concattedfiles.fasta")
    conda:
        "envs/pythonChimereWorkflow.yaml"
    params:
        fileSacra = os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}/{FIRST_FILE}SacraResults.fasta")
    threads: 
        4
    shell: 
        """
        python3 scripts/ConcatFiles.py {params.fileSacra} {output} 
        """