#!/usr/bin/python3
# Creating a report file to generate a report file after performing the Porechop ABI

#Importing needed modules
import re

# Opening the file from the current location 
with open("Log_file.txt", "r") as text_file:
    #Splitting the lines of the file to get a list
    splitted_file = text_file.readlines()
    #print(splitted_file)

    flag = 0 

    for line in splitted_file:

        if re.search("Trimming adapters from read ends", line):
            flag = 1
        elif re.search("^\n", line):
            flag = 0
        elif re.search("adapters trimmed from their", line):
            flag = 2
        elif re.search("reads were split based on middle adapters", line):
            flag = 3


        if flag == 1 or flag == 2 or flag == 3:
            print(line)
