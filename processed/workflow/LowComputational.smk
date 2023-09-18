include:
    "rules/PreProcessing.smk"
include:
    "rules/SACRA.smk"
include:
    "rules/ConcatenateFiles.smk"
include:
    "rules/FilterSACRAFile.smk"
include:
    "rules/FilteringDiamond.smk"
include:
    "rules/Remove@Headers.smk"
include:
    "rules/SPAdesAssembly.smk"
include:
    "rules/Bandage.smk"
include:
    "rules/Mitos.smk"
include:
    "rules/GenerateReport.smk"

rule Analysis:
    input:
        expand(
            [
                os.path.join(DATA_DIR,"{project}/PathoFact_intermediate/AMR/{sample}_AMR_MGE_prediction_detailed.tsv"),
                os.path.join(DATA_DIR,"{project}/PathoFact_report/Toxin_gene_library_{sample}_report.tsv"),
                os.path.join(DATA_DIR,"{project}/PathoFact_report/PathoFact_{sample}_predictions.tsv"),
                os.path.join(DATA_DIR,"{project}/logs/{sample}_compressed.zip")
            ],
                project=config["projectMetadata"], sample=config["sample"]
        )
    output:
        touch('MioIONProcessingAnalysis.done')