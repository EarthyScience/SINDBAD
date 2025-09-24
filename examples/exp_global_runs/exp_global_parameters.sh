#!/bin/bash
#SBATCH --job-name=Params
#SBATCH --ntasks=10                  # Total number of tasks
#SBATCH --cpus-per-task=10            # 10 CPUs per task
#SBATCH --mem-per-cpu=3GB            # 3GB per CPU
#SBATCH --time=23:50:00              # 10 minutes runtime

# telling slurm where to write output and error
#SBATCH -o /Net/Groups/BGI/tscratch/lalonso/SindbadOutput/Params_slurm-%A_%a.out
