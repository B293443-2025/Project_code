#!/usr/bin/env python
# coding: utf-8

# ## Data Preparation and Pysster Motif Prediction Pipeline
# 

# In[11]:


import pandas as pd
import numpy as np
import subprocess, os, re
from collections import defaultdict
from pyCRAC.Parsers import GTF2

# code from tutorial: https://github.com/budach/pysster/blob/master/tutorials/workflow_rna_editing.ipynb
from time import time
from IPython.display import Image
from pysster.Data import Data
from pysster.Grid_Search import Grid_Search
from pysster import utils

def parquet_to_fa(output_folder, protein, length):
    protein_n = protein.lower()
    df_parq = pd.read_parquet(output_folder+"/"+f"{protein_n}_clip.parquet")
    df_neg_int = df_parq[df_parq["label"] == 0]
    df_pos_int = df_parq[df_parq["label"] == 1]

    with open(f"{output_folder}/{protein}peaks_norm{length}_negatives_struct.fasta", "w") as f:
        for i, row in df_neg_int.iterrows():
            f.write(">")
            f.write(row["fasta_header"])
            f.write("\n")
            f.write(row["sequence"])
            f.write("\n")
            f.write(row["structure"])
            f.write("\n")

    with open(f"{output_folder}/{protein}peaks_norm{length}_positives_struct.fasta", "w") as f:
        for i, row in df_pos_int.iterrows():
            f.write(">")
            f.write(row["fasta_header"])
            f.write("\n")
            f.write(row["sequence"])
            f.write("\n")
            f.write(row["structure"])
            f.write("\n")

PARAMS_NAB3 = {"conv_num": [1, 2], "kernel_num": [10], "kernel_len": [6, 10], "dropout_input": [0.05, 0.1]}
PARAMS_SSD1 = {"conv_num": [1, 2], "kernel_num": [10, 20], "kernel_len": [10], "dropout_input": [0.05, 0.1]}

configs = [
    # {"protein": "Nab3", "length": "50", "output_folder": "outputs_50nt","structure": False,  "params": PARAMS_NAB3},
    # {"protein": "Nab3", "length": "100", "output_folder": "outputs_100nt","structure": False,  "params": PARAMS_NAB3},
    # {"protein": "Nab3", "length": "100", "output_folder": "outputs_Nab3_100nt_struct","structure": True,  "params": PARAMS_NAB3},
    {"protein": "Ssd1", "length": "100", "output_folder": "outputs_Ssd1_100nt","structure": False,  "params": PARAMS_SSD1},
    # {"protein": "Ssd1", "length": "100", "output_folder": "outputs_Ssd1_100nt_struct","structure": True,  "params": PARAMS_SSD1},
    # {"protein": "Ssd1", "length": "300", "output_folder": "outputs_Ssd1_300nt","structure": False, "params": PARAMS_SSD1},
    # {"protein": "Ssd1", "length": "300", "output_folder": "outputs_Ssd1_300nt_struct","structure": True,  "params": PARAMS_SSD1}
]

for con in configs:
    protein = con["protein"]
    length = con["length"]
    output_folder = con["output_folder"]
    is_struct = con["structure"]
    params = con["params"]

    ex = f"{protein}_{length}nt" + ("_struct" if is_struct else "")
    output_folder_p = f"pysster_output_{ex}_aupr"
    os.makedirs(output_folder_p, exist_ok=True)

    if is_struct:
        parquet_to_fa(output_folder, protein, length)
        pos_file = f"{output_folder}/{protein}peaks_norm{length}_positives_struct.fasta"
        neg_file = f"{output_folder}/{protein}peaks_norm{length}_negatives_struct.fasta"
        alphabet = ("ACGU", "().")
    else:
        pos_file = f"{output_folder}/{protein}peaks_norm{length}_no_overlaps.fasta"
        neg_file = f"{output_folder}/{protein}peaks_norm{length}_negatives.fasta"
        alphabet = ("ACGT")
    if protein == "Nab3" and not is_struct:
        pos_file = f"{output_folder}/test_count_output_FDRs_r100_norm{length}_no_overlaps.fasta"
        neg_file = f"{output_folder}/test_count_output_FDRs_r100_norm{length}_negatives.fasta"
        alphabet = ("ACGT")

    data = Data([pos_file, neg_file], alphabet)
    data.train_val_test_split(0.7, 0.15, seed=42)
    summary = data.get_summary()
    print(summary)
    with open(f"{output_folder_p}/classes.txt", "w") as file:
        file.write(summary)
    searcher = Grid_Search(params)
    start = time()
    model, summary = searcher.train(data, verbose=False, pr_auc=True)
    stop = time()
    print("time in minutes: {}".format((stop-start)/60))
    utils.save_model(model, output_folder_p+"/"+"model.pkl")


    # In[44]:


    from sklearn.preprocessing import label_binarize
    from sklearn.metrics import matthews_corrcoef, accuracy_score
    predictions = model.predict(data, "test")
    predictions
    labels = data.get_labels("test")
    labels
    utils.plot_roc(labels, predictions, output_folder_p+"/"+"roc.png")
    utils.plot_prec_recall(labels, predictions, output_folder_p+"/"+"prec.png")
    perf_report = utils.get_performance_report(labels, predictions)
    print(perf_report)
    print(summary)
    classes =  list(range(labels.shape[1]))
    y_pred = label_binarize(np.argmax(predictions, axis = 1), classes = classes)
    labels = label_binarize(np.argmax(labels, axis = 1), classes = classes)
    mcc = matthews_corrcoef(labels, y_pred)
    acc = accuracy_score(labels, y_pred)
    
    print("MCC: ", mcc)
    print("Accuracy: ", acc)
    with open(f"{output_folder_p}/tuning+performance_results.txt", "w") as f:
        f.write(summary)
        f.write("\n\n")
        f.write(f"MCC: {mcc}")
        f.write("\n")
        f.write(f"Accuracy: {acc}")
        f.write("\n\n")
        f.write(perf_report)



    # In[ ]:


    #save and evaluate

    activations = model.get_max_activations(data, "test")
    logos = model.visualize_all_kernels(activations, data, output_folder_p)

    if is_struct:
        utils.save_as_meme([logo[0] for logo in logos], output_folder_p+"/"+"motifs_seq.meme")
        utils.save_as_meme([logo[1] for logo in logos], output_folder_p+"/"+"motifs_struct.meme")
    else:
        utils.save_as_meme(logos, output_folder_p+"/"+"motifs_seq.meme")

    model.plot_clustering(activations, output_folder_p+"/"+"clustering.png")
    Image(output_folder_p+"/"+"clustering.png")





