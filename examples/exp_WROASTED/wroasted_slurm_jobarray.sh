#!/bin/bash
#SBATCH --job-name wroasted
#SBATCH -o ./run_logs/wroasted-%A_%a.o.log
#SBATCH -e ./run_logs/wroasted-%A_%a.e.log
#SBATCH -p work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-205%100

export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

/Net/Groups/BGI/scratch/skoirala/.juliaup/bin/julia --project=../exp_distri experiment_WROASTED_jobarray.jl