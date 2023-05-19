#!/usr/bin/python3
# Creating a report file. 

#######################################
# MODULES
#######################################

import re, os, argparse, webbrowser, time
from Bio import SeqIO   # pip install biopython
import numpy as np      # pip install numpy
import matplotlib.pyplot as plt     # pip install matplotlib
import pandas as pd

#######################################
# COMMAND LINE INPUT
#######################################

parser = argparse.ArgumentParser(description='Generate report')
parser.add_argument('outputFile', type=str, 
                    help='Give the name of the file that will contain the output.')                       
parser.add_argument('porechopStat', type=str, 
                    help='Give the folder containing the Porechop Statistics files.')
parser.add_argument('porechopFastq', type=str, 
                    help='Give the Fastq file generated by Porechop ABI.')                                  
parser.add_argument('prowlerFolder', type=str, 
                    help='Give the Fasta file generated by Prowler Trimmer.')
parser.add_argument('sacraFiltered', type=str, 
                    help='Give the Fasta file containing the filtered reads on a certain threshold.')
args = parser.parse_args()

## PARSING UNIQUE IDENTIFIER
# Use the unique identifier per sample 
uniquelabel = args.outputFile
# Substitute the unwanted part by nothing >> using regular expression
# This will automatically create the specified == path-identifier/identifier...
# Will only take the base path and have the identifier once
identifier = re.sub("Results.html","",uniquelabel)
identifier = re.sub("reports/","",identifier)
identifier = os.path.basename(identifier)

#######################################
# HANDLING FILES
#######################################
# This section will contain each of the files used for statistical summary;
#######################################
# PORECHOP REPORT
#######################################
# Adding an empty list to get the items
statistics_list = []

# Go over all the files in the directory
for file in os.listdir(args.porechopStat):
    
    # Full filepath to the file
    file_path = f"{args.porechopStat}/{file}" 
    # Opening the file from the current location 
    with open(file_path, "r") as text_file:
        # Splitting the lines of the file to get a list of each newline
        splitted_file = text_file.readlines()

        # Setting up a flag
        flag = 0 

        for line in splitted_file:
            # Setting up the different conditions to handle the wanted output
            # When the re.search matches the pattern of a line it will return == True if not == False
            if re.search("Trimming adapters from read ends", line):
                flag = 1
            elif re.search("adapters trimmed from their", line):
                flag = 2
            elif re.search("reads were split based on middle adapters", line):
                flag = 3
            # When encoutering a newline flag == 0 == Not add the line to the list
            elif re.search("^\n", line):
                flag = 0

            # If any of the flags match the set value == save the output in a list
            if flag == 1 or flag == 2 or flag == 3:
                # print(line)
                # Removing leading or trailing characters
                stripped_line = line.strip()
                # Add each stripped line now to a file 
                statistics_list.append(stripped_line)     
        #print(statistics_list)

# Removing special characters from the lines
cleaned_text_list = []

for text in statistics_list:
    # If any of the patterns match in the item from lsit then replace it by nothing == Removing
    cleaned_text = re.sub(r'\x1b\[1m\x1b\[4m|\x1b\[0m|\x1b\[31m', '', text)
    # If the filtered item has nothing == Do nothing with it
    # Else keep it and add to a list 
    if cleaned_text == '':
        continue
    else: 
        cleaned_text_list.append(cleaned_text)   

### Adapters
# Define an empty set to get a set of unique adapters
adapters = set()
# Save all the statistics about the trimmed count
trimmed_count = []
# Loop over the list that has been fully cleaned/stripped
for item in cleaned_text_list:
    # ADAPTER LINES == ":"
    if re.search(":", item):
        adapters.add(item)
    # REMOVED READS == "/"
    elif re.search("/", item):
        trimmed_count.append(item)
# Need to extract now start - mid - end
start = []
middle = []
end = []
#Based on how the lines are written can match the items easily
for item in trimmed_count:

    if re.search("start", item):
        start.append(item)
    elif re.search("middle", item):
        middle.append(item)
    elif re.search("end", item):
        end.append(item)

