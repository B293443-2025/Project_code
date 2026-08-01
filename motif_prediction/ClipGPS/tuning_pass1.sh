#!/usr/bin/bash

data="ssd1_custom_intervals_vienna/ssd1_clip.parquet" 
out="results_custom/ssd1_fit_bilstm_auroc/tune_pass1"
summary="$out/summary.txt"

rm $summary
mkdir -p $out
touch $summary

echo "batch-size 16" >> $summary
echo "hidden-dim 64" >> $summary
echo "num-heads 4" >> $summary
echo "epochs 35" >> $summary
echo "patience 5" >> $summary

for layers in 2 4; do
    for wd in 1e-5 1e-4 3e-4; do
    run="l${layers}_wd${wd}"
    out_subdir="$out/$run"
    mkdir -p $out_subdir

    echo $data >> $summary
    echo "layers" >> $summary
    echo $layers >> $summary
    echo "weight decay" >> $summary
    echo $wd >> $summary

    clip-gnn-train \
    --data $data \
    --out $out_subdir \
    --batch-size 16 \
    --hidden-dim 64 \
    --num-layers $layers \
    --num-heads 4 \
    --epochs 35 \
    --weight-decay $wd \
    --bilstm-layers 1 \
    --patience 5 2>&1 >> $summary
    done
done

mkdir -p results_custom/ssd1_optuna_300/
touch results_custom/ssd1_optuna_300/summary.txt
nohup clip-gnn-train \
    --data ssd1_custom_intervals_vienna/ssd1_clip_300.parquet \
    --out results_custom/ssd1_optuna_300 \
    --tune 2>&1 >> results_custom/ssd1_optuna_300/summary.txt &