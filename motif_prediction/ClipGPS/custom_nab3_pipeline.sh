python scripts/prepare_from_gtf.py \
--gtf ../Pysster/Nab3_dataset_100nt/test_count_output_FDRs_r100_norm100_no_overlaps.gtf \
--annotation-gtf ../../data/references/GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf \
--genome ../../data/references/*fa \
--chromsizes ../../data/references/*txt \
--protein nab3 \
--out datasets/nab3_100nt_clip.parquet \
--neg-gtf ../Pysster/Nab3_dataset_100nt/test_count_output_FDRs_r100_norm100_negative_controls.gtf \
--length 100 \
--no-depfold

CHECKPOINT=nab3_100nt_fit/tune_pass2/d0.1_lr3e-4_chosen/best_model.pt
DATA=datasets/nab3_100nt_clip.parquet
OUT=nab3_100nt_fit/tune_pass2/d0.1_lr3e-4_chosen/

clip-gnn-motif \
    --checkpoint $CHECKPOINT \
    --data       $DATA \
    --out-dir    $OUT \
    --ranking-score auto

clip-gnn-motif \
    --checkpoint $CHECKPOINT \
    --data       $DATA \
    --out-dir    $OUT \
    --top-n      500 \
    --mutagenesis

clip-gnn-logo \
    --checkpoint $CHECKPOINT \
    --data       $DATA \
    --out-dir    $OUT \

clip-gnn-predict \
    --checkpoint $CHECKPOINT \
    --data       $DATA \
    --out        ${OUT}/nab3_predictions.parquet

clip-gnn-dropout \
    --checkpoint $CHECKPOINT \
    --data       $DATA \
    --out-dir    $OUT \
    --n-passes    30

#gnn explainer

clip-gnn-interpret \
    --checkpoint $CHECKPOINT \
    --data       $DATA \
    --out-dir    ${OUT}/interpret \
    --gnn-max-seqs  50 \
    --gnn-epochs   200 \
    --structural-mutagenesis