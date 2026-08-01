python scripts/prepare_from_gtf.py \
--gtf ssd1_inputs/Ssd1peaks_norm300_no_overlaps.gtf \
--annotation-gtf ssd1_inputs/Saccharomyces_cerevisiae.EF4.74_SGDv64_CUTandSUT_withUTRs_noEstimates_antisense_intergenic_4xlncRNAs_final.pyCheckGTFfile.output.quotefix.gtf \
--genome ssd1_inputs/Saccharomyces_cerevisiae.EF4.74.dna.toplevel.shortChrNames.fa \
--chromsizes ssd1_inputs/Saccharomyces_cerevisiae.EF4.74.dna.toplevel.shortChrNames.lengths \
--protein ssd1 \
--length 100 \
--out ssd1_custom_intervals_vienna/ssd1_clip_300.parquet \
--neg-gtf ssd1_inputs/Ssd1peaks_norm300_negative_controls.gtf \
--no-depfold

# # Hyperparameter optimisation (50 Optuna trials)
# clip-gnn-train \
#     --data     ssd1_custom_intervals_vienna/ssd1_clip_300.parquet \
#     --out      results_custom/ssd1_hpo300/ \
#     --tune \
#     --n-trials 7
data=ssd1_custom_intervals_vienna/ssd1_clip.parquet
model=results_custom/ssd1_fit_blstm/tune_pass2/d0.1_lr1e-4

data2=ssd1_custom_intervals_vienna/ssd1_clip_50.parquet
model2=results_custom/ssd1_fit50/tune_pass2/d0.1_lr3e-4/

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
    --name Interval1_2 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUCCUUUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_2 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCAACUACUCUAUAUCCCUCUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1_2_mut1 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUUAUCCCUCUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_2_mut1 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCGGCUACUCUAUAUCCCUCUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1_2_mut2 \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCGGCUAAUUUUUAUCCCUCUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_2_mut2 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCGGCUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC \
    --checkpoint $model/best_model.pt \
    --name Interval1_2_gg \
    --out-dir $model/scan
clip-gnn-scan \
    --sequence ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCGGCUAAUUUUCACUCCUUUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU \
    --name Interval2_2_gg \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence TTCTTTTACCATTATCCAACTACTCTACACTCCTTTTTCGCCGAAGAAAA \
    --name Interval1 \
    --epistasis \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AAGAAAAGAACTCTTCCAACTAATTTTCACTCCTTTAAGCATTTTTTTTT \
    --name Interval2 \
    --epistasis \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence TTCTTTTACCATTATCCGGCTACTCTACACTCCTTTTTCGCCGAAGAAAA \
    --name Interval1_gg \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AAGAAAAGAACTCTTCCGGCTAATTTTCACTCCTTTAAGCATTTTTTTTT \
    --name Interval2_gg \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence TTCTTTTACCATTATCCAACTACTCTAUAUCCCTCTTTCGCCGAAGAAAA \
    --name Interval1_mut1 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AAGAAAAGAACTCTTCCAACTAATTTTUAUCCCTCTAAGCATTTTTTTTT \
    --name Interval2_mut1 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence TTCTTTTACCATTATCCGGCTACTCTAUAUCCCTCTTTCGCCGAAGAAAA \
    --name Interval1_mut2 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

clip-gnn-scan \
    --sequence AAGAAAAGAACTCTTCCGGCTAATTTTUAUCCCTCTAAGCATTTTTTTTT \
    --name Interval2_mut2 \
    --checkpoint $model/best_model.pt \
    --out-dir $model/scan

# clip-gnn-scan \
#     --sequence TTTTTATTTGAATATAACCAACTACTAGTCCTTCCTTTAAACAAAAATTT \
#     --name Interval_uth1_2 \
#     --checkpoint $model/best_model.pt \
#     --out-dir $model/scan#