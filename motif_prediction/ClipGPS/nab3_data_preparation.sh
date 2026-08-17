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
