The only thing you should need to edit is the config.yaml file. All directory paths should end with a trailing /

### How to make a sample sheet
The necessary columns are
`sample_name`	`unit`	`fast1`	`fast2`	`group`	`exclude_sample_downstream_analysis`

After that, you can include as many columns with sample metadata as you want. 


#### What to put in each columns
`sample_name` - the name that you want each sample to have, for clarities sake I recommend using snake_case. Please no spaces, and don't start with a number. 


`unit` - this is for the situation when there are multiple fastq's per sample, such as as the following case

sample_name | unit | fast1 | fast2 | group | exclude_sample_downstream_analysis
-- | -- | -- | -- | -- | --
sample_one | WTCHG_598911_202118 | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_598911_202118_1.fastq.gz | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_598911_202118_2.fastq.gz | OPMD | 
sample_one | WTCHG_606179_202118 | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_606179_202118_1.fastq.gz | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_606179_202118_2.fastq.gz | OPMD | 
sample_two | WTCHG_598911_203130 | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_598911_203130_1.fastq.gz | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_598911_203130_2.fastq.gz | IBM | 
sample_two | WTCHG_606179_203130 | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_606179_203130_1.fastq.gz | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_606179_203130_2.fastq.gz | IBM | 
sample_two | WTCHG_606180_203130 | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_606180_203130_1.fastq.gz | /SAN/vyplab/IoN_RNAseq/Bilal_Muscle_biopsies/fastqs/WTCHG_606180_203130_2.fastq.gz | IBM | 


This is to allow trimming to occur on each fastq independently and then the merging is done later, if you don't have multiple fastqs per sample
please just put a placeholder there. If downloaded from SRA, I recommend the accession, but just don't leave it empty, you could fill  it with "placeholder". 

sample_name | unit | fast1 | fast2 | group | exclude_sample_downstream_analysis
-- | -- | -- | -- | -- | --
axonal_control_1 | SRR11430624 | /SAN/vyplab/alb_projects/data/briese_tdp43_mouse_motorneuron/raw_data/SRR11430624.fastq |  | axonal_control | 
axonal_control_2 | SRR11430625 | /SAN/vyplab/alb_projects/data/briese_tdp43_mouse_motorneuron/raw_data/SRR11430625.fastq |  | axonal_control | 
axonal_control_3 | SRR11430626 | /SAN/vyplab/alb_projects/data/briese_tdp43_mouse_motorneuron/raw_data/SRR11430626.fastq |  | axonal_control | 
axonal_control_4 | SRR11430627 | /SAN/vyplab/alb_projects/data/briese_tdp43_mouse_motorneuron/raw_data/SRR11430627.fastq |  | axonal_control | 

`fast1`	`fast2` - paths to the fast1 and fast2 files, if data is single end leave fast2 blank

`group` - a group name, useful for downstream analysis

`exclude_sample_downstream_analysis` - if a sample ends up being dirty or you don't want to analyze it, place a 1, otherwise leave blank


### How to run the pipeline

The pipeline has specific defined workflows. These are currently:

#### fastq_qc
1. Trim reads with fastp
2. Generate QC reports with FASTQC

#### interleave_fastq_qc
1. Trim reads with fastp
2. Generate QC reports with FASTQC
3. Combine paired end read files into single, interleaved FASTQ file with bbmap

#### align
1. Trim reads with fastp
2. Generate QC reports with FASTQC
3. Align reads to genome with STAR
4. Generate gene (raw) read count tables with FeatureCounts
5. Generate gene TPM values with TPMcalculator


Submit to the cluster using the following command. The **first argument** should be your **workflow of choice** (*{workflow}*), followed by a specific **run name for the job** (*{run_name}*, optional but recommended).
`source submit.sh {workflow} {run_name}`


You should have Snakemake executable from your path. Check that this is the case before submission by typing in "which snakemake" at the command line. It should say this:
"/share/apps/python-3.7.2-shared/bin/snakemake""

To add Snakmake to your PATH. You'll also need to be using the correct version of Python. I recommend doing the following.

Open your .bash_profile:
"nano ~/.bash_profile"

Add this line to your .bash_profile to source the Cluster Folk's file for setting your Python version

"source /share/apps/examples/source_files/python/python-3.7.2.source"

Close the .bash_profile, source it, "source ~/.bash_profile"

Confirm that snakemake is callable

"which snakemake" should now say "/share/apps/python-3.7.2-shared/bin/snakemake"

In the samples csv sheet, the unit column is used for when the fastq's for a single sample have been split. E.G if one sample has multiple fastqs this will tell you that. If you only have one fastq per sample, the unit column must not be empty. Please fill it out with either the sample name or just some place holder text like "a". It will not work if you just put a number.

Before submission I recommend that you test that everything looks correct with a dry run first. This can be done with
"snakemake -s rna_seq.snakefile -n -p"
