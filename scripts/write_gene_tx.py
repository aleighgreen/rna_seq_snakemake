import argparse
from gtfparse import read_gtf

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-g", "--gtf", help="a GTF",
                        type=str)
    parser.add_argument("-o", "--output", help="an output for the GTF",
                        type=str)
    args = parser.parse_args()


    in_file = args.gtf
    out_file = args.output

    df = read_gtf(in_file)
    df = df[['gene_id','transcript_id']].drop_duplicates()
    df = df[df['transcript_id'] != ""]
    df.to_csv(out_file, sep='\t', index=False,header = False)

    return 0


if __name__ == "__main__":
    main()
