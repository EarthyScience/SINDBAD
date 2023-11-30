#!/bin/bash
#SBATCH --job-name e_wr
#SBATCH -o ./run_logs_erai/wroasted-%A_%a.o.log
#SBATCH -e ./run_logs_erai/wroasted-%A_%a.e.log
#SBATCH -p gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3000
#SBATCH --array=1-205%205
#SBATCH --time=06-00:00:00
# mkdir -p run_logs_erai
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}
/Net/Groups/Services/HPC_22/apps/julia/julia-1.9.2/bin/julia --project=../exp_graf --heap-size-hint=5G WROASTED_params_erai.jl