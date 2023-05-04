#!/usr/bin/python3

#######################################
# MODULES
#######################################
import os, argparse, re
from Bio import SeqIO   # pip install biopython
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt     # pip install matplotlib


#######################################
# COMMAND LINE INPUT
#######################################

parser = argparse.ArgumentParser(description='Generate report')                                                         
parser.add_argument('prowlerFasta', type=str, help='Give the Fasta file generated by Prowler Trimmer.')
parser.add_argument('sacraChimere', type=str, help='Give the Fasta file containing the Chimeric reads split.')
parser.add_argument('sacraNonChimere', type=str, help='Give the Fasta file containing the non Chimere reads.')
args = parser.parse_args()

#######################################
# HANDLING FILE - INFORMATION
#######################################
# Defining empty lists beforehand
prow_records = []
chim_records = []
nonchim_records = []

### PROWLER SEQUENCES
# Reading in the Prowler Fasta file
for seq_record in SeqIO.parse(args.prowlerFasta, "fasta"):
    # Append each record to a list
    prow_records.append(seq_record.id)
# Counting the number of IDs == Number of sequences
count_prow = len([record for record in prow_records])

### CHIMERA SEQUENCES
# Reading in the Fasta file with Chimere sequences
for seq_record in SeqIO.parse(args.sacraChimere, "fasta"):
    # Append each record to a list
    chim_records.append(seq_record.id)
# Counting the number of IDs == Number of sequences
count_chim = len([record for record in chim_records])

### UNIQUE CHIMERA SEQUENCE ID
# Will try to count and see how many reads had one/multiple chimera reads
# Setting empty list beforehand
record_splitted = []
#Iterating over the already collected chimera sequence records
for chim in chim_records:
    # Split since each record hase the sequence pos start and end included.
    chim_splitted = chim.split(":")
    # Only retain the chimeric sequence IDs
    record_splitted.append(chim_splitted[0])
# Set an empty set to start
unique_chim = set()
# Iterate over the sequence IDs
for i in record_splitted:
    # Add to a set of IDs
    unique_chim.add(i)
# Counting the number of IDs == Number of UNIQUE sequences
count_unique_chim = len([record for record in unique_chim])

### NON CHIMERA SEQUENCES
# Reading in the Prowler Fasta file with Non Chimere reads
for seq_record in SeqIO.parse(args.sacraNonChimere, "fasta"):
    nonchim_records.append(seq_record.id)
# Counting the number of IDs == Number of reads
count_nonchim = len([record for record in nonchim_records])

print(f"Reads after Prowler: {count_prow}\
      \nHow many chimera sequences: {count_chim}\
      \nHow many from original unique reads: {count_unique_chim}\
      \nHow many non chimera sequences: {count_nonchim}\
      \nSum chimera unique IDs & non chimera IDs: {(total_sacra_seq := count_unique_chim + count_nonchim)}")

#######################################
# VISUALIZATION
#######################################






"""
labels = ["Reads after Prowler", "Chimere Reads", "Non-Chimere Reads"]
total_reads = [count_prow, count_chim, count_nonchim]

# Setting the margins
fig, ax = plt.subplots(figsize =(16, 9))
 
# Creating the horizontal bar plot
sns.barplot(x=total_reads, y=labels, ax=ax, palette="Blues_r")
#ax.barh(labels, total_reads)

# Add padding between axes and labels
ax.xaxis.set_tick_params(pad = 5)
ax.yaxis.set_tick_params(pad = 10)

# Adding the axis labels on to it. 
ax.set_xlabel("No. of Reads")
ax.set_title("No. of Reads before and after removing Chimere sequences")

# Adding the values on top of the barchart. 
for i, v in enumerate(total_reads):
    ax.text(v + 100, i, str(v), color='gray', fontweight='bold')


# Saving the picture 
plt.savefig("reports/SACRA-Results.png", dpi=200)

#Showing the plot
plt.show()
"""