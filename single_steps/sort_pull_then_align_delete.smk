import os
# a top level folder where the bams reside
project_dir = "/home/annbrown/data/ursa_mouse"
out_spot = "name_sortbams/"
bam_spot = "ori_bams/"
fastq_dir = "pulled_fastq/"
bam_suffix = ".bam"
end_type = "pe"
out_spot = "salmon/"
salmon_strand_info = "-l ISR"
salmon_index = "/SAN/vyplab/vyplab_reference_genomes/salmon/human/GRCh38/full/gencode_v34.kmer_31/"

# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------

output_dir = os.path.join(project_dir,out_spot)
bam_dir = os.path.join(project_dir,bam_spot)
fastq_dir = os.path.join(project_dir, fastq_dir)

SAMPLES, = glob_wildcards(bam_dir + "{sample}" + bam_suffix)
print(SAMPLES)

rule all:
  input:
    expand(output_dir + "{sample}_" + "quant.sf", sample = SAMPLES)

rule name_sort:
    input:
        aligned_bam = bam_dir + "{sample}" + bam_suffix
    output:
       temp(output_dir + "{sample}_namesorted.bam")
    shell:
        """
        mkdir -p {output_dir}
        samtools sort -n -@ 2 {input.aligned_bam} -o {output}
        """
if end_type == "pe":
  rule bam_to_fastq:
      input:
          name_sort_bam = output_dir + "{sample}_namesorted.bam"
      output:
          one = temp(fastq_dir + "{sample}_1.merged.fastq"),
          two = temp(fastq_dir + "{sample}_2.merged.fastq")
      shell:
          """
          bedtools bamtofastq -i {input} \
                        -fq {output.one} \
                        -fq2 {output.two}
          """
  rule gunzip_fastq:
      input:
          one = fastq_dir + "{sample}_1.merged.fastq",
          two = fastq_dir + "{sample}_2.merged.fastq"
      output:
          one_out = temp(fastq_dir + "{sample}_1.merged.fastq.gz"),
          two_out = temp(fastq_dir + "{sample}_2.merged.fastq.gz")
      shell:
          """
          gzip {input.one}
          gzip {input.two}
          """
else:
  rule bam_to_fastq:
      input:
          name_sort_bam = output_dir + "{sample}_namesorted.bam"
      output:
          one = temp(fastq_dir + "{sample}_1.merged.fastq")
      shell:
          """
          bedtools bamtofastq -i {input} \
                        -fq {output.one}
          """
  rule gunzip_fastq:
      input:
          one = fastq_dir + "{sample}_1.merged.fastq"
      output:
          one_out = temp(fastq_dir + "{sample}_1.merged.fastq.gz")
      shell:
          """
          gzip {input.one}
          """

rule salmon_quant:
    input:
        fast1 = fastq_dir  + "{sample}_1.merged.fastq.gz",
        fast2 = fastq_dir  + "{sample}_2.merged.fastq.gz",
    output:
        output_dir + "{sample}_" + "quant.sf"
    params:
        out = output_dir + "{sample}",
        out2 = output_dir + "{sample}" + "/quant.sf"
    shell:
        """
        salmon quant \
        --index {params.index_dir} \
        --libType {params.libtype} \
        --mates1 {input.fast1} \
        --mates2 {input.fast2} \
        --geneMap {params.gtf} \
        --threads {params.threads} \
        {params.extra_params} \
        -o {params.output_dir} \
        """