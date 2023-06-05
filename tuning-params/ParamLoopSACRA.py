################### MODULES ###################
import subprocess, re

################### PARAMS MPC ###################
# List of minimum PC ratios to test. 
params_mpc = [0,5,10,12,15]

# Iterate over parameter values
for mpc in params_mpc:
    # Update the config file with the new parameter value
    with open('config_snakemake.yaml', 'r') as file:
        config_data = file.read()
    # Save the file in a variable use to resave each change in config file.  
    updated_config_data = config_data
    # Replace the old parameter value with the new one. 
    # Need to use regular expression to match with file and replace each time a new value is place
    ################### STEP 1 ALIGNMENT ###################
    # Alignemnt: a 
    #updated_config_data = re.sub(r"a: \d{1,2} # First a", f"a: {a} # First a", updated_config_data)
    # Alignemnt: A 
    #updated_config_data = re.sub(r"A: \d{1,2} # First A", f"A: {A} # First A", updated_config_data)
    # Alignemnt: b
    #updated_config_data = re.sub(r"A: \d{1,2} # First b", f"A: {A} # First b", updated_config_data)
    # Alignemnt: B
    #updated_config_data = re.sub(r"A: \d{1,2} # First B", f"A: {A} # First B", updated_config_data)
    
    ################### STEP 5 SPLIT ###################
    updated_config_data = re.sub(r"pc: \d{1,2}", f"pc: {mpc}", updated_config_data)
    
    # Save the updated config file
    with open('config_snakemake.yaml', 'w') as file:
        file.write(updated_config_data)
    
    # Run the bash command with the updated config file
    #command = 'scripts/SACRA.sh -i reads.fasta -p ReadsAfterSacra.fasta -t 4 -c ../config/config_snakemake.yaml'
    command = 'cat config_snakemake.yaml'
    subprocess.run(command, shell=True)

################### PARAMS SL ###################
# List of minimum PC ratios to test. 
params_sl = [75,125,100]

# Iterate over parameter values
for sl in params_sl:
    # Update the config file with the new parameter value
    with open('config_snakemake.yaml', 'r') as file:
        config_data = file.read()
    
    ################### STEP 5 SPLIT ###################
    # Set back to default value (10 %)
    updated_config_data = re.sub(r"pc: \d{1,2}", f"pc: 10", config_data)
    # Last value is default 100pb
    updated_config_data = re.sub(r"sl: \d{2,3}", f"sl: {sl}", updated_config_data)
    
    # Save the updated config file
    with open('config_snakemake.yaml', 'w') as file:
        file.write(updated_config_data)
    
    # Run the bash command with the updated config file
    #command = 'scripts/SACRA.sh -i reads.fasta -p ReadsAfterSacra.fasta -t 4 -c ../config/config_snakemake.yaml'
    command = 'cat config_snakemake.yaml'
    subprocess.run(command, shell=True)

################### PARAMS AD ###################
# List of minimum PC ratios to test. 
params_ad = [25,75,50]

# Iterate over parameter values
for ad in params_ad:
    # Update the config file with the new parameter value
    with open('config_snakemake.yaml', 'r') as file:
        config_data = file.read()
    
    ################### STEP 3 CALCULATE PC RATIO ###################
    # Last value is default (50 %)
    updated_config_data = re.sub(r"ad: \d{1,2}", f"ad: {ad}", config_data)
    
    # Save the updated config file
    with open('config_snakemake.yaml', 'w') as file:
        file.write(updated_config_data)
    
    # Run the bash command with the updated config file
    #command = 'scripts/SACRA.sh -i reads.fasta -p ReadsAfterSacra.fasta -t 4 -c ../config/config_snakemake.yaml'
    command = 'cat config_snakemake.yaml'
    subprocess.run(command, shell=True)

################### PARAMS ID ###################
# List of ID ratios CARs 
params_id = [65,85,75]

# Iterate over parameter values
for ids in params_id:
    # Empty list with rewritten line
    newlines = [] 
    # Setting a counter, to count the ids
    count = 0
    # Update the config file with the new parameter value
    with open('config_snakemake.yaml', 'r') as file:
        config_data = file.readlines()
        ################### STEP 3 CALCULATE ID THRESHOLD CARs ###################
        # Last value is default (75 %)
        for line in config_data:
            # Each time it encounters an "id:" count one up. If the ":" not placed, matches on identity as well!
            if re.search(r"\s+id:", line):
                count += 1
                # If the count is equal to 2 then edit the line only. Matching 2 conditions
                if count == 2:
                    # Using regular expression to replace the value of the line
                    updated_config_data = re.sub(r"id: \d{1,2}", f"id: {ids}", line)
                    newlines.append(updated_config_data)
                else:
                    newlines.append(line)
            else:
                newlines.append(line)

    # Save the updated config file
    with open('config_snakemake.yaml', 'w') as file:
        for item in newlines:
            file.write(item)
    
    # Run the bash command with the updated config file
    #command = 'scripts/SACRA.sh -i reads.fasta -p ReadsAfterSacra.fasta -t 4 -c ../config/config_snakemake.yaml'
    command = 'cat config_snakemake.yaml'
    subprocess.run(command, shell=True)