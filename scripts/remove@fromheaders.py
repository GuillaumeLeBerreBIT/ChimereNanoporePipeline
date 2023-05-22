import re
with open("fastq_runid_211FastaForAssembly-BioPython-removed@.fasta", "w") as file_to_write:
    with open("fastq_runid_211FastaForAssembly-BioPython.fasta", "r") as file_to_read:
        file_lines = file_to_read.readlines()

        for line in file_lines:
            if re.search("@", line):
                removed_at = line.replace("@", "")
                file_to_write.writelines(removed_at)
            else:
                file_to_write.writelines(line)