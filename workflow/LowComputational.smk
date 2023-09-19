include:
    "../rules/PreProcessing.smk"
include:
    "../rules/SACRA.smk"
include:
    "../rules/ConcatenateFiles.smk"
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

rule Analysis:
    input:
        expand(
            [
                os.path.join(DATA_DIR, f"{META_DIR}/SACRAResults/{SAMPLE}/{i}SacraResults.fasta"),
                os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}Results.html")
            ],
            SAMPLE = SAMPLE, i = FILES, META_DIR = META_DIR
        )
    output:
        touch('MioIONProcessingAnalysis.done')