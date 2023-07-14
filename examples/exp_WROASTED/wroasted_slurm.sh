#!/bin/bash
#SBATCH --job-name wroasted
#SBATCH -o ./wroasted-%A.o.log
#SBATCH -e ./wroasted-%A.e.log
#SBATCH -p big
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

/Net/Groups/BGI/scratch/skoirala/.juliaup/bin/julia --project=../exp_distri experiment_WROASTED.jl