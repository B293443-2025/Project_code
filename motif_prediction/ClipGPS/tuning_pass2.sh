#!/usr/bin/bash
#modified paths depending on dataset and best hyperparameters from tune_pass1 results accordingly, append a chosen on the model with bet vaildation performance 
data="datasets/ssd1_100nt_clip.parquet" 
out="ssd1_100nt_fit/tune_pass2"
summary="$out/summary.txt"
layers="2"
wd="1e-5"

rm $summary
mkdir -p $out
touch $summary

echo "batch-size 16" >> $summary
echo "hidden-dim 64" >> $summary
echo "num-layers $layers" >> $summary
echo "weight-decay $wd" >> $summary
echo "num-heads 4" >> $summary
echo "epochs 35" >> $summary
echo "patience 5" >> $summary

for dr in 0.1 0.2; do
    for lr in 1e-4 3e-4; do
        run="d${dr}_lr${lr}"
        out_subdir="$out/$run"
        mkdir -p $out_subdir

        echo $data >> $summary
        echo "dropout" >> $summary
        echo $dr >> $summary
        echo "learning rate" >> $summary
        echo $lr >> $summary

        clip-gnn-train \
        --data $data \
        --out $out_subdir \
        --batch-size 16 \
        --hidden-dim 64 \
        --num-layers $layers \
        --num-heads 4 \
        --epochs 35 \
        --dropout $dr \
        --weight-decay $wd \
        --lr $lr \
        --patience 5 2>&1 >> $summary
    done
done