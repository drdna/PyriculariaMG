## Figure 2A: CH7BAC9 Phylogeny

1. Use [CAP3](https://doua.prabi.fr/software/cap3) to merge forward and reverse sequences from CH7BAC9 PCR products:
```bash
# move fwd reads into F directory
mkdir CAP3F
cp CH7BAC9_F/*seq CAP3F
# move rev reads into R directory
mkdir CAP3R
cp CH7BAC9_R/*seq CAP3R
mkdir CH7BAC9_MERGE
mv CAP3F CH7BAC9_MERGE
mv CAP3R CH7BAC9_MERGE
cd CH7BAC9_MERGE
# add directionality to read headers and then merge F and R reads into individual .fasta files
for f in `ls CAP3F`; do sed 's/F\.ab1/\.ab1F/' CAP3F/$f >> ${f/seq/fasta}; done
for f in `ls CAP3R`; do sed 's/R\.ab1/\.ab1R/' CAP3R/$f >> ${f/seq/fasta}; done
# run CAP3 on merged .fasta files
for f in `ls *fasta`; do cap3 $f; done
# concatenate merged .fastas into single .fasta file
for f in `ls *contigs | awk -F '.' '{print $1}'`; do sed "s/>Contig1/>$f/" $f*contigs >> CH7BAC9_PCR.fasta; done
```
4. Extract CH7BAC9 sequences from genome assemblies using [Create_ortholog_datasets.pl](/Ascari_et_al/scripts/Create_ortholog_datasets.pl):
```bash
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
10. Build tree using [Fig2A_CH7BAC9_tree.R](/Ascari_et_al/Fig2/Fig2A_CH7BAC9_tree.R) script:

![Fig2A_CH7BAC9.png](/Ascari_et_al/Fig2/Fig2A_CH7BAC9.png)

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
4. Use [Fig2B_MPG1 Tree.R](/Ascari_et_al/scripts/Fig2B_MPG1_tree.R) script to produce the tree and manually edit in Illustrator.
![/Fig2B](/Ascari_et_al/Fig2/Fig2B_MPG1_tree.png)

## Figure 3. Creation of maximum likelihood tree for MonsterPlex data

1. Reads were aligned to the B71 reference genome and haplotypes were called using the BWT2-GATK.sh script:
```bash
for f in `ls RAW_READS/*fq.gz | awk -F '[/.]' '{print $2}'`; do sbatch $script/BWT2-GATK.sh 70-15.fasta RAW_READS $f; done
```
2. Generated .fasta files for MonsterPlex data (reorder from gene ID-based coordinates [MGG] to chromosome/position-based):
```bash
perl MonsterPlex2Fasta.pl 70-15.fasta MPLEX_VCFs MonsterPlexSites MPlexGenotypes
```
3. Interrogate the new SNPs file and add new variant positions to the SNP sites list:
```bash
cat MPtestdir/MP_new_sites0.txt MonsterPlexSites > AllMonsterPlexVarSites
```
4. Re-run the script to generate a .fasta file covering all variant positions with sufficient coverage:
```bash
perl MonsterPlex2Fasta.pl 70-15.fasta MPLEX_VCFs AllMonsterPlexVarSites MPlexGenotypes
```
5. Retrieve MonsterPlex target sites from genome assemblies:
```bash
perl MonsterPlex_sitesv3.pl 70-15.B71v2sh.map AllMonsterPlexVarSites B71v2sh_SNPs > MonsterPlex_genomes.fasta
```
6. Combine datasets:
```bash
cat MonsterPlexData.fasta MonsterPlex_genomes.fasta > MonsterPlex_combined.fasta
```
7. Align sequences with MUSCLE:
```bash
muscle3.8.31_i86darwin64 -in MonsterPlex_annotated.fasta -out MonsterPlex_final_align.fasta
```
Fasta file: [MonsterPlex_final_align.fasta](/Ascari_et_al/data/MonsterPlex_final_align.fasta).

8. Create maximum likelihood tree using RAxML:
```bash
raxml -T 4 -p 48556 -f a -x 48556 -s MonsterPlex_final_align.fasta -n MonsterPlex_final_align.raxml -m GTRGAMMA -# 100
```
9. Add support values to nodes
```bash
raxml -T 2 -f b -m GTRGAMMA -n outSupport -t RAxML_bestTree.MonsterPlex_final_align.raxml -z RAxML_bootstrap.MonsterPlex_final_align.raxml
```
10. Create tree using [Fig3_MPLEX_tree.R](/Ascari_et_al/scripts/Fig3_MPLEX_tree.R).

![Fig3.Ascari_et_al.tiff](/Ascari_et_al/Fig4/Fig4.Ascari_et_al.tiff)
