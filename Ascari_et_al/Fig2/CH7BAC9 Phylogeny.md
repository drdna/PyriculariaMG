# CH7BAC9 Phylogeny

1. Merge forward and reverse sequences from CH7BAC9 PCR products:
2. ```bash

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
