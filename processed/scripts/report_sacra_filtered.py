#!/usr/bin/python3
#Importing needed modules
import os
import re
from Bio import SeqIO   # pip install biopython
import numpy as np
import matplotlib.pyplot as plt     # pip install matplotlib

# Lists to store the read lengths before and after trimming
filtered_sacra = []

# Read the input fastq file and append the length of each read to before_trim
for seq_record in SeqIO.parse("SACRAResults/fastq_runid_211SacraResultsFiltered.fasta", "fasta"):
    filtered_sacra.append(len(seq_record.seq))

# Convert the read length lists to numpy arrays for plotting
before_array = np.array(filtered_sacra)

# Plot a histogram with a predefined number of bins & a range set from x1 to x2.
plt.hist(before_array, bins=40, range=[0,1000])
# Setting the title
plt.title('After filtereing on No. of bases')
# X-axis label
plt.xlabel('Read length')
# Setting y-axis label
plt.ylabel('Frequency')
# Detrmining to show the interval of x-axis ticks. 
plt.xticks(np.arange(0, 1000, 100))
plt.show()