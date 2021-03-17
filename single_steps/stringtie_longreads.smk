configfile: "config/single_steps_config.yaml"
include: "../rules/helpers.py"

import pandas as pd
import os
import subprocess
import yaml

localrules: compose_gtf_list
##############################
##### STOLEN FROM https://github.com/bioinformatics-core-shared-training/RNAseq_March_2019/tree/master/
##### Final output is a merged gtf of all samples containing transcripts that
##### were found in the samples but NOT the input GTF
##############################
#reading in the samples and dropping the samples to be excluded in order to get a list of sample names
# samples = pd.read_csv(config['sampleCSVpath'])
# samples2 = samples.loc[samples.exclude_sample_downstream_analysis != 1]
# SAMPLE_NAMES = list(set(samples2['sample_name']))


options_dict = config["stringtie_longreads"]

bam_dir = os.path.join(options_dict["bam_spot"], "")
stringtie_outdir = os.path.join(options_dict["out_spot"], "")
GTF = options_dict['gtf']

SAMPLE_NAMES = list(glob_wildcards(os.path.join(bam_dir, "{sample}" + options_dict["bam_suffix"])))
print(SAMPLE_NAMES)


rule all_stringtie:
    input:
        expand(stringtie_outdir + "{sample}.assemble.gtf", sample = glob_wildcards(os.path.join(bam_dir, "{sample}" + options_dict["bam_suffix"])),
        os.path.join(stringtie_outdir, "stringtie_merged.unique.gtf"),
        os.path.join(stringtie_outdir, "stringtie_merged.gtf")

rule StringTie_Assemble:
    input:
        bam = os.path.join(bam_dir, "{sample}" + options_dict['bam_suffix']),
        ref_gtf = GTF
    output:
        stringtie_outdir + "{sample}.assemble.gtf"
    conda:
        "../envs/stringtie.yaml"
    shell:
        "stringtie -L -G {input.ref_gtf} -o {output} {input.bam}"


rule compose_gtf_list_stringtie:
    input:
        expand(stringtie_outdir + "{sample}.assemble.gtf", sample=SAMPLE_NAMES)
    output:
        txt = os.path.join(stringtie_outdir,"gtf_list.txt")
    run:
        with open(output.txt, 'w') as out:
            print(*input, sep="\n", file=out)

rule merge_stringtie_gtfs:
    input:
        gtf_list = os.path.join(stringtie_outdir,"gtf_list.txt")
    output:
        merged_gtf = os.path.join(stringtie_outdir,"stringtie_merged.gtf")
    params:
        gtfmerge = options_dict['gtfmerge']
    shell:
        """
        {params.gtfmerge} union {input.gtf_list} {output.merged_gtf} -t 2 -n
        """
