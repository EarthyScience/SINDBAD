module OptimizeSindbad
using InteractiveUtils
using ForwardSindbad
using CMAEvolutionStrategy:
    minimize,
    xbest
using Dates
using DifferentialEquations
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
using YAXArrays, NetCDF, DiskArrayTools, Zarr
using YAXArrays: savecube
using AxisKeys
using AxisKeys: KeyedArray, AxisKeys
using FillArrays
using YAXArrayBase: getdata, YAXArrayBase
using JLD2: @save

include("tools/tools.jl")
#include("Ecosystem/Ecosystem.jl")
include("optimization/optimization.jl")

#include("Models/models.jl")
#@reexport using .Models

end
