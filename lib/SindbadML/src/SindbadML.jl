"""
    SindbadML

This module provides the tools to train neural networks to predict model parameters from `process-based models (PBMs)` using automatic differentiation and finite differences. It also includes functions to train PBMs using a mixed gradient approach to optimize the neural network weights and the PBM parameters simultaneously.

::: danger

This module is still under development and is not yet ready for production use.

:::

"""
module SindbadML

using Distributed:
    nworkers,
    pmap,
    workers,
    nprocs,
    CachingPool

using Reexport: @reexport
using SindbadTEM
using SindbadData.YAXArrays
using SindbadData.Zarr
using SindbadData.AxisKeys
using SindbadData: AllNaN
using Flux
using Optimisers
using FiniteDiff
using FiniteDifferences
using ForwardDiff
using PolyesterForwardDiff
using Zygote
using Statistics
import ProgressMeter: @showprogress, Progress, next!, progress_pmap, progress_map
using PreallocationTools
using Base.Iterators: repeated, partition
using Random
using JLD2

include("utilsML.jl")
include("diffCaches.jl")
include("neuralNetwork.jl")
include("trainPBM.jl")

end
