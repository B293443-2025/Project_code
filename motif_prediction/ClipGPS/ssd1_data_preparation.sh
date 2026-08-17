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
