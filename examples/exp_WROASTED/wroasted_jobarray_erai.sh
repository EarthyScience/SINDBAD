#!/bin/bash
#SBATCH --job-name e_wr
#SBATCH -o ./tmp_run_logs_erai/wroasted-%A_%a.o.log
#SBATCH -e ./tmp_run_logs_erai/wroasted-%A_%a.e.log
#SBATCH -p gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem-per-cpu=12G
#SBATCH --array=1-205%10
#SBATCH --time=06-00:00:00
# mkdir -p tmp_run_logs_erai
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}
sleep $SLURM_ARRAY_TASK_ID
/Net/Groups/Services/HPC_22/apps/julia/julia-1.11.2/bin/julia --project=../exp_WROASTED --heap-size-hint=12G WROASTED_jobarray_erai.jl