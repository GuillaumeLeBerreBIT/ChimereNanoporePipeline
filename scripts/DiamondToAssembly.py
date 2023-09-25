#!/usr/bin/python3
############################# INTRODUCTION #############################
# Author: Guillaume Le Berre
# GitHub: https://github.com/GuillaumeLeBerreBIT
# 
# DIAMOND to Assemvly
# 1) Will loop over the folders containing the blast results in csv format, tab seperated
# 2) Gather the matches per gene
# 3) Gather the seq in how many reads found  
# 4) Filter on 20 len, eval 10^-6, 70 percent identity (depending on the input variables)
# 5) Histogram -- > Of the read lengths
# 6) Create a final Fasta file for the assembly
#####################################################################
# MODULES
#####################################################################
import os, argparse, csv, re
from Bio import SeqIO   # pip install biopython
import matplotlib.pyplot as plt
import numpy as np

#####################################################################
# COMMAND LINE INPUT
#####################################################################
parser = argparse.ArgumentParser(description='From DIAMOND to Assembly')
parser.add_argument('inputFolder', type=str, 
                    help='Give the (path to and) name of the folder containing the files after DIAMOND.')
parser.add_argument('sacraFiltered', type=str, 
                    help='Give the Fasta file containing the filtered reads on a certain threshold.')
parser.add_argument('outputAssembly', type=str, 
                    help='Give the (path to and) name for the fasta file with the output reads after filtering and DIAMOND mathces with DB.')
parser.add_argument('-i', '--identity', type=int, default = 70, required = False, 
                    help ='Give a number of the percentage identity as the minimum treshold.')
parser.add_argument('-l', '--len', type=int, default = 20, required = False, 
                    help ='Give a number of the min length of residues want to set as minimum treshold.')
# Will later convert it to a float -- > YAML sets it as an string
parser.add_argument('-e', '--evalue', type=str, default = 10e-6, required = False, 
                    help ='Give the minimum value to filter the sequences from DIAMOND.')
args = parser.parse_args()

#####################################################################
# FILE HANDLING
#####################################################################
# VARIABLES & LISTS (set before loop or will reset on each new file)
# Will create a list with all the headers validated by the filter parameters
filtered_list = []
# Need a list with all the crab families to match on 
crab_genus = ["Carcinus", "Charybdis", "Thalamita"]
# Testing for the Enoplea class >> Halalaimus
enoplea = ["Eucoleus","Longidorus","Trichinella", "Trichuris"]
# Testing for the Chromadorea class >> Acantholaimus & Desmoscolex
chromadorea = ["Gnathostoma", "Rhigonema", "Strongyloides", "Camallanus", "Meloidogyne"]
# Empty dictionary to save the amount of matches per gene
gene_matches = {}
# Empty dictionary for saving the headers
sequence_count = {} 

# The pipeline starts from the ChimereNanoporePipeline/ 
# Adding the folder containing the files after Diamond
# Do check if the user gave the slash with it at the end as well or not
if args.inputFolder[-1] == '/':    
    diamond_folder = args.inputFolder 
else:
    diamond_folder = args.inputFolder + "/"
# Using the unique identifier as name
splitted_folder = diamond_folder.split('/')
identifier = splitted_folder[-2]
project_folder = splitted_folder[-4]


# Get each file from the list (13 files) and open each one of them to read its content. 
for file in os.listdir(diamond_folder):
    #Split the file name to get the gene name extracted >> Splitting will return a list
    splitted_gene = file.split("_")
    # Saving the gene name and then removing the .csv
    # Taking the last item from the list, since it can vary depending on name given.
    gene_name = splitted_gene[-1].replace(".csv","")
    # Want to for each gene a starting value of 0
    if gene_name not in gene_matches:
        gene_matches[gene_name] = 0
    else:
        continue

    # Link each file again with the full path to open it
    file_to_open = diamond_folder + file
        
    # Can open each csv file
    with open(file_to_open, "r") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter='\t')
        # Each line from the csv file be returned as list
        # 0.  qseqid      query or source (gene) sequence id <-- 
        # 1.  sseqid      subject or target (reference genome) sequence id <-- 
        # 2.  pident      percentage of identical positions <--
        # 3.  length      alignment length (sequence overlap) <--
        # 4.  mismatch    number of mismatches
        # 5.  gapopen     number of gap openings
        # 6.  qstart      start of alignment in query
        # 7.  qend        end of alignment in query
        # 8.  sstart      start of alignment in subject
        # 9.  send        end of alignment in subject
        # 10.  evalue      expect value <--
        # 11.  bitscore    bit score
        for row in csv_reader:
            """
            print(f"Sequence ID: {row[0]}\
                  \nTarget Species_Gene: {row[1]}\
                  \nPercentage Identical positions: {row[2]}\
                  \nAlignement length: {row[3]}\
                  \nE-value: {row[10]}")
            """
            #################
            # FILTER 
            #################
            # First item of each row is the header name 
            header = row[0]
            # Need to split the sseqid to match on the Crab genus names
            splitted_genus = row[1].split("_")
            genus_name = splitted_genus[0]   
            gene = splitted_genus[2]
            
            # The float will function in the same way as the integers and can now compare numbers
            # Convert str -- > float/int
            # args.identity == Percentage Identity
            # args.len == Min length of residues 
            # args.evalue == Max e-value a sequence can have as treshold
            if float(row[2]) >= args.identity and\
                int(row[3]) >= args.len and\
                float(row[10]) <= float(args.evalue) and\
                genus_name in enoplea:
                
                # Get all the headers that match the set filters
                # The headers that will be used to create FASTA file for assembly 
                # Add a '>' since the fasta files start with a '>' 
                filtered_list.append('>' + header)
                # For each matching gene name increase the value with 1
                gene_matches[gene] += 1
                # Dictionary for all headers, to see if reads are found in multiple genes or not 
                if header not in sequence_count:
                    sequence_count[header] = 1
                else:
                    sequence_count[header] += 1


