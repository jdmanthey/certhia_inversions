#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=filter
#SBATCH --nodes=1 --ntasks=1
#SBATCH --partition quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-6

# define input files from helper file during genotyping
input_array=$( head -n${SLURM_ARRAY_TASK_ID} vcf_list.txt | tail -n1 )

# define main working directory
workdir=/lustre/scratch/jmanthey/07_certhia_inversions

# filter out indels and sites covered by less than 50% of individuals and max 2 alleles per site
vcftools --vcf ${workdir}/03_vcf/${input_array} --max-missing 0.5 --max-alleles 2 --remove-indels --recode --recode-INFO-all --out ${workdir}/12_filter/${input_array%.full.g.vcf}


# bgzip and tabix index files that will be subdivided into windows

#bgzip
bgzip ${workdir}/12_filter/${input_array%.full.g.vcf}.recode.vcf

#tabix
tabix -p vcf ${workdir}/12_filter/${input_array%.full.g.vcf}.recode.vcf.gz

