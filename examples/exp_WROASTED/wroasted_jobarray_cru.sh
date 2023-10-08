#!/bin/bash
#SBATCH --job-name c_wr
#SBATCH -o ./run_logs_cruj/wroasted-%A_%a.o.log
#SBATCH -e ./run_logs_cruj/wroasted-%A_%a.e.log
#SBATCH -p big
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3000
#SBATCH --array=1-205%205
#SBATCH --time=15-00:00:00
mkdir -p run_logs_cruj
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}
/Net/Groups/Services/HPC_22/apps/julia/julia-1.9.2/bin/julia --project=../exp_distri --heap-size-hint=5G WROASTED_jobarray_cruj.jl
# /Net/Groups/BGI/scratch/skoirala/.juliaup/bin/julia --project=../exp_distri --heap-size-hint=2G experiment_WROASTED_jobarray.jl