python scripts/prepare_from_gtf.py \
--gtf ../Pysster/Ssd1_dataset_100nt/Ssd1peaks_norm100_no_overlaps.gtf \
--annotation-gtf ../../data/references/Saccharomyces_cerevisiae.EF4.74_SGDv64_CUTandSUT_withUTRs_noEstimates_antisense_intergenic_4xlncRNAs_final.pyCheckGTFfile.output.quotefix.gtf \
--genome ../../data/references/Saccharomyces_cerevisiae.EF4.74.dna.toplevel.shortChrNames.fa \
--chromsizes ../../data/references/Saccharomyces_cerevisiae.EF4.74.dna.toplevel.shortChrNames.lengths \
--protein ssd1 \
--length 100 \
--out datasets/ssd1_100nt_clip.parquet \
--neg-gtf ../Pysster/Ssd1peaks_norm300_negative_controls.gtf \
--no-depfold

# Hyperparameter optimisation (50 Optuna trials)
# clip-gnn-train \
#     --data     datasets/ssd1_100nt_clip.parquet \
#     --out      ssd1_hpo/ \
#     --tune \
#     --n-trials 8
data=datasets/ssd1_100nt_clip.parquet
model=ssd1_100nt_fit/tune_pass2/d0.2_lr3e-4_chosen

clip-gnn-motif \
    --checkpoint $model/best_model.pt \
    --data       $data \
    --out-dir    $model \
    --ranking-score auto

clip-gnn-motif \
    --checkpoint $model/best_model.pt \
    --data       $data \
    --out-dir    $model \
    --top-n      500 \
    --mutagenesis

clip-gnn-logo \
    --checkpoint $model/best_model.pt \
    --data $data \
    --out-dir $model/kmer6 \
    --kmer-size 8

clip-gnn-predict \
    --checkpoint $model/best_model.pt \
    --data       $data \
    --out        $model/ssd1_predictions.parquet

clip-gnn-dropout \
    --checkpoint  $model/best_model.pt \
    --predictions $model/ssd1_predictions.parquet \
    --out-dir     $model \
    --n-passes    30

#gnn explainer
clip-gnn-interpret \
    --checkpoint          $model/best_model.pt \
    --data                $data \
    --out-dir             $model/interpret \
    --gnn-max-seqs  50 \
    --gnn-epochs   200 \
    --structural-mutagenesis

clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCAACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUCCUUUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCAACUACUCUAUAUCCCUCUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1_mut1 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUUAUCCCUCUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_mut1 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCGGCUACUCUAUAUCCCUCUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1_mut2 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCGGCUAAUUUUUAUCCCUCUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_mut2 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCGGCUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1_mut3 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCGGCUAAUUUUCACUCCUUUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_mut3 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan