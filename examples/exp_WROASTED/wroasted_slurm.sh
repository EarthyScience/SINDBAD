#!/bin/bash
#SBATCH --job-name wroasted
#SBATCH -o ./wroasted-%A.o.log
#SBATCH -e ./wroasted-%A.e.log
#SBATCH -p big
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

module load julia/1.7.3

export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

julia --project=../ experiment_WROASTED.jl