import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import numpy as np
import pandas as pd
from clip_gnn.scan import _fold, _mutation_table, plot_scan
from pysster.Model import Model
from pysster.Data import Data
from pysster import utils
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("-s", help="sequence")
parser.add_argument("-n", help="name")
parser.add_argument("-p", help="protein")
parser.add_argument("-m", help="model path")

args = parser.parse_args()

output_folder = f"pysster_scan_{args.p}_{args.n}"
if not os.path.isdir(output_folder):
    os.makedirs(output_folder)

model_path = args.m
NTS       = ["A", "C", "G", "U"]
NT_IDX    = {nt: i for i, nt in enumerate(NTS)}

model = utils.load_model(model_path)

def pysster_predict_probs(model, sequences):
    path = f"{output_folder}/scan_seqs.fasta"
    with open(path, "w") as f:
        for seq in sequences:
            f.write(">1\n")
            f.write(seq + "\n")
        
    data = Data(path, ("ACGU"))
    probs = model.predict(data, "all")
    probs = probs[:, 0]
    os.remove(path)
    return probs


def scan_sequence(
    model,
    sequence: str,
) -> tuple[float, np.ndarray]:
    """Scan all single-nucleotide substitutions in *sequence*.

    Parameters
    ----------
    sequence  : RNA sequence (any case; T→U automatically)

    Returns
    -------
    wt_prob : float
        Predicted binding probability of the wildtype sequence.
    mut_mat : np.ndarray, shape [4, L]
        mut_mat[i, j] = predicted probability when position j carries NTS[i].
        The wildtype nucleotide cell contains wt_prob.
    """
    seq_upper = sequence.upper().replace("T", "U")
    L = len(seq_upper)

    # Wildtype prediction
    wt_prob = float(pysster_predict_probs(model, [seq_upper])[0])

    # Enumerate non-wildtype substitutions
    mut_seqs    = []
    mut_coords  = []   # (nt_idx, pos)

    for pos in range(L):
        wt_nt = seq_upper[pos]
        for nt in NTS:
            if nt == wt_nt:
                continue
            mut_seq = seq_upper[:pos] + nt + seq_upper[pos + 1:]
            mut_seqs.append(mut_seq)
            mut_coords.append((NT_IDX[nt], pos))

    # Batch inference
    if mut_seqs:
        mut_probs_arr = pysster_predict_probs(
            model, mut_seqs
        )
    else:
        mut_probs_arr = np.array([])

    # Build [4, L] matrix — fill wildtype positions with wt_prob first
    mut_mat = np.full((4, L), np.nan)
    for pos in range(L):
        ni = NT_IDX.get(seq_upper[pos], -1)
        if ni >= 0:
            mut_mat[ni, pos] = wt_prob

    for (ni, pos), prob in zip(mut_coords, mut_probs_arr):
        mut_mat[ni, pos] = float(prob)

    return wt_prob, mut_mat


def plot(sequence):
    wt_prob, mut_mat = scan_sequence(model, sequence)

    with PdfPages(f"{output_folder}/{args.n}.pdf") as pdf:
        plot_scan(pdf, sequence, wt_prob, mut_mat, name=args.n)

    df = _mutation_table(sequence, wt_prob, mut_mat)
    df.to_csv(f"{output_folder}/{args.n}.tsv", sep="\t", index=False)

plot(args.s) 
    
