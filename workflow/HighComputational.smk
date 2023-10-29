################################# INTRODUCTION #################################
#
# The HighComputational workflow allows the user to run the pipeline on servers or big systems
# without encountering memory issues. 
#
################################# RULES #################################
include:
    "../rules/PreProcessingHigh.smk"
include:
    "../rules/Diamond.smk"
include:
    "../rules/FilterSACRAFile.smk"
include:
    "../rules/FilteringDiamond.smk"
include:
    "../rules/Remove@Headers.smk"
include:
    "../rules/SPAdesAssembly.smk"
include:
    "../rules/Bandage.smk"
include:
    "../rules/Mitos.smk"
include:
    "../rules/GenerateReport.smk"

################################# TARGET RULE #################################
rule Analysis:
    input:
        expand(
            [
                os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}Results.html")
            ],
            SAMPLE = SAMPLE, i = FILES, META_DIR = META_DIR
        )
    output:
        touch('MioIONProcessingAnalysis.done')