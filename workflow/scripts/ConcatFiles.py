#!/usr/bin/python3
#####################################################################
# Concatenate multiple files togheter
#####################################################################
# MODULES
#####################################################################
import os, argparse, re

#####################################################################
# COMMAND LINE INPUT
#####################################################################
parser = argparse.ArgumentParser(description='Concatenate files')                                                         
parser.add_argument('inputFolFil', type=str, 
                    help='Provide the folder containing all the fastq files to be concatenated (or file of that folder).')
parser.add_argument('outputFile', type=str, 
                    help='Give a (path to and) name to call the outputfile.')
#parser.add_argument('targetNum', type=int, 
#                    help='Give a target File.')
args = parser.parse_args()

#####################################################################
# FILE HANDLING
#####################################################################
# Check wheter the path to the files is given OR a file from that folder
if os.path.isdir(args.inputFolFil):
    path_to_files = args.inputFolFil
else:
    # Splitting the file from the path
    splitted_path = os.path.split(args.inputFolFil)
    # Only use the path to move further
    path_to_files = splitted_path[0]

## Setting a flag to break/continue the loop
#flag = 0
## While the amount of total files is not present keep looping until all files are collected 
#while flag == 0:
#    # Changes when the folder of SACRA results has all files
#    if args.targetNum != len(os.listdir(path_to_files)):
#        flag = 0
#        #print(len(os.listdir(path_to_files)))
#    else:
#        # Loop breaks 
#        flag = 1

# Open a file to write everything in to
with open(args.outputFile, "w") as file_to_write:
    # Get every file from the directory
    for filename in os.listdir(path_to_files):
        
        if not re.search(".csv",filename) and\
        not re.search(".non_chimera.fasta",filename) and\
        not re.search(".split.fasta", filename):

            # Paste the path to file togheter with the filename
            file_path = os.path.join(path_to_files, filename)
            # True == File
            if os.path.isfile(file_path):
                with open(file_path, 'r') as file_to_read:
                    file_lines = file_to_read.read()
                    file_to_write.write(file_lines)
