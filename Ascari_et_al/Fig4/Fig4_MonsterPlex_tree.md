## Build Maximum Likelihood Tree from MonsterPlex data
1. Use bowtie2 and GATK to align MonsterPlex reads and call genotypes:
```bash
for f in `ls MPreads/*.gz`; do sbatch BWT2-GATK.sh Guy11 MPreads $f; done
```
2. Use MP script to extract genotypes at target sites and identify additional informative variants:
```bash
```
4. Run RAxML with 100 bootstrap replications:
```bash
raxml -T 4 -p 22703 -f a -x 22703 -s MonsterPlexExt_final_align.fasta -n MonsterPlexExt_final_align -m GTRGAMMA -# 100
```
5. Write support values to nodes:
```bash
raxml -T 2 -f b -m GTRGAMMA -n outSupport -t RAxML_bestTree.MonsterPlexExt_final_align.raxml -z RAxML_bootstrap.MonsterPlexExt_final_align.raxml 
```
6. Use the RAxML.bipartitions.outSupport file as input to [Fig4_Ascari_MPLEX_tree.R](/Ascari_et_al/scripts/Fig4_Ascari_MPLEX_tree.R) tree building script.
7. Modify figure in Illustrator to re-annotate legends, re-draw some clade highlights, and re-position clade labels
