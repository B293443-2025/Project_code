import argparse
import os, subprocess
import pandas as pd

#scanner code adapter from ClipGPS scan.py
NTS = ["A", "C", "G", "U"]

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--sequence")
parser.add_argument("-n", "--name")
parser.add_argument("-m", "--model")
parser.add_argument("-o", "--output_dir", default=".")
args = parser.parse_args()
if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

seq = args.sequence.upper().replace("T", "U")
L = len(seq)
wt_path = os.path.join(args.output_dir, "{}_wt.fasta".format(args.name))
mut_path = os.path.join(args.output_dir, "{}_muts.fasta".format(args.name))

with open(wt_path, "w") as wt_f:
    wt_f.write(">{}_wt\n{}".format(args.name, seq))

with open(mut_path, "w") as mut_f:
    for pos in range(L):
        wt_nt = seq[pos]
        for nt in NTS:
            if nt == wt_nt:
                continue
            mut_seq = seq[:pos] + nt + seq[pos + 1:]
            mut_name = "{}_pos{}_{}>{}".format(args.name, pos, wt_nt, nt)
            mut_f.write(">{}\n{}\n".format(mut_name, mut_seq))

out_tsv = args.output_dir+"/{}.tsv".format(args.name)
subprocess.call(["python", "{}/deepclip/DeepCLIP.py".format(home), "--runmode", "predict", 
                 "-P", args.model, 
                 "--sequences", wt_path,
                  "--variant_sequences", mut_path,
                  "--predict_output_file", out_tsv
                  ])
top_10 = args.output_dir+"/{}_top10.tsv".format(args.name)
df = pd.read_csv(out_tsv, sep="\t", header = None)
df.columns = ["WT", "Mutant", "WT sequence", "Mutant sequence", "WT score", "Mutant score"]
df["difference"] =  abs(df["WT score"] - df["Mutant score"])
df_top10 = df.nlargest(10, "difference")
df_top10.to_csv(top_10, sep = "\t", index=False, header=None)

mut_seqs = os.path.join(args.output_dir, "{}_muts_top10.fasta".format(args.name))
with open(mut_seqs, "w") as f:
    for i, row in df_top10.iterrows():
        f.write(">{}\n{}\n".format(row["Mutant"], row["Mutant sequence"]))

subprocess.call(["python", "{}/deepclip/DeepCLIP.py".format(home), "--runmode", "predict", 
                 "-P", args.model, 
                 "--sequences", wt_path,
                  "--variant_sequences", mut_seqs,
                  "--predict_output_file", top_10,
                  "--draw_profiles"])