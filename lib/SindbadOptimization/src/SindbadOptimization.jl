module SindbadOptimization
using InteractiveUtils
using Reexport: @reexport
@reexport using Sindbad
@reexport using SindbadTEM
@reexport using SindbadUtils
@reexport using SindbadMetrics

using CMAEvolutionStrategy: minimize, xbest
# using Dates
# using DifferentialEquations
using ForwardDiff
using Flatten: flatten, metaflatten, fieldnameflatten, parentnameflatten

using Optim, Optimization, OptimizationOptimJL, OptimizationBBO, OptimizationGCMAES
using Evolutionary: Evolutionary
using MultistartOptimization: MultistartOptimization
using NLopt: NLopt
# @reexport using Optimization:FD
#     OptimizationFunction

using RecursiveArrayTools

# using TableOperations: select
# using Tables: columntable, matrix
# using TypedTables: Table

# using JLD2: @save

# using YAXArrays
# using YAXArrayBase
# using YAXArrays: savecube
# using YAXArrayBase: getdata

using Infiltrator  # to allow @infiltrate for debugging

include("optimization.jl")

end
