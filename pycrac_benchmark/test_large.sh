#!/usr/bin/env bash
echo
echo "##### testing all pyCRAC tools #####"
echo
# echo "# pyBarcodeFilter.py..."
# echo "...demultiplexing illumina indexes"
# python ../pyCRAC/pyBarcodeFilter.py -f test_f.fastq -r test_r.fastq -b indexes.txt -i -m 1
# echo "...demultiplexing illumina indexes on compressed files"
# python ../pyCRAC/pyBarcodeFilter.py -f test_f.fastq.gz -r test_r.fastq.gz -b indexes.txt -i -m 1 --file_type=fastq.gz
# echo "...demultiplexing random barcodes in 5' adapter"
# python ../pyCRAC/pyBarcodeFilter.py -f test_f_dm.fastq -r test_r_dm.fastq -b barcodes.txt -m 1
# echo "...demultiplexing random barcodes in 5' adapter on compressed data and compressing output files"
# python ../pyCRAC/pyBarcodeFilter.py -f test_f_dm.fastq -r test_r_dm.fastq -b barcodes.txt -m 1 --gz
echo "# pyReadCounters..."
echo "...range 300 and deletions only"
python ../pyCRAC/pyReadCounters.py -f test.novo -r 300 --mutations=delsonly --discarded=pyReadCounters_discarded.txt --rpkm -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "...same as above but counting hits for introns only"
python ../pyCRAC/pyReadCounters.py -f test.novo -r 300 --mutations=delsonly --discarded=pyReadCounters_discarded.txt --rpkm -a protein_coding --hittable -s intron -o test_intron -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "...same as above but now counting hits in exons only"
python ../pyCRAC/pyReadCounters.py -f test.novo -r 300 --mutations=delsonly --discarded=pyReadCounters_discarded.txt --rpkm -a protein_coding --hittable -s exon -o test_exon -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "# pyClusterReads..."
python ../pyCRAC/pyClusterReads.py -f test_count_output_reads.gtf -r 300 --cic=5 --ch=5 --co=5 --mutsfreq=10 -o test_count_output_clusters.gtf -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
# echo "...counting overlap between clusters and genomic features"
# python ../pyCRAC/pyReadCounters.py -f test_count_output_clusters.gtf --file_type=gtf -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf 
echo "# pyMotif..."
echo "...with range setting"
python ../pyCRAC/pyMotif.py -f test_count_output_clusters.gtf -r 300 -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "...with annotation = protein_coding"
python ../pyCRAC/pyMotif.py -f test_count_output_clusters.gtf -a protein_coding -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "# pyBinCollector..."
echo "...with annotation = protein_coding"
python ../pyCRAC/pyBinCollector.py -f test_count_output_clusters.gtf -a protein_coding -n 50 -o test_count_output_protein_coding_50.pileup -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "...with all annotations"
python ../pyCRAC/pyBinCollector.py -f test_count_output_clusters.gtf -n 50 -o test_count_output_all_50.pileup -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "...with --binoverlap flag"
python ../pyCRAC/pyBinCollector.py -f test_count_output_clusters.gtf -n 50 --binoverlap 1 5 -o test_count_output_selected_1_5.gtf -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "...with --outputall flag"
python ../pyCRAC/pyBinCollector.py -f test_count_output_clusters.gtf -n 50 --outputall -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf
echo "# pyPileup..."
echo "...with genes list"
python ../pyCRAC/pyPileup.py -f test.novo -g genes.list --limit=1000 --discarded=pyPileup_discarded.txt -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "...with genes list and removal of duplicates"
python ../pyCRAC/pyPileup.py -f test.novo -g genes.list --limit=1000 --blocks -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "...with chromosome coordinates"
python ../pyCRAC/pyPileup.py -f test.novo --chr test_coordinates.txt --limit=1000 -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "...with chromosome coordinates and removal of duplicates"
python ../pyCRAC/pyPileup.py -f test.novo --chr test_coordinates.txt --limit=1000 --blocks -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "# pyReadAligner..."
echo "...with chromosome coordinates"
python ../pyCRAC/pyReadAligner.py -f test.novo --chr test_coordinates.txt --limit=1000 --discarded=pyReadAligner_discarded.txt -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "...with genes list and mutation filtering"
python ../pyCRAC/pyReadAligner.py -f test.novo -g genes.list --limit=500 --mutations=delsonly -v --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf --tab=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75.fa.tab
echo "# pyCalculateFDRs..."
python ../pyCRAC/pyCalculateFDRs.py -f test_count_output_reads.gtf -r 200 -o test_count_output_FDRs_005.gtf -v -m 0.05 --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
# echo "# regression: verify jobs=1 vs jobs=2 reproducibility"
# python test_jobs_repro.py #empty file
echo "# pyCalculateMutationFrequencies..."
python ../pyCRAC/pyCalculateMutationFrequencies.py -i test_count_output_FDRs_005.gtf -r test_count_output_reads.gtf -o test_count_output_FDRs_005_with_muts.gtf --mutsfreq=20 -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo
echo "##### testing pyCRAC scripts #####"
echo
echo "# pyFastqJoiner.py..."
python ../pyCRAC/scripts/pyFastqJoiner.py -f test_f.fastq test_r.fastq -c "|" -o test_joined.fastq
echo "...with compressed data and output compression"
python ../pyCRAC/scripts/pyFastqJoiner.py -f test_f.fastq.gz test_r.fastq.gz --file_type=fastq.gz -c "|" --gz -o test_joined_compressed.fastq
echo "...with reverse-complementing the reverse read"
python ../pyCRAC/scripts/pyFastqJoiner.py -f test_f.fastq test_r.fastq --reversecomplement -c "|" -o test_reverse_joined.fastq
echo "# pyFastqDuplicateRemover.py..."
echo "...with single-end data"
python ../pyCRAC/scripts/pyFastqDuplicateRemover.py -f test_f.fastq -o test_f.fasta
echo "...with paired-end data"
python ../pyCRAC/scripts/pyFastqDuplicateRemover.py -f test_f.fastq -r test_r.fastq -o test
echo "# pyFastqSplitter.py..."
python ../pyCRAC/scripts/pyFastqSplitter.py -f test_joined.fastq -c "|" -o test_splitted
echo "...with compressed data"
python ../pyCRAC/scripts/pyFastqSplitter.py -f test_joined_compressed.fastq.gz --file_type=fastq.gz -c "|" -o test_compressed_splitted
echo "...with compressed data and compressing output"
python ../pyCRAC/scripts/pyFastqSplitter.py -f test_joined_compressed.fastq.gz --file_type=fastq.gz -c "|" -o test_compressed_splitted --gzip
echo "# pyCheckGTFfile.py..."
python ../pyCRAC/scripts/pyCheckGTFfile.py --gtf=test.gtf -o test_corrected.gtf
echo "# pyGetGTFSources.py..."
python ../pyCRAC/scripts/pyGetGTFSources.py --gtf=test.gtf -o test_gtf_sources.txt --count
echo "# pyGetGeneNamesFromGTF.py..."
python ../pyCRAC/scripts/pyGetGeneNamesFromGTF.py --gtf=test.gtf -a gene_name -o test_gtf_gene_names.txt --count
echo "# pyNormalizeIntervalLengths with various flags..."
python ../pyCRAC/scripts/pyNormalizeIntervalLengths.py -f test_count_output_FDRs_005.gtf -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt --fixed 20 -o test_count_output_FDRs_fixed_20.gtf -v
python ../pyCRAC/scripts/pyNormalizeIntervalLengths.py -f test_count_output_FDRs_005.gtf -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt --min 20 -o test_count_output_FDRs_min_20.gtf -v
python ../pyCRAC/scripts/pyNormalizeIntervalLengths.py -f test_count_output_FDRs_005.gtf -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt --addboth 20 -o test_count_output_FDRs_addboth_20.gtf -v
python ../pyCRAC/scripts/pyNormalizeIntervalLengths.py -f test_count_output_FDRs_005.gtf -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt --addleft 20 -o test_count_output_FDRs_addleft_20.gtf -v
python ../pyCRAC/scripts/pyNormalizeIntervalLengths.py -f test_count_output_FDRs_005.gtf -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt --addright 20 -o test_count_output_FDRs_addright_20.gtf -v
echo "# pyAlignment2Tab.py..."
python ../pyCRAC/scripts/pyAlignment2Tab.py -f sense-_PIC2_genomic_test.fasta -o sense-_PIC2_genomic_test.tab
echo "# pyExtractLinesFromGTF.py..."
python ../pyCRAC/scripts/pyExtractLinesFromGTF.py --gtf=test.gtf -g genes.list -o test_PIC2.gtf -a gene_name
echo "# pyGTF2bed.py..."
python ../pyCRAC/scripts/pyGTF2bed.py --gtf=test_count_output_reads.gtf -o test.bed -n test_gtf -d test_gtf --color red
echo "# pyGTF2bedGraph.py..."
echo "...default settings"
python ../pyCRAC/scripts/pyGTF2bedGraph.py --gtf=test_count_output_reads.gtf -o test_out -t reads -n test_gtf -d test_gtf -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "...normalized to hits per million"
python ../pyCRAC/scripts/pyGTF2bedGraph.py --gtf=test_count_output_reads.gtf -o test_out_norm --permillion -t reads -n test_gtf -d test_gtf -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "...start positions"
python ../pyCRAC/scripts/pyGTF2bedGraph.py --gtf=test_count_output_reads.gtf -o test_out_norm_5end --permillion -t startpositions -n test_gtf -d test_gtf -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "...end positions"
python ../pyCRAC/scripts/pyGTF2bedGraph.py --gtf=test_count_output_reads.gtf -o test_out_norm_3end --permillion -t endpositions -n test_gtf -d test_gtf -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "# pyGTF2sgr.py..."
echo "...default settings"
python ../pyCRAC/scripts/pyGTF2sgr.py --gtf=test_count_output_reads.gtf -o test_out -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "...normalized to hits per million"
python ../pyCRAC/scripts/pyGTF2sgr.py --gtf=test_count_output_reads.gtf -o test_out_norm --permillion -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "...start positions"
python ../pyCRAC/scripts/pyGTF2sgr.py --gtf=test_count_output_reads.gtf -o test_out_norm_5end --permillion -t startpositions -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "...end positions"
python ../pyCRAC/scripts/pyGTF2sgr.py --gtf=test_count_output_reads.gtf -o test_out_norm_3end --permillion -t endpositions -v -c GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_chr_lengths.txt
echo "# pyFilterGTF.py..."
python ../pyCRAC/scripts/pyFilterGTF.py -f test_count_output_reads.gtf -o test_sense_filtered_reads.gtf -a protein_coding --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf 
# echo "# pybed2GTF.py..."
# python ../pyCRAC/scripts/pybed2GTF.py --bed=test.bed -o test_bed2gtf.gtf --gtf=GSE276517_Saccharomyces_cerevisiae.R64-1-1.75_1.2.gtf 
echo "# pyFasta2tab.py..."
python ../pyCRAC/scripts/pyFasta2tab.py -f sense-_PIC2_genomic_test.fasta -o sense-_PIC2_genomic_test_f2a.tab
echo
echo "##### tests finished #####"
echo
