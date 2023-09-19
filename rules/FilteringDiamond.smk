#################### MODULES ####################
import os, glob

################# FILTER DIAMOND ####################
# Having all the BLASTX results in a csv file, all gathered in a folder. The script will scan folder for all files being a csv file and extract the results. 
# In the config file can set up filters: ID percentage, Length of residues and e-value. 
# It will generate statistical figures & rewrite the BLAST hits to a new FASTA file for ASSEMBLY.  
rule FilteringDIAMOND:
    input: 
        Diamond = expand(
            os.path.join(DATA_DIR, "{META_DIR}/Diamond/{SAMPLE}/{SAMPLE}Diamond_{GENE}.csv"), 
            GENE = GENES, META_DIR = META_DIR, SAMPLE = SAMPLE
            )
    output: 
        os.path.join(DATA_DIR, "{META_DIR}/AssemblyFasta/{SAMPLE}FastaForAssembly.fasta")
    conda:
        "../envs/pythonChimereWorkflow.yaml"
    params:
        # Define folders under params and not as output otherwise will get an error.
        folder = config['sample'],
        idper = config['filtDIA']['idperc'],
        length = config['filtDIA']['len'],
        evalue = config['filtDIA']['eval'],
        sacraF = os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}SacraResultsFiltered.fasta")
    threads: 
        4
    shell:
        """
        python3 scripts/DiamondToAssembly.py -i {params.idper} -l {params.length} -e {params.evalue} Diamond/{params.folder} {params.sacraF} {output}
        """