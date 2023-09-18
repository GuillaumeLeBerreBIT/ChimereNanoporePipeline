#!/usr/bin/python3
############################# INTRODUCTION #############################
# Author: Guillaume Le Berre
# GitHub: https://github.com/GuillaumeLeBerreBIT
# 
# Remove the @ from header sequences. Using Flye it conlficted to have @ in the header present. 
# The same problem occured using samtools, since it thinks it is a SAM-header. 
#################################### MODULES ####################################
import argparse, re

#################################### COMMAND LINE INPUT ####################################
parser = argparse.ArgumentParser(description='Remove @ from headers - Nanopore data')                                                         
parser.add_argument('inputFile', type=str, 
                    help='Provide the input file to remove @ from the headers. Due to complications parsing to samtools/Flye. ')
parser.add_argument('outputFile', type=str, 
                    help='Give a (path to and) name to call the outputfile.')
#parser.add_argument('targetNum', type=int, 
#                    help='Give a target File.')
args = parser.parse_args()

#################################### FILE HANDLING ####################################

with open(args.outputFile, "w") as file_to_write:
    with open(args.inputFile, "r") as file_to_read:
        file_lines = file_to_read.readlines()

        for line in file_lines:
            if re.search("@", line):
                removed_at = line.replace("@", "")
                file_to_write.writelines(removed_at)
            else:
                file_to_write.writelines(line)
    file_to_read.close()
file_to_write.close()