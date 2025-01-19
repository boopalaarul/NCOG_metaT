This file describes how totalRNA data was created. Can see that "filtered" refers to removal of Spike contigs.

---

#summary of NCOG merged assembliy and annotation
Paths to the analysis data (archive) and the filtered post-RAP annotation data are given at the end. I have summarized below the important analysis details and the observations on the results.

Preprocessing:
- for the new 2019 (run2) and 2020 sequences, used a single-step fastp-trimmomatic commands to remove both low quality and read-through primers/adapters - thus replacing separate 'qtrim' and 'primers' steps of the existing RAP workflow. This approach is ideal for large data sets since it is much faster and better or equal in the processing efficiency and accuracy. The summary stats of trimming for each library can be found in 'seq_QC_reports' folder in each of the parent directories: ncog_rap_2019/ and ncog_rap_2020/ (see paths under Data below).
- used bbduk/sortmerna programs to separate rRNA from non-rRNA sequences. Both yielded similar output. However, when compared to bbduk, sortmerna often fails if input sequences contain high-level of rRNA contamination. Thus, I had to use bbduk for 2019 data, majority of which contain rRNA while 2020 set worked with sortmerna even though it has more sequence depth. See the attached files for relative rRNA and nonrRNA levels in both sets. About ~90% of 2019 data is rRNA when compared to nonrRNA, the reverse is true for 2020 sequences. I recommend bbduk as the go-to tool for rRNA filtering in future analyses.
- I did not process reads from Spike1 and 8 standards at this stage since it is not very efficient to do so (this was addressed post-assembly).

Assembly and merging:
- as done previously, assembly for both datasets was performed using RAP workflow - by library, by groups (Rob's lists) and global in that order.
- used transabyss-merge program for merging the previously generated global assembly contigs from 2014-2018 samples with the newly generated global contigs from 2019 and 2020 data. Tested two different KMER settings in separate analysis: '--mink 23 --maxk 31' for more sensitivity and '--mink 31 --maxk 63' for more specificity to aid in the merging the overlapping contigs. However, both yielded the same number of merged contigs. I used the merged contigs contigs from the former for the annotation. There were ~6 million (6,097,544) contigs after merging the three separate assemblies (4,961,045 (2014-18) +  197,729 (2019_2nd_run) + 1,275,740 (2020) =  6,434,514) with 336,970 fewer contigs than the input. Such (low) level of merging may be result of the fragmented, error-containing contigs in the metagenomic pool. Note: In the merged assembly, the contig names from the older assembly (2014-18) are prefixed with 'NCOG_2014-18 and those from the new (2019_run2 and 2020) are prefixed with 'NCOG_2020'.

ORFs:
- used FragGeneScan program to identify ORFs from the merged contigs: there were ~12 million delineated ORFs in both orientations (12,093,635). since this is a large number, I wanted to see if they could be further collapsed into highly similar clusters (with >=95% similarity) at ORF sequence level using cd-hit. I performed this analysis using both protein and nucleotide ORF sequences. The nucleotide level clustering worked better than at protein level in this case as there are many ambiguous (*) AA calls due to frameshift errors. I decided it is prudent not to pre-filter the contigs at this stage (prior to annotation) leaving the option to do so post-annotation even though it meant a much longer processing time.

Annotation:
- used the RAP workflow as before. However, I have used the most recently released (updated) KEGG gene database for annotation in addition to the existing phyloDB database.
- removed all the contigs with significant matches to the Spike 1 and 8 reference sequences prior to annotation. Added the the Spike references to the contigs for mapping the reads.
- read-mapping took the most time in this analysis (~12 days for mapping the reads on the grid from all 558 libraries to ~12 million ORFs). Need to verify if bowtie2/salmon workflow might be a speedier and more importantly accurate option in place of clc_mapper tool.
- the file 'filter_annotations.txt' has the breakdown of contig numbers for the filter categories.

Post-annotation:
- used filtered contigs (annotatio_all.filtered.tab) for adding the taxonomic group and species-level information to each ORF (added to the annotation table in the last few columns).
- the post annotation files, in addition to the unclustered ORFs, include cd-hit clustered (reduced) subset which have the label 'cdhit0.95' in their names.
- generated a summary tables for the cumulative group and species level total read and ORF counts (summing counts from all ORFs in the annotation set). These files are named 'organism_group_counts.txt' and 'species_read_and_orf_count_summary.tab' in the post-rap directory (also attached here). There is a also file named 'Diatom.contigs.txt' in the post-rap folder which contains contig list associated with 'Diatoms' annotation.

Data:
#Archive area: input and analysis directories:

#separate assemblies
/usr/local/archdata/0568/projects/PLANKTON_archive/pratap/NCOG/NCOG_RNASeq_merged_2014-2018-2019-2020_assemblies/ncog_rap_2019/run_RAP/
/usr/local/archdata/0568/projects/PLANKTON_archive/pratap/NCOG/NCOG_RNASeq_merged_2014-2018-2019-2020_assemblies/ncog_rap_2020/run_RAP/

#all NCOG merged assembly and annotations
/usr/local/archdata/0568/projects/PLANKTON_archive/pratap/NCOG/NCOG_RNASeq_merged_2014-2018-2019-2020_assemblies/merge_2014-18_2019_2020_assemblies/

#Project area directory: only annotation files.
/usr/local/projdata/0568/projects/PLANKTON/illumina_aallen/pratap/NCOG_RNASeq/merged_2014-18_2019_2020_assembly_contigs_and_annotations/
