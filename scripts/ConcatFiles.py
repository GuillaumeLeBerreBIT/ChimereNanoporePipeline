#!/usr/bin/python3
#####################################################################
# Concatenate files togheter
#####################################################################
# MODULES
#####################################################################
import os, argparse

#####################################################################
# COMMAND LINE INPUT
#####################################################################
parser = argparse.ArgumentParser(description='Concatenate files')                                                         
parser.add_argument('inputFolFil', type=str, 
                    help='Provide the folder containing all the fastq files to be concatenated.')
parser.add_argument('outputFile', type=str, 
                    help='Give a (path to and) name to call the outputfile.')
parser.add_argument('targetFile', type=str, 
                    help='Give a target File.')
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

flag = 0
# While the target file is not present keep looping until it is in the folder 
while flag == 0:
    # Changes when the target folder is in there
    if args.targetFile not in os.listdir(path_to_files):
        flag = 0
    else:
        flag = 1
# Open a file to write everything in to
with open(args.outputFile, "w") as file_to_write:
    # Get every file from the directory
    for filename in os.listdir(path_to_files):
        # Paste the path to file togheter with the filename
        file_path = os.path.join(path_to_files, filename)
        # True == File
        if os.path.isfile(file_path):
            with open(file_path, 'r') as file_to_read:
                file_lines = file_to_read.read()
                file_to_write.write(file_lines)
