	options(scipen=999)
	project_directory <- "/lustre/scratch/jmanthey/07_certhia_inversions/12_filter"
	directory_name <- "13_make_fasta"
	cluster <- "quanah"
	max_number_jobs <- 400
	
	# read in reference index
	# filtered to only include genotyped chromosomes
	ref_index <- read.table("reduced.fai", stringsAsFactors=F)
	
	# define window size
	window_size <- 1000
	
	# make directories
	dir.create(directory_name)
	
	# define intervals and write to helper files
	helper1 <- list()
	helper2 <- list()
	helper3 <- list()
	counter <- 1
	for(a in 1:nrow(ref_index)) {
		a_start <- 1
		a_end <- a_start + window_size - 1
		a_max <- ref_index[a,2]
		a_windows <- ceiling((a_max - a_start) / window_size)
		a_chromosome <- ref_index[a,1]
		
		# loop for defining helper info for each window
		for(b in 1:a_windows) {
			if(b == a_windows) {
				a_end <- a_max
			}
			helper1[[counter]] <- a_chromosome
			helper2[[counter]] <- a_start
			helper3[[counter]] <- a_end

			a_start <- a_start + window_size
			a_end <- a_end + window_size
			counter <- counter + 1
		}
	}
	helper1 <- unlist(helper1)
	helper2 <- unlist(helper2)
	helper3 <- unlist(helper3)
	
	# calculate number of array jobs
	if(length(helper3) > max_number_jobs) {
		n_jobs_per_array <- ceiling(length(helper3) / max_number_jobs)
		n_array_jobs <- ceiling(length(helper3) / n_jobs_per_array)
	} else {
		n_array_jobs <- length(helper3)
		n_jobs_per_array <- 1
	}
	
	helper1 <- c(helper1, rep("x", n_jobs_per_array - length(helper3) %% n_jobs_per_array))
	helper2 <- c(helper2, rep(1, n_jobs_per_array - length(helper3) %% n_jobs_per_array))
	helper3 <- c(helper3, rep(1, n_jobs_per_array - length(helper3) %% n_jobs_per_array))
	length(helper3)
	write(helper1, file=paste(directory_name, "/helper_chrom.txt", sep=""), ncolumns=1)
	write(helper2, file=paste(directory_name, "/helper_start.txt", sep=""), ncolumns=1)
	write(helper3, file=paste(directory_name, "/helper_end.txt", sep=""), ncolumns=1)

	# write the array script
	a.script <- paste(directory_name, "/alignment_array.sh", sep="")
	write("#!/bin/sh", file=a.script)
	write("#SBATCH --chdir=./", file=a.script, append=T)
	write(paste("#SBATCH --job-name=", "fasta", sep=""), file=a.script, append=T)
	write("#SBATCH --nodes=1 --ntasks=2", file=a.script, append=T)
	write(paste("#SBATCH --partition ", cluster, sep=""), file=a.script, append=T)
	write("#SBATCH --time=48:00:00", file=a.script, append=T)
	write("#SBATCH --mem-per-cpu=8G", file=a.script, append=T)
	write(paste("#SBATCH --array=1-", n_array_jobs, sep=""), file=a.script, append=T)
	write("", file=a.script, append=T)
	write("module load intel R", file=a.script, append=T)
	write("", file=a.script, append=T)

	write("# Set the number of runs that each SLURM task should do", file=a.script, append=T)
	write(paste("PER_TASK=", n_jobs_per_array, sep=""), file=a.script, append=T)
	write("", file=a.script, append=T)
	
	write("# Calculate the starting and ending values for this task based", file=a.script, append=T)
	write("# on the SLURM task and the number of runs per task.", file=a.script, append=T)
	write("START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))", file=a.script, append=T)
	write("END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))", file=a.script, append=T)
	write("", file=a.script, append=T)
	
	write("# Print the task and run range", file=a.script, append=T)
	write("echo This is task $SLURM_ARRAY_TASK_ID, which will do runs $START_NUM to $END_NUM", file=a.script, append=T)
	write("", file=a.script, append=T)

	write("# Run the loop of runs for this task.", file=a.script, append=T)	
	write("for (( run=$START_NUM; run<=$END_NUM; run++ )); do", file=a.script, append=T)
	write("\techo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run", file=a.script, append=T)
	write("", file=a.script, append=T)
	
	write("\tchrom_array=$( head -n${run} helper_chrom.txt | tail -n1 )", file=a.script, append=T)
	write("", file=a.script, append=T)
	write("\tstart_array=$( head -n${run} helper_start.txt | tail -n1 )", file=a.script, append=T)
	write("", file=a.script, append=T)
	write("\tend_array=$( head -n${run} helper_end.txt | tail -n1 )", file=a.script, append=T)
	write("", file=a.script, append=T)
	
	# add header to output file
	header <- paste('\tgunzip -cd ', project_directory, '/Ca_0008_Tg_7.recode.vcf.gz | grep "#" > ', project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.recode.vcf", sep="")
	write(header, file=a.script, append=T)
	write("", file=a.script, append=T)
	
	#tabix command
	tabix_command <- paste("\ttabix ", project_directory, "/${chrom_array}.recode.vcf.gz ${chrom_array}:${start_array}-${end_array} >> ", project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.recode.vcf", sep="")
	write(tabix_command, file=a.script, append=T)
	write("", file=a.script, append=T)
	
	# bcftools command
	bcf_tools_command <- paste("\tbcftools query -f '%POS\\t%REF\\t%ALT[\\t%GT]\\n' ", project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.recode.vcf > ", project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.simple.vcf", sep="")
	write(bcf_tools_command, file=a.script, append=T)
	write("", file=a.script, append=T)
		
	# Rscript command for fasta creation
	rscript_command <- paste("\tRscript create_fasta.r ", project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.simple.vcf popmap_fasta.txt", sep="")
	write(rscript_command, file=a.script, append=T)
	write("", file=a.script, append=T)
		
	# remove unnecessary files at end
	write(paste("\trm ", project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.recode.vcf", sep=""), file=a.script, append=T)
	write(paste("\trm ", project_directory, "/windows/${chrom_array}__${start_array}__${end_array}.simple.vcf", sep=""), file=a.script, append=T)
		write("", file=a.script, append=T)
	
	# finish
	write("done", file=a.script, append=T)