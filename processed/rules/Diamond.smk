#################### MODULES ####################
import os, glob

################# DIAMOND ####################
# DIAMOND will be used to BLASTX the fasta file against the mitochondriol genes, split up into 13 databases.
# It will generate the output in a folder containing 13 csv files, each containing the BLASTX results against one of the genes. 

rule DiamondAlignment:
    input: 
    os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}SacraResultsFiltered.fasta")
    
    output: 
        expand(
            os.path.join(DATA_DIR, "{META_DIR}/Diamond/{SAMPLE}/{SAMPLE}Diamond_{gene}.csv"), 
            gene = config["genes"]) 
            
    conda:
        "envs/diamond.yaml"
    params:
        k = config['Diamond']['max-target-seq'],
        f = config['Diamond']['output-format'],
        folder = config['identifier']
    threads: 
        4
    shell: 
        """
        for db in ATP6 ATP8 COX1 COX2 COX3 CYTB NAD1 NAD2 NAD3 NAD4 NAD4L NAD5 NAD6; 
        do
            diamond blastx -d../resources/DIAMOND-DB/"$db" -q {input} -k {params.k} -f {params.f} \
            -p 4 -o "Diamond/{params.folder}/${db}Diamond_{params.folder}.csv"
        done
        """

"""
rule DiamondAlignment:
    input: 
        sacraF = f"SACRAResults/{identifier}SacraResultsFiltered.fasta"
    output: 
        DiamondATP6 = f"Diamond/{identifier}/{identifier}Diamond_ATP6.csv",
        DiamondATP8 = f"Diamond/{identifier}/{identifier}Diamond_ATP8.csv",
        DiamondCOX1 = f"Diamond/{identifier}/{identifier}Diamond_COX1.csv",
        DiamondCOX2 = f"Diamond/{identifier}/{identifier}Diamond_COX2.csv",
        DiamondCOX3 = f"Diamond/{identifier}/{identifier}Diamond_COX3.csv",
        DiamondCYTB = f"Diamond/{identifier}/{identifier}Diamond_CYTB.csv",
        DiamondNAD1 = f"Diamond/{identifier}/{identifier}Diamond_NAD1.csv",
        DiamondNAD2 = f"Diamond/{identifier}/{identifier}Diamond_NAD2.csv",
        DiamondNAD3 = f"Diamond/{identifier}/{identifier}Diamond_NAD3.csv",
        DiamondNAD4 = f"Diamond/{identifier}/{identifier}Diamond_NAD4.csv",
        DiamondNAD4L = f"Diamond/{identifier}/{identifier}Diamond_NAD4L.csv",
        DiamondNAD5 = f"Diamond/{identifier}/{identifier}Diamond_NAD5.csv",
        DiamondNAD6 = f"Diamond/{identifier}/{identifier}Diamond_NAD6.csv"
    conda:
        "envs/diamond.yaml"
    params:
        k = config['Diamond']['max-target-seq'],
        f = config['Diamond']['output-format'],
        folder = config['identifier']
    threads: 
        4
    # Will create a folder with the identifier, since then only the resulst to a specific run belong to that folder. 
    # To generate statistical output its easier to handel the files in a  determined directory.  
    # Using """ Can all have different bash commands each executed on seperate line.
    # Do not have to set a "mkdir folder" since the path defined will automatically create a destined folder. 
    shell: 
        """
        diamond blastx -d ../resources/DIAMOND-DB/ATP6 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondATP6}
        diamond blastx -d ../resources/DIAMOND-DB/ATP8 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondATP8}
        diamond blastx -d ../resources/DIAMOND-DB/COX1 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondCOX1}
        diamond blastx -d ../resources/DIAMOND-DB/COX2 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondCOX2}
        diamond blastx -d ../resources/DIAMOND-DB/COX3 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondCOX3}
        diamond blastx -d ../resources/DIAMOND-DB/CYTB -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondCYTB}
        diamond blastx -d ../resources/DIAMOND-DB/NAD1 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD1}
        diamond blastx -d ../resources/DIAMOND-DB/NAD2 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD2}
        diamond blastx -d ../resources/DIAMOND-DB/NAD3 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD3}
        diamond blastx -d ../resources/DIAMOND-DB/NAD4 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD4}
        diamond blastx -d ../resources/DIAMOND-DB/NAD4L -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD4L}
        diamond blastx -d ../resources/DIAMOND-DB/NAD5 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD5}
        diamond blastx -d ../resources/DIAMOND-DB/NAD6 -q {input.sacraF} -k {params.k} -f {params.f} -p 4 -o {output.DiamondNAD6}
        """
"""

