module SindbadML

using Distributed: @distributed, @sync
using SharedArrays: SharedArray

using Reexport: @reexport
using SindbadTEM
using Flux
using Optimisers
using FiniteDiff
using FiniteDifferences
using ForwardDiff
using Zygote
using Statistics
using ProgressMeter
using PreallocationTools
using Base.Iterators: repeated, partition
using Random
using JLD2

include("utilsML.jl")
include("setupNeuralNetwork.jl")
include("runSindbadML.jl")

end # module SindbadML
