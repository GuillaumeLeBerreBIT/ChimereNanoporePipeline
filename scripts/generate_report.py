#!/usr/bin/python3
# Creating a report file to generate a report file after performing the Porechop ABI

#Importing needed modules
import re, os, webbrowser, time

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
# GENERATIN HTML REPORT
#######################################

# Creating the header line
html_header = f"<html>  <head> </head> <body> <h1> {cleaned_text_list[0]} </h1>"

# Creating the table containg everything

# The last 3 are summary lines from the adapters trimmed so can parse everything until then
unorder_list = []
unorder_list.append("<ul>")
for adapter in cleaned_text_list[1:-3]:

    unorder_list.append(f"<li>{adapter}</li>")
unorder_list.append("</ul>")
#print(unorder_list)

# Adding the last summary lines from where the adapters are removed or not. 
adapter_loc_list = []
for adap_loc in cleaned_text_list[-3:]:
    adapter_loc_list.append(f"<div>{adap_loc}</div>")

# Adding the last line to the file
html_end = "</body> </html>"

with open("reports/Results.html", "w") as html_file:
    html_file.writelines(html_header)
    
    for ul in unorder_list:
        html_file.writelines(ul)
    
    for summary in adapter_loc_list:
        html_file.writelines(summary)
    
    html_file.writelines(html_end)

# Does not work on the WSL ubuntu yet, could be because no browser installed on it
#time.sleep(2)
#webbrowser.open_new_tab("report.html")