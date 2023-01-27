# PyriculariaMG
Code and Data for Analyzing Pyricularia population in Minas Gerais

## Figure 2A: CH7BAC9 Phylogeny

1. Use [CAP3](https://doua.prabi.fr/software/cap3) to merge forward and reverse sequences from CH7BAC9 PCR products:
```bash
mkdir CH7BAC9_MERGE
mv CH7BAC9F_seqs CH7BAC9_MERGE
mv CH7BAC9R_seqs CH7BAC9_MERGE
cd CH7BAC9_MERGE
for f in `ls CH7BAC9F_seqs/*.seq`; do mv $f ${f/seq/Fseq}; mkdir ${f/\.seq/}; mv ${f/seq/Fseq} ${f/\.seq/}/; done
for f in `ls CH7BAC9R_seqs/*.seq`; do mv $f ${f/seq/Rseq}; mv ${f/seq/Rseq} ${f/\.seq/}/; done
for f in `ls -d`; do cap3 $f; done
for f in `ls *contigs | awk -F '.' '{print $1}`; do sed 's/>contig1/>$f/ >> CH7BAC9_PCR.fasta; done
```
4. Extract CH7BAC9 sequences from genome assemblies using [Create_ortholog_datasets.pl](/scripts/reate_ortholog_datasets.pl):
5. ```bash
perl Create_ortholog_datasets.pl MASKED_GENOMES B71_ch7bac9.fasta
```
5. Merge the two datasets:
```bash
cat CH7BAC9_PCR.fasta CH7BAC9_genomic.fasta > CH7BAC9_all.fasta
```
6. Use MUSCLE to align the sequences:
```bash
./muscle3.8.31_i86darwin64 -in CH7BAC9_all.fasta -out CH7BAC9_all_align.fasta
```
7. Run maximum likelihood analysis:
```bash
mkdir Ascari_et_al
mv CH7BAC9_all_align.fasta Ascari_et_al_CH7BAC9_final_align.fasta
cd Ascari_et_al
raxml -T 2 -p 74517 -f a -x 74517 -s ./Ascari_et_al_CH7BAC9_final_align.fasta -n Ascari_et_al_CH7BAC9_final_align.raxml -m GTRGAMMA -# 1000 
```
8. Add bootstrap values to node labels:
```bash
raxml -T 2 -f b -m GTRGAMMA -n outSupport -t RAxML_bestTree.Ascari_et_al_CH7BAC9_final_align.raxml -z RAxML_bootstrap.Ascari_et_al_CH7BAC9_final_align.raxml
```
9. Rename output file with descriptive name:
```bash
mv bipartitions.outSupport CH7BAC9_RAxML_bipartitions.outSupport
```
10. Build tree using [Fig2A_CH7BAC9_tree.R](Fig2/Fig2A_CH7BAC9_tree.R) script:

# Figure 2B: Species Identification Using MPG1 Sequences

1. Align sequences using MUSCLE:
```bash
muscle -in Ascari_Cen_Dig.fasta -out Ascari_Cen_Dig_align.fasta
```
2. Use RAxML to build maximum likelihood tree with support values:
```bash
raxml -T 2 -p 85776 -f b -z RAxML_bipartitions.Ascari_Cen_Dig_align.raxml -t RAxML_bestTree.Ascari_Cen_Dig_align.raxml -s ./Ascari_Cen_Dig_align.fasta -m GTRGAMMA -n support 
```
3. Rename tree file with more descriptive title:
```bash
mv RAxML_bestTree.Ascari_Cen_Dig_align.raxml.raxml.support MPG1_RAXML_bestTree.support
```
4. Use [Fig2B_MPG1 Tree.R](/Fig2/Fig2B_MPG1_tree.R) script to produce the tree.

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
