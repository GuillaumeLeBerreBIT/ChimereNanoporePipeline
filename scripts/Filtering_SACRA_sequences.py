#!/usr/bin/python3
#######################################
# MODULES
#######################################

import re, os, argparse, webbrowser, time
from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio import SeqIO   # pip install biopython
#import numpy as np      # pip install numpy
#import matplotlib.pyplot as plt     # pip install matplotlib

#######################################
# COMMAND LINE INPUT
#######################################

parser = argparse.ArgumentParser(description='Generate report')                                                         
parser.add_argument('inputFile', type=str, 
                    help='Give the input fasta file to filter the legth of the reads on. Can parse the path of file with it.')
parser.add_argument('outputFile', type=str, 
                    help='Give an output fasta file name to write to. Can parse the path of file with it.')
parser.add_argument('-b', '--bases', type=int, default = 50, required = False, 
                    help ='Give a number of bases want to have as minimum treshold to filter on.')
args = parser.parse_args()

#######################################
# FILE HANDLING
#######################################

# GHATHERING ALL IDS ABOVE X NT
list_wanted_records = []
# Setting a counter
counter_1 = 0
# Readigng in the input file 
for seq_record in SeqIO.parse(args.inputFile, "fasta"):
    # Filter on the length of the amount of bases smaller then X, default 50
    if len(seq_record) < args.bases:
        continue

    # Filter on the length of the amount of bases bigger then X, default 50
    elif len(seq_record) >= args.bases:
        # The records do not have the starting ">", so add it here so the parsing can be done much easier. 
        # Will have == >@9030c343-3ff2-4b66-ab1b-c1e3327c3de0:1-188
        list_wanted_records.append(">" + seq_record.id)
        counter_1 += 1 

# HANDLING THE FILE
# Opening a file to write to
with open(args.outputFile, "w") as file_to_write:
    # Opening a file to read to
    with open(args.inputFile, "r") as file_to_read:
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
                if iso_header in list_wanted_records:
                    counter_2 += 1
                    flag = 1
                # If the header is not in the list then set flag to 0 == not write
                elif iso_header not in list_wanted_records:
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
print(f"File readed through Biopython: {counter_1}\
      \nFile handled for checking matching lines (manually): {counter_2}\
      \nLines printed {counter_3}\
      \nLines skipped {counter_4}")