StartAdapRem = 0 
StartTotReads = 0
StartBasePairs = 0
#For each list have to split them to get the numbers out
for s in start:
    splitted_start = s.split(" ")
    # [0] == Adapters & removed [2] == Reads & [10] == BP
    StartAdapRem += int(splitted_start[0].replace(",",""))
    StartTotReads += int(splitted_start[2].replace(",",""))
    StartBasePairs += int(splitted_start[10].replace(",","").replace("(",""))

#print(f"{StartAdapRem}-{StartTotReads}-{StartBasePairs}")

MidAdapRem = 0 
MidTotReads = 0
#For each list have to split them to get the numbers out
for m in middle:
    splitted_mid = m.split(" ")
    # [0] == Adapters & removed [2] == Reads 
    MidAdapRem += int(splitted_mid[0].replace(",",""))
    MidTotReads += int(splitted_mid[2].replace(",",""))

#print(f"{MidAdapRem}-{MidTotReads}")

EndAdapRem = 0 
EndTotReads = 0
EndBasePairs = 0
#For each list have to split them to get the numbers out
for e in end:
    splitted_end = e.split(" ")
    # [0] == Adapters & removed [2] == Reads & [10] == BP
    EndAdapRem += int(splitted_end[0].replace(",",""))
    EndTotReads += int(splitted_end[2].replace(",",""))
    EndBasePairs += int(splitted_end[10].replace(",","").replace("(",""))

#print(f"{EndAdapRem}-{EndTotReads}-{EndBasePairs}")

#######################################
# GENERATING PROWLER REPORT
#######################################
# Empty lists to store the read lengths before and after trimming
before_trim = []
after_trim = []
# Biopython has a usefull library that can handle the read of fastq and fasta files. 
# Makes it much more easier to read in files and can filter on what part of each sequence you want == .seq, .id 
# Read the input fastq file and append the length of each read to before_trim aka a list
for pore_file in os.listdir(args.porechopFastq):

    file_path_pore = f"{args.porechopFastq}/{pore_file}"

    for seq_record in SeqIO.parse(file_path_pore, "fastq"):
            before_trim.append(len(seq_record.seq))

# Read the trimmed fasta file and append the length of each read to after_trim aka a list
for prow_file in os.listdir(args.prowlerFolder):   
    
    if not re.search(".csv",prow_file) or\
        re.search(".non_chimera.fasta",prow_file) or\
        re.search(".split.fasta", prow_file):
          
        file_path_prow = f"{args.prowlerFolder}/{prow_file}"

        for seq_record in SeqIO.parse(file_path_prow, "fasta"):
            after_trim.append(len(seq_record.seq))

# Convert the read length lists to numpy arrays >> Plots require numpy array == [[...]]
before_array = np.array(before_trim)
after_array = np.array(after_trim)

# Create a figure with two subplots + tight layout
fig, axs = plt.subplots(1, 2, tight_layout=True, figsize = (10,5))

# Plot a histogram of read lengths before trimming + setting number of bins + setting the range of x axis
axs[0].hist(before_array, bins = 40, range = [0,10000])
axs[0].set_title('Before trimming Reads')
axs[0].set_xlabel('Read length')
axs[0].set_ylabel('Frequency')
# Plot a histogram of read lengths before trimming + setting number of bins + setting the range of x axis
axs[1].hist(after_array, bins = 40, range = [0,10000])
axs[1].set_title('After trimming Reads')
axs[1].set_xlabel('Read length')
axs[1].set_ylabel('Frequency')

# Saving the file before show
plt.savefig(f"reports/{identifier}/{identifier}Before&After-Prowler.png", dpi=200)
# Savefig does not close the plot. >> clf = close
plt.clf()

#######################################
# GENERATING SACRA REPORT
#######################################
# Defining empty lists beforehand
prow_records = []
chim_records = []
nonchim_records = []
# This list with the gathered seq len from Non-Cimera and Chimera reads
sacra_seq_len = []

