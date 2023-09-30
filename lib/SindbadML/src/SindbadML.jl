module SindbadML

using Distributed: @distributed, @sync
using SharedArrays: SharedArray

using Reexport: @reexport
#@everywhere 
using SindbadTEM
#using OptimizeSindbad
using Flux
using Optimisers
#@everywhere
using FiniteDiff
using ForwardDiff
using Zygote
using Statistics
using ProgressMeter
using PreallocationTools
using Base.Iterators: repeated, partition
using Random
using JLD2

include("iter_tools.jl")
include("nn_dense.jl")
include("gradients.jl")
include("site_loss.jl")

end # module SindbadML
