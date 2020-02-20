import os
configfile: "config/config.yaml"
cluster_config: "config/cluster.yaml"
include: "helpers.py"

SAMPLES = pd.read_csv(config["sampleCSVpath"], sep = ",")
SAMPLES = SAMPLES.replace(np.nan, '', regex=True)

SAMPLE_NAMES = SAMPLES['sample_name'].tolist()
#make sure the output folder for featureCounts exists before running anything
os.system("mkdir -p {0}".format(config["feature_counts_output_folder"]))
#this function uses the text file located in the config folder "star_genomes_species.csv" and
#the config file species parameter to
#give the correct genome for the species
REFERENCE_ANNOTATION = get_gtf(config['species'])

rule all_qc:
    input:
        expand(config['feature_counts_output_folder'] + "{name}_featureCounts_results.txt", name = SAMPLE_NAMES)

rule picard_rna_seq:
	input:
		bamfile = expand(config['star_output_folder'] + "{name}.Aligned.sorted.out.bam",name = SAMPLE_NAMES)
	output:
		config['project_top_level'] + "picard"
	params:
		multiqc_path = config['multiqc_path']
	shell:
		"""
		java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectRnaSeqMetrics \
		I={input.bamfile} \
		O=output.RNA_Metrics \
		REF_FLAT=ref_flat.txt \
		STRAND=SECOND_READ_TRANSCRIPTION_STRAND \
		"""

rule run_multiqc:
	input:
		expand(config['feature_counts_output_folder'] + "{name}_featureCounts_results.txt", name = SAMPLE_NAMES)
	output:
		config['project_top_level'] + "multiqc_report.html"
	params:
		multiqc_path = config['multiqc_path']
	shell:
		"""
		source /share/apps/source_files/python/python-3.6.4.source
		{params.multiqc_path .
		"""
