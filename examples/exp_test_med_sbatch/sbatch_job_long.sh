#!/bin/bash
#SBATCH --job-name hybrid_long
#SBATCH -p work
#SBATCH --ntasks=17
#SBATCH --cpus-per-task=1

# setting memory requirements
#SBATCH --mem-per-cpu 10G

# propagating max time for job to run
# ##SBATCH --time <days-hours:minute:seconds>
# ##SBATCH --time <hours:minute:seconds>
#SBATCH --time 6-23:00:00

# Setting the name for the job
# #SBATCH --job-name hybrid_long

# setting notifications for job
# accepted values are ALL, BEGIN, END, FAIL, REQUEUE
# #SBATCH --mail-type END

# telling slurm where to write output and error
#SBATCH -o /Net/Groups/BGI/scratch/lalonso/SindbadRuns/output_sindbad_slurm-%a.out
##SBATCH -e outputn-%A_%a.err

# dont access /home after this line

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

julia --project --heap-size-hint=7G main_job_long.jl