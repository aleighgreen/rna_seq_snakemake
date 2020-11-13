import os
# a top level folder where the bams reside
project_dir = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/"
out_spot = "name_sortbams/"
bam_spot = "NYGC_bams/"
fastq_dir = "pulled_fastq/"
bam_suffix = ".cut.bam"
end_type = "pe"
IRfinder_path = "/SAN/vyplab/alb_projects/tools/IRFinder/bin/IRFinder"
IRfinder_reference = "/SAN/vyplab/alb_projects/tools/IRFinder/REF/human_gencodev34_3"
# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------

output_dir = os.path.join(project_dir,out_spot)
bam_dir = os.path.join(project_dir,bam_spot)
fastq_dir = os.path.join(project_dir, fastq_dir)

SAMPLES, = glob_wildcards(bam_dir + "{sample}" + bam_suffix)
print(SAMPLES)

rule all:
  input:
    expand(output_dir + "{sample}/IRFinder-IR-nondir.txt", sample = SAMPLES),
    # expand(fastq_dir + "{sample}_1.merged.fastq.gz", sample = SAMPLES)

rule name_sort:
    input:
        aligned_bam = bam_dir + "{sample}" + bam_suffix
    output:
       out_name = temp(output_dir + "{sample}_namesorted.bam")
    shell:
        """
        mkdir -p {output_dir}
        samtools sort -n -@ 2 {input.aligned_bam} -o {output.out_name}
        """
rule run_ir_finder:
    input:
        output_dir + "{sample}_namesorted.bam"
    output:
        "{sample}/IRFinder-IR-nondir.txt"
    shell:
        """
        {IRfinder_path} -m BAM -r {IRfinder_reference} -d {sample} {input}
        """
