#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=cat
#SBATCH --partition quanah
#SBATCH --nodes=1 --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

grep "#" Ca_0001_Tg_2__a.g.vcf > Ca_0001_Tg_2.full.g.vcf
for i in $( ls Ca_0001_Tg_2__*vcf ); do echo $i; grep -v "#" $i >> Ca_0001_Tg_2.full.g.vcf; done
for i in $( ls Ca_0001_Tg_2b__*vcf ); do echo $i; grep -v "#" $i >> Ca_0001_Tg_2.full.g.vcf; done

grep "#" Ca_0002_Tg_1__a.g.vcf > Ca_0002_Tg_1.full.g.vcf
for i in $( ls Ca_0002_Tg_1__*vcf ); do echo $i; grep -v "#" $i >> Ca_0002_Tg_1.full.g.vcf; done
for i in $( ls Ca_0002_Tg_1b__*vcf ); do echo $i; grep -v "#" $i >> Ca_0002_Tg_1.full.g.vcf; done

grep "#" Ca_0003_Tg_3__a.g.vcf > Ca_0003_Tg_3.full.g.vcf
for i in $( ls Ca_0003_Tg_3__*vcf ); do echo $i; grep -v "#" $i >> Ca_0003_Tg_3.full.g.vcf; done
for i in $( ls Ca_0003_Tg_3b__*vcf ); do echo $i; grep -v "#" $i >> Ca_0003_Tg_3.full.g.vcf; done

grep "#" Ca_0005_Tg_1A__a.g.vcf > Ca_0005_Tg_1A.full.g.vcf
for i in $( ls Ca_0005_Tg_1A__*vcf ); do echo $i; grep -v "#" $i >> Ca_0005_Tg_1A.full.g.vcf; done

grep "#" Ca_0006_Tg_4__a.g.vcf > Ca_0006_Tg_4.full.g.vcf
for i in $( ls Ca_0006_Tg_4__*vcf ); do echo $i; grep -v "#" $i >> Ca_0006_Tg_4.full.g.vcf; done

grep "#" Ca_0008_Tg_7__a.g.vcf > Ca_0008_Tg_7.full.g.vcf
for i in $( ls Ca_0008_Tg_7__*vcf ); do echo $i; grep -v "#" $i >> Ca_0008_Tg_7.full.g.vcf; done
