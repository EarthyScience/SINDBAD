module HybridSindbad

using Reexport: @reexport
using SindbadTEM
#using OptimizeSindbad
using Flux
using Optimisers
using ForwardDiff
using Zygote
using Statistics
using ProgressMeter
using PreallocationTools

using Base.Iterators: repeated, partition
using Random

include("iter_tools.jl")
include("nn_dense.jl")
include("site_loss.jl")
include("gradients.jl")
include("exMachina.jl")

#@reexport using ForwardSindbad
#@reexport using OptimizeSindbad: get_loc_loss, loc_loss, loc_loss_inner

end # module HybridSindbad
