

configfile: "../config/MyConfig.yaml"

SEQ_DIR = config["sequencedata"]
DATA_DIR = config["datafolder"]
META_DIR = config["projectMetadata"]
SAMPLE = config["sample"]
GENES = ["ATP6","ATP8","COX1","COX2","COX3","CYTB","NAD1", "NAD2","NAD3","NAD4","NAD4L","NAD5","NAD6"]


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
FASTQPATH = os.path.join(DATA_DIR, SEQ_DIR) + "/"

FASTQFOL = os.listdir(FASTQPATH)

# Empty list to save file names
FILES = []
# Iterate over the folder to get all the file names and remove the extension for global use. FASTQ > FASTA
for fastq in FASTQFOL:
    stripped_fastq = fastq.replace(".fastq", "")
    FILES.append(stripped_fastq)

FIRST_FILE = FILES[0]

if config["MinION"]["Workflow"] == "LowComputational":
    include:
        "workflow/LowComputational.smk"
    rule all:
        input:
            expand(
                [
                    os.path.join(DATA_DIR, f"{META_DIR}/SACRAResults/{SAMPLE}/{i}SacraResults.fasta"),
                    os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}Results.html")
                ],
                SAMPLE = SAMPLE, i = FILES, META_DIR = META_DIR
            )
            
elif config["MinION"]["Workflow"] == "HighComputational":
    include:
        "workflows/HighComputational.smk"
    rule all:
        input:
            expand(
                [
                    os.path.join(DATA_DIR, f"{META_DIR}/SACRAResults/{SAMPLE}/{i}SacraResults.fasta"),
                    os.path.join(DATA_DIR, "{META_DIR}/results/{SAMPLE}/{SAMPLE}Results.html")
                ],
                SAMPLE = SAMPLE, i = FILES, META_DIR = META_DIR
            )
else:
    raise Exception("Unknown workflow option: %s" % config["MinION"]["Workflow"])
