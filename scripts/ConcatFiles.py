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
parser.add_argument('inputFolder', type=str, 
                    help='Provide the folder containing all the fastq files to be concatenated.')
parser.add_argument('outputFile', type=str, 
                    help='Give a (path to and) name to call the outputfile.')
args = parser.parse_args()
#####################################################################
# FILE HANDLING
#####################################################################

with open(args.outputFile, "w") as file_to_write:
    
    for filename in os.listdir(args.inputFolder):
        
        file_path = os.path.join(args.inputFolder, filename)

        if os.path.isfile(file_path):
            with open(file_path, 'r') as file_to_read:
                file_lines = file_to_read.read()
                file_to_write.write(file_lines)