### PROWLER SEQUENCES
for prow_file in os.listdir(args.prowlerFolder):   
    
    if not re.search(".csv",prow_file) or\
        re.search(".non_chimera.fasta",prow_file) or\
        re.search(".split.fasta", prow_file):
          
        file_path_prow = f"{args.prowlerFolder}/{prow_file}"
        # Reading in the Prowler Fasta file using Biopython to handel fasta files
        for seq_record in SeqIO.parse(file_path_prow, "fasta"):
            # Append each record to a list
            prow_records.append(seq_record.id)
# Counting the number of IDs == Number of sequences >> total number of sequences present in the fasta file.
count_prow = len([record for record in prow_records])

### CHIMERA SEQUENCES
for chim_file in os.listdir(args.prowlerFolder):

    if re.search(".split.fasta", chim_file):
        
        file_path_chim = f"{args.prowlerFolder}/{chim_file}"
        # Reading in the Fasta file with Chimere sequences
        for seq_record in SeqIO.parse(file_path_chim, "fasta"):
            # Append each record/header to a list
            chim_records.append(seq_record.id)
            # Gathering the read lengths. >> Want all read lengths even of the headers contain multiple lengths
            sacra_seq_len.append(len(seq_record.seq))

# Counting the number of IDs == Number of sequences >> total number of sequences present in the fasta file.
count_chim = len([record for record in chim_records])

### UNIQUE CHIMERA SEQUENCE ID
# Will try to count and see how many reads had one/multiple chimera reads == UNIQUE HEADERS!!
# Setting empty list beforehand
record_splitted = []
# Iterating over the collected chimera sequence records
for chim in chim_records:
    # Split each item >> HEADER:START-END == Want only the first part to find unique headers
    chim_splitted = chim.split(":")
    # Only ID part retained
    record_splitted.append(chim_splitted[0])
# Set an empty set >> Set == only unique IDs
unique_chim = set()
# Iterate over the sequence IDs
for i in record_splitted:
    # Add to the set of IDs
    unique_chim.add(i)
# Counting the number of IDs == Number of UNIQUE sequences
count_unique_chim = len([record for record in unique_chim])

### NON CHIMERA SEQUENCES
for chim_file in os.listdir(args.prowlerFolder):

    if re.search(".non_chimera.fasta", chim_file):
        
        file_path_non_chim = f"{args.prowlerFolder}/{chim_file}"
        # Non chimera sequences were not splitted or so thus headers remain unique
        # Reading in the Prowler Fasta file with Non Chimere reads, using the Biopython library
        for seq_record in SeqIO.parse(file_path_non_chim, "fasta"):
            nonchim_records.append(seq_record.id)
            # Gathering the read lengths. 
            sacra_seq_len.append(len(seq_record.seq))
# Counting the number of IDs == Number of reads
count_nonchim = len([record for record in nonchim_records])

# Informative print of the results gathered
#print(f"Reads after Prowler: {count_prow}\
#      \nHow many chimera sequences: {count_chim}\
#      \nHow many from original unique reads: {count_unique_chim}\
#      \nHow many non chimera sequences: {count_nonchim}\
#      \nSum chimera unique IDs & non chimera IDs: {(total_sacra_seq := count_unique_chim + count_nonchim)}")

### VISUALIZATION
### RAW RESULTS
# Creating a pandas dataframe >> Parse to matplotlib
sacraDf = pd.DataFrame([["No. sequences", count_unique_chim, count_nonchim]],
                       columns = ["Amount", "Chimera", "Non chimera"])
# Plotting the rows  of the No. sequences per bar.
# Setting the width of the bars bit smaller. 
# Adding colormap for visualization. 
ax = sacraDf.plot(x='Amount', kind='bar', stacked=True, width = 0.2,
                colormap = "Set3",  
                title='Total amounft of chimera and non-chimera sequences after SACRA')
# Iterating over the patches to obtain the width and height + x and y coordinates
# Using the x, y coordinates to place it in the center of corresponding bar
for p in ax.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy() 
    # labelling text based on gathered positions. 
    ax.text(x+width/2, 
            y+height/2, 
            '{:.0f}'.format(height), 
            horizontalalignment='center', 
            verticalalignment='center')
    
