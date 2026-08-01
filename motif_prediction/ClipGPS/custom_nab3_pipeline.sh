python scripts/prepare_from_gtf.py \
--gtf nab3_inputs/test_count_output_FDRs_r100_norm100_no_overlaps.gtf \
--annotation-gtf nab3_inputs/GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf \
--genome nab3_inputs/*fa \
--chromsizes nab3_inputs/*txt \
--protein nab3 \
--out nab3_custom_intervals_vienna/nab3_clip100.parquet \
--neg-gtf nab3_inputs/test_count_output_FDRs_r100_norm100_negative_controls.gtf \
--length 100 \
--no-depfold

# # Hyperparameter optimisation (10 Optuna trials)
# clip-gnn-train \
#     --data     nab3_custom_intervals_vienna/nab3_clip100.parquet \
#     --out      results_custom/nab3_hpo/ \
#     --tune \
#     --n-trials 10

clip-gnn-motif \
    --checkpoint results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/best_model.pt \
    --data       nab3_custom_intervals_vienna/nab3_clip100.parquet \
    --out-dir    results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/ \
    --ranking-score auto

clip-gnn-motif \
    --checkpoint results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/best_model.pt \
    --data       nab3_custom_intervals_vienna/nab3_clip100.parquet \
    --out-dir    results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/ \
    --top-n      500 \
    --mutagenesis

clip-gnn-logo \
    --checkpoint results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/best_model.pt \
    --data nab3_custom_intervals_vienna/nab3_clip100.parquet \
    --out-dir results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/

clip-gnn-predict \
    --checkpoint results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/best_model.pt \
    --data       nab3_custom_intervals_vienna/nab3_clip100.parquet \
    --out        results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/nab3_predictions.parquet

clip-gnn-dropout \
    --checkpoint  results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/best_model.pt \
    --predictions results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/nab3_predictions.parquet \
    --out-dir     results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/ \
    --n-passes    30

#gnn explainer

clip-gnn-interpret \
    --checkpoint          results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/best_model.pt \
    --data                nab3_custom_intervals_vienna/nab3_clip100.parquet \
    --out-dir             results_custom/nab3_fit100/tune_pass2/d0.1_lr3e-4/interpret \
    --gnn-max-seqs  50 \
    --gnn-epochs   200 \
    --structural-mutagenesis