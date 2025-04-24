#!/bin/bash
#SBATCH --job-name InSZ_PF
#SBATCH -o ./tmp_run_logs/InSZ_PF-%A_%a.o.log
#SBATCH -e ./tmp_run_logs/InSZ_PF-%A_%a.e.log
#SBATCH -p gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=34
#SBATCH --mem-per-cpu=12G
#SBATCH --array=1-205%50
#SBATCH --time=07-00:00:00
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}
sleep $SLURM_ARRAY_TASK_ID

/Net/Groups/Services/HPC_22/apps/julia/julia-1.11.4/bin/julia --project=../exp_WROASTED --heap-size-hint=12G exp_fluxnet_zarr_PF.jl