# For some reason have to set the ticks to 0 to get the label horizontally. 
plt.xticks(rotation=0)
# Legend location to the upper right
# bbox anchor is to change the location, placed it outside the box, bbox_to_anchor(x,y)
plt.legend(loc = 'upper right', bbox_to_anchor=(1.4, 0.95))
# Shrink current axis by 20% (x-axis)
box = ax.get_position()
ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
# Label y-axis
plt.ylabel("No. of sequences")
# Saving the picture 
plt.savefig(f"reports/{identifier}/{identifier}SACRA-Stacked-Seq-Amount.png", dpi=200)
# Savefig does not close the plot. 
plt.clf()

### RELATIVE RESULTS
# Calculations Relative Amount
total_sacra_seq = count_unique_chim + count_nonchim
rel_unique_chim = (count_unique_chim / total_sacra_seq) * 100
rel_nonchim = (count_nonchim / total_sacra_seq) * 100
# Creating a pandas dataframe. >> Parse to matplotlib
sacraDf = pd.DataFrame([["No. sequences", rel_unique_chim, rel_nonchim]],
                       columns = ["Amount", "Chimera", "Non chimera"])
#Plotting the rows  of the No. sequences per bar.
# Setting the width of the bars bit smaller. 
# Adding colormap for visualization. 
ax = sacraDf.plot(x='Amount', kind='bar', stacked=True, width = 0.2,
                colormap = "Set3",  
                title='Total amounft of chimera and non-chimera sequences after SACRA')
# Iterating over the patches to obtain the width and height + x and y coordinates
# Using the x, y coordinates to place it in the center of corresponding bar
for p in ax.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy() 
    # labelling text based on gathered positions. 
    ax.text(x+width/2, 
            y+height/2, 
            '{:.2f} %'.format(height), 
            horizontalalignment='center', 
            verticalalignment='center')

# For some reason have to set the ticks to 0 to get the label horizontally. 
plt.xticks(rotation=0)
# Shrink current axis by 20%
box = ax.get_position()
ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
# Legend location to the upper right
# bbox anchor is to change the location, placed it outside the box, bbox_to_anchor(x,y)
plt.legend(loc = 'upper right', bbox_to_anchor=(1.4, 0.95))
# Label y-axis
plt.ylabel("No. of sequences")
# Saving the created plot as .png, using the dpi to set the size of the figure. 
plt.savefig(f"reports/{identifier}/{identifier}SACRA-Stacked-Seq-Rel-Amount.png", dpi=200)
# Savefig does not close the plot. 
plt.clf()
### HISTOGRAM LENGTH READS
# Convert the read length lists to numpy arrays for plotting
sacra_array = np.array(sacra_seq_len)

# Plot a histogram of sequence lengths after SACRA
# Setting amount of bins & range of the graph. 
plt.hist(sacra_array, bins = 40, range = [min(sacra_array), 1000])
# Setting title, x and y labels. 
plt.title('Sequence lengths after SACRA')
plt.xlabel('Sequence length')
plt.ylabel('Frequency')
# Determining to show the interval of x-axis ticks. 
plt.xticks(np.arange(0, 1000, 100))
# Saving the figure in .png format. 
plt.savefig(f"reports/{identifier}/{identifier}SACRA-Hist-Distribution.png", dpi=200)
# Savefig does not close the plot. 
plt.clf()

#######################################
# SACRA FILTERING STEP
#######################################
# Lists to store the sequence lengths after the filtering of fasta file on certain length. 
filtered_sacra = []
# Read the input fastq file and append the length of each sequence to before_trim list
for seq_record in SeqIO.parse(args.sacraFiltered, "fasta"):
    filtered_sacra.append(len(seq_record.seq))
# Convert the read length lists to numpy arrays for plotting
before_array = np.array(filtered_sacra)

# Plot a histogram with a predefined number of bins & a range set from x1 to x2.
plt.hist(before_array, bins=40, range=[0,1000])
# Setting the title
plt.title('Filtering on a treshhold of ' + str(min(filtered_sacra)) + ' bases')
# X-axis label
plt.xlabel('Read length')
# Setting y-axis label
plt.ylabel('Frequency')
# Detrmining to show the interval of x-axis ticks. 
# np.arange to go from a to b in x amount of steps. 
plt.xticks(np.arange(0, 1000, 100))
# Saving the figure 
plt.savefig(f"reports/{identifier}/{identifier}SACRA-Hist-FilteredSeq.png", dpi=200)
# Close the plot
plt.clf()

