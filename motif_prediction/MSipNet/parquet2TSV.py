#6 columns
import pandas as pd

df = pd.read_parquet("../ClipGPS/datasets/ssd1_clip.parquet")
df["Type"] = "Ssd1"
df["Score"] = 0.0
df["Str"] = "0.0"

out = df[["Type", "fasta_header", "sequence", "Str", "Score", "label"]]
out.to_csv("Ssd1.tsv", index=False, header=None, sep="\t")

