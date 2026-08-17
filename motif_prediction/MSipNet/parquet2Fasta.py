#prepare structural file parquet->fasta
import pandas as pd

df_parq = pd.read_parquet("../ClipGPS/datasets/ssd1_clip.parquet")
protein="Ssd1"
length=str(100)

df_neg_int = df_parq[df_parq["label"] == 0]
df_pos_int = df_parq[df_parq["label"] == 1]

with open(f"{protein}peaks_norm{length}_negatives.fasta", "w") as f:
    for i, row in df_neg_int.iterrows():
        f.write(">")
        f.write(row["fasta_header"])
        f.write("\n")
        f.write(row["sequence"])
        f.write("\n")

with open(f"{protein}peaks_norm{length}_no_overlaps.fasta", "w") as f:
    for i, row in df_pos_int.iterrows():
        f.write(">")
        f.write(row["fasta_header"])
        f.write("\n")
        f.write(row["sequence"])
        f.write("\n")
