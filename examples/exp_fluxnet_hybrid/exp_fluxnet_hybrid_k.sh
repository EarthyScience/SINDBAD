#!/bin/bash
#SBATCH --job-name hyK
#SBATCH -o ./hyK-%A.o.log
#SBATCH -e ./hyK-%A.e.log
#SBATCH -p gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem-per-cpu=12G
#SBATCH --time=07-00:00:00
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}
/Net/Groups/Services/HPC_22/apps/julia/julia-1.11.4/bin/julia --project=../exp_WROASTED --heap-size-hint=12G exp_fluxnet_hybrid_k.jl