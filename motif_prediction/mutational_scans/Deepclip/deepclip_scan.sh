DEEPCLIP=~/deepclip/DeepCLIP.py
DATA=../Data_preparation/Ssd1_dataset_100nt/
POS=../Data_preparation/Ssd1_dataset_100nt/Ssd1peaks_norm100_no_overlaps.fasta
NEG=../Data_preparation/Ssd1_dataset_100nt/Ssd1peaks_norm100_negatives.fasta
SEQ1=AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCAACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC
SEQ2=ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUCCUUUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU
CHOSEN_MODEL=../Ssd1_tuning_f4_n8_l20.001

# for filters in 1 4; do
#   for nodes in 8 32; do
#     for l2 in 0.01 0.001; do
#       RUN="f${filters}_n${nodes}_l2${l2}"
#       python $DEEPCLIP --runmode train \
#           --num_filters $filters \
#           --lstm_nodes $nodes \
#           -e 50 --early_stopping 10 \
#           --performance_selection auroc \
#           --sequences $POS \
#           --background_sequences $NEG \
#           -n Ssd1_tuning_${RUN} \
#           -P Ssd1_tuning_${RUN}_predict_fn \
#           --l2 $l2 \
#           --data_split 0.7 0.15 0.15 \
#           --test_output_file Ssd1_tuning_${RUN}.json
#     done
#   done


OUTPUT_DIR=deepclip_scan_results
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR
mkdir -p png_files


#wt
python ../deepclip_scan.py -s $SEQ1 -n Interval1 -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
python ../deepclip_scan.py -s $SEQ2 -n Interval2 -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
convert +append *Interval1*.png combined_inteval1.png
convert +append *Interval2*.png combined_interval2.png
mv *png png_files

#mutant 1
python ../deepclip_scan.py -s AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCGGCUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC -n Interval1_mut1 -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
python ../deepclip_scan.py -s ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCGGCUAAUUUUCACUCCUUUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU -n Interval2_mut1 -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
convert +append *Interval1*.png combined_inteval1_mut1.png
convert +append *Interval2*.png combined_interval2_mut1.png
mv *png png_files

#mutant 2
python ../deepclip_scan.py -s AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCAACUACUCUAUAUCCCUCUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC -n Interval1_mut2 -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
python ../deepclip_scan.py -s ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUUAUCCCUCUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU -n Interval2_mut2 -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
convert +append *Interval1*.png combined_inteval1_mut2.png
convert +append *Interval2*.png combined_interval2_mut2.png
mv *png png_files

#both
python ../deepclip_scan.py -s AGCAAGAAAAGGAAAGAUCGAUUCGUUCUUUUACCAUUAUCCGGCUACUCUAUAUCCCUCUUUCGCCGAAGAAAAGAACUCUUCCAACUAAUUUUCACUC -n Interval1_mut_comb -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
python ../deepclip_scan.py -s ACUACUCUACACUCCUUUUUCGCCGAAGAAAAGAACUCUUCCGGCUAAUUUUUAUCCCUCUAAGCAUUUUUUUUUUUUACUUUUUUACAAGUCGUAUGUU -n Interval2_mut_comb -m $CHOSEN_MODEL -o Ssd1_deepclip_scan
convert +append *Interval1*.png combined_inteval1_mut_comb.png
convert +append *Interval2*.png combined_interval2_mut_comb.png
mv *png png_files

python ~/deepclip/DeepCLIP.py --runmode predict -P $CHOSEN_MODEL --sequences deepclip_scan_results/Ssd1_deepclip_scan/interval1.fasta --variant_sequences deepclip_scan_results/Ssd1_deepclip_scan/interval1_withmuts.fasta --predict_output_file png_files_final/interval1_predictions.tsv --draw_profiles
python ~/deepclip/DeepCLIP.py --runmode predict -P $CHOSEN_MODEL --sequences deepclip_scan_results/Ssd1_deepclip_scan/interval1.fasta --variant_sequences deepclip_scan_results/Ssd1_deepclip_scan/interval1_withmuts.fasta --predict_output_file png_files_final/interval2_predictions.tsv --draw_profiles
