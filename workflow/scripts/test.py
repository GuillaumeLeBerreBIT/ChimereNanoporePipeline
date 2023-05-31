import os

inputfolder = "Cmaenas_minion_data"
# The files as input 
FASTQFOL = os.listdir(inputfolder)
FILES = []
# Iterate over the folder to get the extension removed
for fastq in FASTQFOL:
    stripped_fastq = fastq.replace(".fastq", "")
    splitted_file = stripped_fastq.split("_")
    FILES.append(splitted_file[3])
# Sort the list
FILES.sort()
print(FILES)