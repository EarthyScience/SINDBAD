#!/bin/bash
#SBATCH --job-name=forward
#SBATCH --ntasks=30                  # Total number of tasks
#SBATCH --cpus-per-task=4            # 4 CPUs per task
#SBATCH --mem-per-cpu=3GB            # 3GB per CPU
#SBATCH --time=23:10:00              # 10 minutes runtime

# telling slurm where to write output and error
#SBATCH -o /Net/Groups/BGI/tscratch/lalonso/SindbadOutput/f_pfts_again2_slurm-%A_%a.out

# if needed load modules here
module load proxy
module load julia/1.11

# if needed add export variables here
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

################
#
# run the program
#
################
julia --project --heap-size-hint=16G exp_hybrid_pfts_forward.jl
