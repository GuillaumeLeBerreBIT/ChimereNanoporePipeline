#################### MODULES ####################
import os, glob

#################### SACRA ####################
# SACRA splits the chimeric reads to the non-chimeric reads in long reads of MDA-treated sample. 
# Make sure the path to the scripts folder is added onto the path, otherwise SACRA won't be able to find the subscripts. 
# This will be noticed as the output files will be empty & in the terminal says to the steps 3 & 4 command not found. 
# After running each rule unwanted files will be cleared == Memory efficiency. 
for i in FILES:    
    rule:
        input:
            os.path.join(DATA_DIR, f"{META_DIR}/ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta")
                
        output: 
            os.path.join(DATA_DIR, f"{META_DIR}/SACRAResults/{SAMPLE}/{i}SacraResults.fasta")

        conda:
            "envs/sacra.yaml"
        # Could be the values need to be restored or set the variables in the Snakefile
        params:
            blasttab = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.blasttab"),
            bck = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.bck"),
            des = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.des"),
            prj = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.prj"),
            sds = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.sds"),
            ssp = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.ssp"),
            suf = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.suf"),
            tis = os.path.join(DATA_DIR, f"ProwlerProcessed/{SAMPLE}/{i}PoreChopReadsTrim{clip}-{fragments}-{trimmode}{qscore}W{windowsize}L{minlen}R{datamax}.fasta.tis")
        threads:
            4

        shell: 
            """
            scripts/SACRA.sh -i {input} -p {output} -t 4 -c ../config/config_snakemake.yaml
            rm {params.blasttab}* {params.bck} {params.des} {params.prj} {params.sds} {params.ssp} {params.suf} {params.tis}
            """