

configfile: "configfile: "../config/config_snakemake.yaml""

SEQ_DIR = config["sequencedata"]
DATA_DIR = config["datafolder"]
META_DIR = config["projectMetadata"]
SAMPLE = config["sample"]
FIRST_FILE = FILES[0]

# Identifier == Retraceability & Reproduceability
identifier = config["identifier"]
# Select L to clip leading Ns, T to trim trialing Ns and LT to trim both (default=LT)
clip = config['prowler']['clip']
# The fragmetation mode default U0
fragments = config['prowler']['fragments']
# Set the trimming algorithm Static == "S" OR Dynamic == "D"
trimmode = config['prowler']['trimmode']
# Set the quality score trimming treshold.
qscore = config['prowler']['qscore']
# Change the size of the trimming window.
windowsize = config['prowler']['windowsize']
# The minimum acceptable numer of bases in a read
minlen = config['prowler']['minlen']
# Select a maximum data subsample in MB (default = 0, entire sample)
datamax = config['prowler']['datamax']

# Return a list of all files in the data folder. 
FASTQFOL = os.listdir(SEQ_DIR)

# Empty list to save file names
FILES = []
# Iterate over the folder to get all the file names and remove the extension for global use. FASTQ > FASTA
for fastq in FASTQFOL:
    stripped_fastq = fastq.replace(".fastq", "")
    FILES.append(stripped_fastq)

if config["MinION"]["Workflow"] == "LowComputational":
    include:
        "workflows/LowComputational.smk"
    rule all:
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
elif config["MinION"]["Workflow"] == "HighComputational":
    include:
        "workflows/HighComputational.smk"
    rule all:
        input:
            expand(
                [
                    os.path.join(DATA_DIR,"{project}/PathoFact_report/Toxin_prediction_{sample}_report.tsv"),
                    os.path.join(DATA_DIR,"{project}/PathoFact_report/Toxin_gene_library_{sample}_report.tsv"),
                    os.path.join(DATA_DIR,"{project}/logs/Tox_{sample}_compressed.zip")
                ],
                project=config["pathofact"]["project"], sample=config["pathofact"]["sample"]
            )
else:
    raise Exception("Unknown workflow option: %s" % config["pathofact"]["workflow"])

"""
    # This is to make sure everything for the last "FOR" loop is completed == TARGETS
    expand("SACRAResults/{identifier}/{i}SacraResults.fasta", identifier = identifier, i = FILES),
    # Set the actual target file == HTML REPORT
    f"../results/{identifier}/{identifier}Results.html"
"""