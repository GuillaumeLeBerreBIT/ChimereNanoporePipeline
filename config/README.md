# Configuration File

This is a configuration file written in YAML format. It contains various parameters and settings for running a specific program or workflow. The following sections describe the different sections and their corresponding values:

## General Settings
- **startfolder**: The path to the folder containing all the input files (fastq). It can use relative or absolute paths. The current value is "../Cmaenas_minion_data".

- **identifier**: A unique identifier used for creating folder and file names. It is recommended to use different identifiers for each run to avoid overwriting or combining files from different experiments. The current identifier is "fastq_runid_211".

- **genes**: A list of mitochondrial genes. The current list includes "ATP6", "ATP8", "COX1", "COX2", "COX3", "CYTB", "NAD1", "NAD2", "NAD3", "NAD4", "NAD4L", "NAD5", and "NAD6".

## PROWLER Settings
- **clip**: Select the clipping mode for leading and trailing Ns. "LT" trims both, "L" trims leading, and "T" trims trailing. The current mode is "LT".

- **fragments**: The fragmentation mode. The current mode is "U0".

- **trimmode**: Set the trimming algorithm. "S" for Static or "D" for Dynamic. The current mode is "D".

- **qscore**: Set the quality score trimming threshold. The current threshold is 7.

- **windowsize**: Change the size of the trimming window. The current size is 100.

- **minlen**: The minimum acceptable number of bases in a read. The current value is 100.

- **datamax**: Select a maximum data subsample in MB. The default is 0, which means the entire sample is used.

## filter SACRA sequences length
- **bases**: The minimum threshold of base length to filter the fasta file. The current value is 50.

## DIAMOND Settings
- **max-target-seq**: The maximum number of target sequences per query to report alignments for. The current value is 1.

- **output-format**: The format of the output file. The current format is 6, which represents the BLAST tabular format.

## Filter DIAMOND Settings
- **idperc**: The minimum percentage identity. The current value is 70.

- **len**: The minimum length (in residues) of a sequence. The current value is 20.

- **eval**: The maximum e-value to filter the BLASTX results on. The current value is 10e-6.

## SACRA Settings
### STEP 1 - Alignemnt
- **alignment**: Configuration for the all-vs-all pairwise alignment of input long-read by the LAST aligner for constructing aligned read clusters (ARCs).
  - **R**: "01"
  - **u**: "NEAR"
  - **a**: 0 (Gap existence cost of LAST aligner)
  - **A**: 10 (Insertion existence cost of LAST aligner)
  - **b**: 15 (Gap extension cost of LAST aligner)
  - **B**: 7 (Insertion extension cost of LAST aligner)
  - **S**: 1
  - **f**: "BlastTab+"

- **parsdepth**: Configuration for detecting partially aligned reads (PARs) and candidate chimeric positions from the alignment result of STEP 1.

### STEP 2 - PARs depth
  - **al**: 100 (Minimum alignment length)
  - **tl**: 50 (Minimum terminal length of unaligned region of PARs)
  - **pd**: Minimum depth of PARs. The current value is 1.
  - **id**: Alignment identity threshold of PARs. The current value is 75.

### STEP 3 - Calculate PC ratio
- **ad**: Minimum length of the alignment start/end position from the candidate chimeric position. The current value is 50.

- **id**: Alignment identity threshold of CARs. The current value is 75.

### STEP 4 - Calculate mPC ratio    
- **sp**: If the mPC ratio is calculated from a spike-in reference genome, set it to true. Otherwise, set it false. The current value is "false".

- **rf**: PATH to the spike-in reference genome. The current value is "lambda.fasta".

- **R**: "01"
- **u**: "NEAR"
- **a**: 8 (Gap existence cost of LAST aligner)
- **A**: 16 (Insertion existence cost of LAST aligner)
- **b**: 12 (Gap extension cost of LAST aligner)
- **B**: 5 (Insertion extension cost of LAST aligner)
- **S**: 1
- **f**: "BlastTab+"
- **id**: Alignment identity threshold. The current value is 95.
- **al**: Minimum alignment length. The current value is 50.
- **lt**: Threshold of the unaligned length for detecting chimeric reads. The current value is 50.

## STEP 5 - Split
- **pc**: Minimum PC ratio (default: 10%). SACRA detects the chimeric positions with a PC ratio greater than this threshold. The current value is 10.

- **dp**: Minimum depth of PARs + CARs. The current value is 0.

- **sl**: Sliding windows threshold (default: 100bp). For detecting the most probable chimeric position from a chimeric junction with a similar sequence, SACRA detects the chimeric position with the highest PARs depth in this threshold window. The current value is 100.

