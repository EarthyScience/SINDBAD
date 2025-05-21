#!/bin/bash
#SBATCH --job-name=HyALL_ALL
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=17
#SBATCH --mem-per-cpu=500
#SBATCH --time=14:50:00
#SBATCH --array=0-9  # 10 jobs
#SBATCH -o /ptmp/lalonso/slurmOutput/HyALL_ALL-%A_%a.out

module load julia
export JULIA_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Define parameter ranges
nfolds=(1 2 3 4 5)
nlayers=(3 2)
neurons=(32)
batchsizes=(32)

# Calculate which combination to use based on SLURM_ARRAY_TASK_ID
id=$SLURM_ARRAY_TASK_ID
# Change the order to prioritize folds first
n_fold=$((id % ${#nfolds[@]}))
id=$((id / ${#nfolds[@]}))
n_layer=$((id % ${#nlayers[@]}))
id=$((id / ${#nlayers[@]}))
n_neuron=$((id % ${#neurons[@]}))
id=$((id / ${#neurons[@]}))
n_batch=$((id % ${#batchsizes[@]}))

# Get the actual parameter values
nfold=${nfolds[$n_fold]}
nlayer=${nlayers[$n_layer]}
neuron=${neurons[$n_neuron]}
batchsize=${batchsizes[$n_batch]}

echo "Running with: nfold=$nfold nlayer=$nlayer neuron=$neuron batchsize=$batchsize"
# Run the program with calculated parameters
julia --project --heap-size-hint=16G exp_hybridfALL_ALL_nfold.jl $nfold $nlayer $neuron $batchsize