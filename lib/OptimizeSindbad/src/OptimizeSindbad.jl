module OptimizeSindbad
using InteractiveUtils
using Sindbad
using ForwardSindbad
using CMAEvolutionStrategy:
    minimize,
    xbest
using Dates
# using DifferentialEquations
using ForwardDiff
using Flatten:
    flatten,
    metaflatten,
    fieldnameflatten,
    parentnameflatten

using Optim, Optimization, OptimizationOptimJL, OptimizationBBO, OptimizationGCMAES
import Evolutionary
import MultistartOptimization
import NLopt
# @reexport using Optimization:FD
#     OptimizationFunction

using RecursiveArrayTools

using TableOperations:
    select
using Tables:
    columntable,
    matrix
using TypedTables:
    Table
using StatsBase:
    mean,
    percentile,
    cor

using JLD2: @save

using YAXArrays
using YAXArrayBase
using YAXArrays: savecube
using YAXArrayBase: getdata

include("optimization/optimization.jl")

end
