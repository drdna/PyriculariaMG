## Species Identification Using MPG1 Sequences
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
