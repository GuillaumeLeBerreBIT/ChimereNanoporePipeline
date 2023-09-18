#!/usr/bin/python3
#####################################################################
# DiamondToAssembly
#####################################################################
# MODULES
#####################################################################
import os, re, argparse
#####################################################################
# COMMAND LINE INPUT
#####################################################################
parser = argparse.ArgumentParser(description='Generate report')
parser.add_argument('MITOS2Folder', type=str, 
                    help='Give the folder with the MITOS2 output')                       
parser.add_argument('outputFile', type=str, 
                    help='Give the name of the file that will contain the output.')
args = parser.parse_args()
#####################################################################
# FILE HANDLING
#####################################################################
# Filter the list to open files in numerical order. 
list_folders = os.listdir(args.MITOS2Folder)
list_folders.sort()
# Open the file to write to beforehand. 
file_to_write = open(args.outputFile, "w")
# Need to specify the full path to find the specific folder
for folder in list_folders:
    #print(f"{folder}")
    # Have to give the full path with it to find the folder
    for file in os.listdir(f"{args.MITOS2Folder}/{folder}/"):
        ## GFF
        if re.search("result.gff",file):
            
            with open(f"{args.MITOS2Folder}/{folder}/{file}", "r") as file_to_read:
                # Create a list of lines from the file
                file_lines = file_to_read.readlines()
                # The title by getting the contig name
                splitted_item = file_lines[0].split("\t")
                contig_raw = splitted_item[0]
                # Edit word
                contig_list = contig_raw.split("_")
                # Write title == Contig 
                file_to_write.write(f"<h3>{contig_list[0].capitalize()} {contig_list[1]}</h3>\n")
                # Write the table header to the file
                file_to_write.write("<table>\n\t<tr>\n\t\t<th>Source</th>\n\t\t<th>Feature</th>\n\t\t<th>Start position</th>\n\t\t<th>End position</th>\n\t\t<th>Score</th>\n\t\t<th>Strand</th>\n\t\t<th>Frame</th>\n\t\t<th>Attributes</th>\n\t</tr>\n")
                # Iterate over the lines from the list
                for line in file_lines:
                    # The columns are tab seperated o split on
                    splitted_gff = line.split("\t")
                    # 1) seqname - name of the chromosome or scaffold
                    # 2) source - name of the data source 
                    # 3) feature - feature type 
                    # 4) start - Start position
                    # 5) end - End position
                    # 6) score - A floating point value.
                    # 7) strand - defined as + (forward) or - (reverse).
                    # 8) frame - One of '0', '1' or '2'. '0' indicates that the first base of the feature is the first base of a codon, '1' that the second base is the first base of a codon, and so on..
                    # 9) attribute - A semicolon-separated list of tag-value pairs, providing additional information about each feature.
                    #print(splitted_gff)
                    # Parse everything to a table in the file. 
                    file_to_write.write(f"\t<tr>\n\t\t<td>{splitted_gff[1]}</td>\n\t\t<td>{splitted_gff[2]}</td>\n\t\t<td>{splitted_gff[3]}</td>\n\t\t<td>{splitted_gff[4]}</td>\n\t\t<td>{splitted_gff[5]}</td>\n\t\t<td>{splitted_gff[6]}</td>\n\t\t<td>{splitted_gff[7]}</td>\n\t\t<td>{splitted_gff[8].strip()}</td>\n\t</tr>\n")
                file_to_write.write("</table>\n")
            file_to_read.close()

        ## FASTA   
        # Only open the file name that matches -- > Will be always the same
        if re.search("result.fas", file):
            # Open the file to read from
            with open(f"{args.MITOS2Folder}/{folder}/{file}", "r") as file_to_read:
                # Get the lines of a file split on newline in a list. 
                file_lines = file_to_read.readlines()
                #Set a counter for each file to handle
                count = 0
                
                for line in file_lines:
                    count += 1
                    # To write the first div
                    if re.search("^>", line) and count == 1:
                        file_to_write.write(f"\t<div>\n\t\t{line}\n\t</div>\n\t<pre>\n")
                    # To write the divs except first and last
                    elif re.search("^>", line) and count != 1:
                        file_to_write.write(f"\t</pre>\n\t<div>\n\t\t{line}\n\t</div>\n\t<pre>\n")
                    # Write the sequence lines
                    elif re.search("^[A,G,C,T,U]", line):
                        # Tab in pre statement will directly visualized. 
                        file_to_write.write(f"\t{line}")
                
                # To write the last div block
                if count == len(file_lines):
                    file_to_write.write(f"\t</pre>\n")
            # Close file
            file_to_read.close()
#Close the file
file_to_write.close()
        
