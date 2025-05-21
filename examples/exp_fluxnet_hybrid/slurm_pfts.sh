#!/bin/bash
#SBATCH --job-name=pfts_hybrid
#SBATCH -p gpu                       # Send to GPU partition
#SBATCH --nodelist=node-r6-he13      # Specify the node with A40 or A100 GPUs
#SBATCH --ntasks=8                  # Total number of tasks
#SBATCH --cpus-per-task=20           # 20 CPUs per task
#SBATCH --mem-per-cpu=500            # 500 MB per CPU
#SBATCH --time=12:10:00              # 10 minutes runtime

# telling slurm where to write output and error
#SBATCH -o /Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fPFTs_slurm-%A_%a.out

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
julia --project --heap-size-hint=16G exp_hybridfPFT.jl
