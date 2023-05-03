#!/usr/bin/python3
# Creating a report file to generate a report file after performing the Porechop ABI

#Importing needed modules
import re, os, webbrowser, time
from Bio import SeqIO   # pip install biopython
import numpy as np
import matplotlib.pyplot as plt     # pip install matplotlib

# Change the path to the directory of the file
#os.chdir("../reports/")
print(os.getcwd())

#######################################
# HANDLING FILE
#######################################

# Opening the file from the current location 
with open("reports/Statistics.txt", "r") as text_file:
    #Splitting the lines of the file to get a list
    splitted_file = text_file.readlines()
    #print(splitted_file)

    # Setting up a flag
    flag = 0 
    # Adding an empty list to get the items
    statistics_list = []

    for line in splitted_file:
        # Setting up the different conditions to handle the wanted output
        if re.search("Trimming adapters from read ends", line):
            flag = 1
        elif re.search("adapters trimmed from their", line):
            flag = 2
        elif re.search("reads were split based on middle adapters", line):
            flag = 3
        # When encoutering a newline then set flag to 0 to nat add the output into a file.
        elif re.search("^\n", line):
            flag = 0

        #If any of the flags are set then will save the output in a list
        if flag == 1 or flag == 2 or flag == 3:
            print(line)
            stripped_line = line.strip()
            statistics_list.append(stripped_line)
            
    print(statistics_list)

    # Removing special characters
    cleaned_text_list = []

    for text in statistics_list:
        cleaned_text = re.sub(r'\x1b\[1m\x1b\[4m|\x1b\[0m|\x1b\[31m', '', text)
        
        if cleaned_text == '':
            continue
        else: 
            cleaned_text_list.append(cleaned_text)

    print(cleaned_text_list)      

#######################################
# GENERATING PROWLER REPORT
#######################################

# Lists to store the read lengths before and after trimming
before_trim = []
after_trim = []

# Read the input fastq file and append the length of each read to before_trim
for seq_record in SeqIO.parse("PorechopABI/Output_reads.fastq", "fastq"):
    before_trim.append(len(seq_record.seq))

# Read the trimmed fasta file and append the length of each read to after_trim
for seq_record in SeqIO.parse("ProwlerProcessed/Output_readsTrimLT-U0-D7W100L100R0.fasta", "fasta"):
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
plt.savefig("reports/Before&After-Prowler.png", dpi=200)


#######################################
# GENERATING HTML REPORT
#######################################

# Creating the header line
html_header = f"<html>\n<head>\n</head>\n<body>\n<h1>Statistical Report - Workflow</h1>\n<h2>Porechop ABI</h2>\n<h3>{cleaned_text_list[0]}</h3>\n"

# Creating the table containg everything

# The last 3 are summary lines from the adapters trimmed so can parse everything until then
unorder_list = []
unorder_list.append("<ul>\n")
for adapter in cleaned_text_list[1:-3]:

    unorder_list.append(f"\t<li>{adapter}</li>\n")
unorder_list.append("</ul>\n")
#print(unorder_list)
# Header adapter loc
adap_loc_header = "<h3>Adapters Removed</h3>\n"
# Adding the last summary lines from where the adapters are removed or not. 
adapter_loc_list = []
for adap_loc in cleaned_text_list[-3:]:

    adapter_loc_list.append(f"<div>\n\t{adap_loc}\n</div>\n")

# Adding the last line to the file
html_end = "</body>\n</html>"

with open("reports/Results.html", "w") as html_file:
    # Porechop ABI
    html_file.writelines(html_header)
    # Adapters
    for ul in unorder_list:
        html_file.writelines(ul)
    
    html_file.writelines(adap_loc_header)
    #Removed adapters
    for summary in adapter_loc_list:
        html_file.writelines(summary)
    # PROWLER
    html_file.writelines("<h2>Prowler Trimming</h2>\n")
    # Have to set the locatio from where the html file will be, so set picture in same folder
    html_file.writelines("\t<img src='Before&After-Prowler.png' height='800px'>\n")

    html_file.writelines(html_end)

# Does not work on the WSL ubuntu yet, could be because no browser installed on it
#time.sleep(2)
#webbrowser.open_new_tab("report.html")