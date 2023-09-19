#################### MODULES ####################
import os, glob

################# STATISTICS TO HTML ####################
# Combining all different files used to generate a general report file.
# Done by a pathon script that will read in files from certain folders.   
rule StatisticsToHTML:
    input: 
        sacraF = os.path.join(DATA_DIR, "{META_DIR}/SACRAResults/{SAMPLE}SacraResultsFiltered.fasta"),
        Diamond = expand(
            os.path.join(DATA_DIR, "{META_DIR}/Diamond/{SAMPLE}/{SAMPLE}Diamond_{GENE}.csv"), 
            SAMPLE = SAMPLE, META_DIR = META_DIR, GENE = GENES
            ),
        assem = expand(
            os.path.join(DATA_DIR, "{META_DIR}/AssemblyFasta/{SAMPLE}FastaForAssembly.fasta"), 
            SAMPLE = SAMPLE, META_DIR = META_DIR
            ),
        MitosFasta = os.path.join(DATA_DIR, "{META_DIR}/MITOS2Results/{SAMPLE}/0/result.faa"),
        BandageAssem = os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}BANDAGE-SPAdesAssembly.jpg")
        
    output: 
        os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}Results.html")
    conda:
        "../envs/pythonChimereWorkflow.yaml"
    params:
        # Set the folders as parameters to give on the command line
        poreStat = os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/PorechopABI/"),
        poreFastq = os.path.join(DATA_DIR, "{META_DIR}/PorechopABI/{SAMPLE}/"),
        prowFold = os.path.join(DATA_DIR, "{META_DIR}/ProwlerProcessed/{SAMPLE}/"),
        mitosFold = os.path.join(DATA_DIR, "{META_DIR}/MITOS2Results/{SAMPLE}/")
    threads: 
        4
    shell: 
        """
        python3 scripts/StatisticalReportGenerator.py {output} {params.poreStat} {params.poreFastq} {params.prowFold} {input.sacraF} {input.BandageAssem} {params.mitosFold} 
        """