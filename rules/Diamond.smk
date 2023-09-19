#################### MODULES ####################
import os, glob

################# DIAMOND ####################
# DIAMOND will be used to BLASTX the fasta file against the mitochondriol genes, split up into 13 databases.
# It will generate the output in a folder containing 13 csv files, each containing the BLASTX results against one of the genes. 
# Received an error that 'Wildcards in input files cannot be determined from output files:'META_DIR'' 
# >> Had to set the expand function in the Input rule as well as the Output already was.
rule DiamondAlignment:
    input: 
        expand(
            os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}SacraResultsFiltered.fasta"),
            META_DIR = META_DIR, SAMPLE = SAMPLE
        )
    
    output: 
        expand(
            os.path.join(DATA_DIR, "{META_DIR}/Diamond/{SAMPLE}/{SAMPLE}Diamond_{GENES}.csv"), 
            GENES = GENES, SAMPLE = SAMPLE, META_DIR = META_DIR
        )
            
    conda:
        "../envs/diamond.yaml"
    params:
        k = config['Diamond']['max-target-seq'],
        f = config['Diamond']['output-format'],
        folder = config['sample']
    threads: 
        4
    shell: 
        """
        for db in ATP6 ATP8 COX1 COX2 COX3 CYTB NAD1 NAD2 NAD3 NAD4 NAD4L NAD5 NAD6; 
        do
            diamond blastx -d resources/DIAMOND-DB/"$db" -q {input} -k {params.k} -f {params.f} \
            -p 4 -o "Diamond/{params.folder}/{params.folder}Diamond_${db}.csv"
        done
        """
