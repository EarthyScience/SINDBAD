#!/bin/bash
#SBATCH --job-name graf
#SBATCH -o ./graf-%A.o.log
#SBATCH -e ./graf-%A.e.log
#SBATCH -p gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=128GB
#SBATCH --time=2-00:00:00

module load julia

export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

/Net/Groups/Services/HPC_22/apps/julia/julia-1.10.0/bin/julia --project=../exp_graf --heap-size-hint=16G experiment_graf.jl
