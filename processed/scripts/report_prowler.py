#!/usr/bin/python3
# Creating a report file to generate a report file after performing the ProwlerTrimming
# 1) Know the length of each read from Fastq & Fasta file
# 2) Genrate a plot with the reads
 
#!/usr/bin/python3
# Creating a report file to generate a report file after performing the ProwlerTrimming
# 1) Know the length of each read from Fastq & Fasta file
# 2) Genrate a histogram with the reads
 
#Importing needed modules
import os
import re
from Bio import SeqIO   # pip install biopython
import numpy as np
import matplotlib.pyplot as plt     # pip install matplotlib

# Print the current working directory
print(os.getcwd())

# Lists to store the read lengths before and after trimming
before_trim = []
after_trim = []

# Read the input fastq file and append the length of each read to before_trim
for seq_record in SeqIO.parse("../PorechopABI/Output_reads.fastq", "fastq"):
    before_trim.append(len(seq_record.seq))

# Read the trimmed fasta file and append the length of each read to after_trim
for seq_record in SeqIO.parse("../ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta", "fasta"):
    after_trim.append(len(seq_record.seq))

# Convert the read length lists to numpy arrays for plotting
before_array = np.array(before_trim)
after_array = np.array(after_trim)

# Create a figure with two subplots
fig, axs = plt.subplots(1, 2, tight_layout=True)

# Plot a histogram of read lengths before trimming
axs[0].hist(before_array, bins=30, range=[0,10000])
axs[0].set_title('Before trimming Reads')
axs[0].set_xlabel('Read length')
axs[0].set_ylabel('Frequency')

# Plot a histogram of read lengths after trimming
axs[1].hist(after_array, bins=30, range=[0,10000])
axs[1].set_title('After trimming Reads')
axs[1].set_xlabel('Read length')
axs[1].set_ylabel('Frequency')

# Saving the file before show
plt.savefig("../reports/Before&After-Prowler.png", dpi=200)

# Display the plot
#plt.show()

