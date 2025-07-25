#!/bin/bash
#SBATCH --job-name MODIS_FIRES
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=27G
#SBATCH --time=00:55:00
#SBATCH --array=1-268

# telling slurm where to write output and error
#SBATCH -o /Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/events-%A_%a.out

# if needed load modules here
module load proxy
module load julia

# if needed add export variables here
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

################
#
# run the program
#
################
sleep $SLURM_ARRAY_TASK_ID
julia --project --heap-size-hint=50G fill_skeleton_zarr.jl $SLURM_ARRAY_TASK_ID