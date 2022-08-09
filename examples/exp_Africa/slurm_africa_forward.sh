#!/bin/bash
#SBATCH --job-name julia
#SBATCH -o ./af-forw-%A.o.log
#SBATCH -p big
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=5120


module load julia/1.7.3

export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

julia --project=../ experiment_forward_Africa_slurm.jl