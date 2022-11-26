## Build Maximum Likelihood Tree from MonsterPlex data
1. Use bowtie2 and GATK to align MonsterPlex reads and call genotypes:
```bash
for f in `ls MPreads/*.gz`; do sbatch BWT2-GATK.sh Guy11 MPreads $f; done
```
2. Use MP script to extract genotypes at target sites and identify additional informative variants