#######################################
# GENERATING HTML REPORT
#######################################
# Creating the header line
html_header = f"<html>\n<head>\n</head>\n<body>\n<h1>Statistical Report - Workflow</h1>\n<h2>Porechop ABI</h2>\n<h3>Trimming adapters from read ends</h3>\n"

# Creating the table containg everything
# The last 3 are summary lines from the adapters trimmed so can parse everything until then
unorder_list = []

unorder_list.append("<ul>\n")
for adapter in adapters:

    unorder_list.append(f"\t<li>{adapter}</li>\n")
unorder_list.append("</ul>\n")

# Header adapter loc
adap_loc_header = "<h3>Adapters Removed</h3>\n"

# Adding the last line to the file
html_end = "</body>\n</html>"

# WRITING TO THE FILE
# The location of the outputfile
statisticalFile = args.outputFile

#Opening the outputfile to write to
with open(statisticalFile, "w") as html_file:
    # PORECHOP ABI
    html_file.writelines(html_header)
    # Adapters
    for ul in unorder_list:
        html_file.writelines(ul)
    
    html_file.writelines(adap_loc_header)
    #Removed adapters
    html_file.writelines(f"\t<div>{StartAdapRem} / {StartTotReads} reads had adapters trimmed from their start ({StartBasePairs} bp removed)</div>")
    html_file.writelines(f"\t<div>{MidAdapRem} / {MidTotReads} reads had adapters trimmed from their middle </div>")
    html_file.writelines(f"\t<div>{EndAdapRem} / {EndTotReads} reads had adapters trimmed from their end ({EndBasePairs} bp removed)</div>")
    # PROWLER
    html_file.writelines("<h2>Prowler Trimming</h2>\n")
    # Have to set the locatio from where the html file will be, so set picture in same folder
    html_file.writelines(f"\t<img src='{identifier}Before&After-Prowler.png' height='800px'>\n")

    # SACRA
    html_file.writelines("<h2>Split Amplified Chimeric Read Algorithm (SACRA)</h2>\n")
    # Have to set the locatio from where the html file will be, so set picture in same folder
    html_file.writelines(f"\t<img src='{identifier}SACRA-Stacked-Seq-Amount.png' height='800px'>\n")
    html_file.writelines(f"\t<img src='{identifier}SACRA-Stacked-Seq-Rel-Amount.png' height='800px'>\n")
    html_file.writelines(f"\t<img src='{identifier}SACRA-Hist-Distribution.png' height='800px'>\n")
    # The statistical ouput after filtering on certain amount of bases
    html_file.writelines("<h2>SACRA Filtered Reads</h2>\n")
    html_file.writelines(f"\t<img src='{identifier}SACRA-Hist-FilteredSeq.png' height='800px'>\n")

    # DIAMOND
    html_file.writelines("<h2>DIAMOND </h2>\n")
    # Read the file containing the amount a hit has been found in the genes
    with open(f"reports/{identifier}/{identifier}HeaderCountDIAMOND.txt", "r") as text_reader:
        lines_read = text_reader.readlines()
        # Write the output in an unordered list
        html_file.writelines("<ul>\n")
        for line in lines_read:
            # Write each newline in a list item, strip the line for \n. 
            html_file.writelines(f"\t<li>{line.strip()}</li>\n")
        html_file.writelines("</ul>\n")
    # Writing the pictures to the html file. 
    html_file.writelines(f"\t<img src='{identifier}Bar-HitsPerGene-DIAMOND&Filtering.png' height='800px'>\n")
    html_file.writelines(f"\t<img src='{identifier}Hist-SequenceLengthAfterDIAMOND&Filtering.png' height='800px'>\n")
    #Add the end of html to the file. 
    html_file.writelines(html_end)
# Close the file that has been written to
html_file.close()
# Does not work on the WSL ubuntu yet, could be because no browser installed on it
#time.sleep(2)
#webbrowser.open_new_tab("report.html")
