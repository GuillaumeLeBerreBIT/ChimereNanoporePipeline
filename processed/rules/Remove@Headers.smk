#################### MODULES ####################
import os, glob

################# REMOVE@HEADERS ####################
# The headers of sequences have @ at the start. Flye will think these are all header lines from SAM file. 
# By removing them Flye will parse the sequences. This file can be used for mapping then as well due to SAMTOOLS could not parse the files of the same reason. 
rule EditingHeaders:
    input: 
        os.path.join(DATA_DIR, "{META_DIR}/AssemblyFasta/{SAMPLE}FastaForAssembly.fasta")
    output: 
        os.path.join(DATA_DIR, "{META_DIR}/AssemblyFasta/{SAMPLE}FastaForAssembly-@-Removed.fasta")
    conda:
        "envs/pythonChimereWorkflow.yaml"
    threads: 
        4
    shell:
        """
        python3 scripts/Remove@FromHeaders.py {input} {output}
        """