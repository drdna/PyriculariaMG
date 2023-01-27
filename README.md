# PyriculariaMG
Code and Data for Analyzing Pyricularia population in Minas Gerais

## Figure 3. Creation of maximum likelihood tree for MonsterPlex data

1. Reads were aligned to the B71 reference genome and haplotypes were called using the BWT2-GATK.sh script:
```bash
for f in `ls RAW_READS/*fq.gz | awk -F '[/.]' '{print $2}'`; do sbatch $script/BWT2-GATK.sh 70-15.fasta RAW_READS $f; done
```
2. Generated .fasta files for MonsterPlex data (reorder from gene ID-based coordinates [MGG] to chromosome/position-based):
```bash
perl MonsterPlex2Fasta_noMGG.pl 70-15.fasta MPcoverage.bed MPLEX_VCFs > MonsterPlexData.fasta
```
3. Retrieved MonsterPlex target sites from genome assemblies:
```bash
perl MonsterPlex_sitesv3.pl 70-15.B71.map AllMonsterPlexVarSites B71v2sh_SNPs > MonsterPlex_genomes.fasta
```
4. Create aligned sequences:
```bash
cat MonsterPlexData.fasta MonsterPlex_genomes.fasta > MonsterPlex_final.fasta
muscle3.8.31_i86darwin64 -in MonsterPlex_final.fasta -out MonsterPlex_final_align.fasta
```
Fasta file: [MonsterPlex_final_align.fasta](/Ascari_et_al/data/MonsterPlex_final_align.fasta)

5. Create maximum likelihood tree using RAxML:
```bash
raxml -T 4 -p 48556 -f a -x 48556 -s MonsterPlex_final_align.fasta -n MonsterPlex_final_align.raxml -m GTRGAMMA -# 100
```
6. Add support values to nodes
```bash
raxml -T 2 -f b -m GTRGAMMA -n outSupport -t RAxML_bestTree.MonsterPlex_final_align.raxml -z RAxML_bootstrap.MonsterPlex_final_align.raxml
```
7. Create tree using Fig4_Ascari_MPLEX_tree.R.

![Fig4.Ascari_et_al.tiff](/Ascari_et_al/Fig4/Fig4.Ascari_et_al.tiff)