# Need to know as well how many hits were not matched after the BLAST
# Rearead the input file from DIAMIND and loop over the headers to check if they are in the dictionary or not.  
# If they are not in the dictionary set to a value of 0   
for seq_record in SeqIO.parse(args.sacraFiltered, "fasta"):
    if seq_record.id not in sequence_count:
        sequence_count[seq_record.id] = 0

# Now need to reverse the logic and count the frequencys of dictionary per header.
# Then can see how much a sequence has not been matched or has been matched after BLASTING against 
# the genes from the database. 
header_freq = {}
for val in sequence_count.values():
    if val not in header_freq:
        header_freq[val] = 0
    else:
        header_freq[val] += 1

# Header list with all IDs            
#print(filtered_list)
# Hits per gene
#print(gene_matches)
# The count of how many times a read seen per hit 
#print(sequence_count)
# Can check now the freq of how much a header has been found in a dictionary
#print(header_freq)

#####################################################################
# WRITE TO FASTA
#####################################################################
# HANDLING THE FILE
# Opening a file to write to
with open(args.outputAssembly, "w") as file_to_write:
    # Opening a file to read to
    with open(args.sacraFiltered, "r") as file_to_read:
        # This will create a list based on the newlines, containing strings
        reading_lines = file_to_read.readlines()
        # Setting a counter
        counter_2 = 0
        counter_3 = 0
        counter_4 = 0
        # Setting a flag
        flag = 0 
        # Iterating over the lines in the list
        for line in reading_lines:
            
            # Check for header lines/ record IDs
            if re.search("^>", line):
                # Only want to retain the beginning of the line, this will be the only identical part of the line
                # Split on spaces
                splitted_header = line.split(" ")
                # Retain the ID:START-END == >@9030c343-3ff2-4b66-ab1b-c1e3327c3de0:1-188
                iso_header = splitted_header[0]
                # If the header is in the list set the flag to 1 == to write
                if iso_header in filtered_list:
                    counter_2 += 1
                    flag = 1
                # If the header is not in the list then set flag to 0 == not write
                elif iso_header not in filtered_list:
                    flag = 0

            # This flag will allow ot print the lines to a file
            if flag == 1:
                file_to_write.writelines(line)
                counter_3 += 1
            # When flag is 0 it will skip the lines. 
            elif flag == 0:
                counter_4 += 1
                continue
# Closing the files for good practice
    file_to_read.close()
file_to_write.close()

# To get information out the parsed reads.
"""
print(f"File handled for checking matching lines (manually): {counter_2}\
      \nLines printed {counter_3}\
      \nLines skipped {counter_4}")
"""
#####################################################################
# VISUALIZATION
#####################################################################
# Have a predefined width so the x-axis is more spread out
plt.figure(figsize=(10,5))
# PLOT HITS PER GENE
bar_colors = ['tab:red','tab:blue','tab:brown','tab:orange','tab:green','tab:purple','tab:cyan','tab:olive','tab:pink','yellow', 'forestgreen','darkred','khaki']
# The x-axis values from the dictionary plotted  per tick
plt.bar(range(len(gene_matches)), gene_matches.values(), align='center', color=bar_colors)
# The x-axis labels from the dictionary plotted 
plt.xticks(range(len(gene_matches)), gene_matches.keys())
# x-axis label
plt.xlabel('Genes')
# y-axis label
plt.ylabel('No. of hits')
# Title for the plot
plt.title('DIAMOND BLAST Results')
plt.savefig(f"{project_folder}/results/{identifier}/{identifier}Bar-HitsPerGene-DIAMOND&Filtering.png", dpi=200, bbox_inches='tight')
# Close the plot
plt.clf()

# REPORT HOW MANY TIMES HEADER BEEN MATCHED
with open(f"{project_folder}/results/{identifier}/{identifier}HeaderCountDIAMOND.txt","w") as tmp_to_write:
    for key, val in header_freq.items():
        tmp_to_write.writelines(f"For the headers found {key} time(s) after DIAMOND: {val} sequences.\n")

# HISTOGRAM LEN OF THE READS
assembly_seq_len = []
for seq_record in SeqIO.parse(args.outputAssembly, "fasta"):
    assembly_seq_len.append(len(seq_record))

# Convert the read length lists to numpy arrays for plotting
assembly_array = np.array(assembly_seq_len)

# Set a predefined picture size to save in format 
plt.figure(figsize=(7,5))
# Plot a histogram of sequence lengths after DIAMOND & Filtering BLAST matches
# Setting amount of bins & range of the graph. 
plt.hist(assembly_array, bins = 40, range = [min(assembly_array), 1000])
# Setting title, x and y labels. 
plt.title('Length of sequences after DIAMOND & Filtering')
plt.xlabel('Sequence length')
plt.ylabel('Frequency')
# Determining to show the interval of x-axis ticks. 
plt.xticks(np.arange(0, 1000, 100))
plt.savefig(f"{project_folder}/results/{identifier}/{identifier}Hist-SequenceLengthAfterDIAMOND&Filtering.png", dpi=200, bbox_inches='tight')
# Savefig does not close the plot. 
plt.clf()