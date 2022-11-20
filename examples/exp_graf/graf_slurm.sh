#!/bin/bash
#SBATCH --job-name graf
#SBATCH -o ./graf-%A.o.log
#SBATCH -e ./graf-%A.e.log
#SBATCH -p big
#SBATCH --ntasks=48
#SBATCH --cpus-per-task=1
#SBATCH --mem=128GB
#SBATCH --time=2-00:00:00

module load julia/1.8.1

export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

julia --project=../exp_distri pmap_tmp.jl


# # SBATCH --ntasks=1
# # SBATCH --cpus-per-task=64
