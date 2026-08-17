
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
