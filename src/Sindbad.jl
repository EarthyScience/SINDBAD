module Sindbad

using SindbadCore
using ConstructionBase
using CSV: CSV
using JSON: parsefile, json, print as json_print
using JLD2: @save, load

using SindbadData
# using SindbadOptimization

using SindbadCore.Reexport: @reexport
@reexport using SindbadCore
@reexport using SindbadData
# @reexport using SindbadOptimization

include("Setup/Setup.jl")
include("TEM/TEM.jl")
include("ML/ML.jl")

include("Experiment/runExperiment.jl")
include("Experiment/saveOutput.jl")

@reexport using .Setup
@reexport using .TEM
@reexport using .ML

end