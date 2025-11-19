module Sindbad

using SindbadCore
using ConstructionBase
using CSV: CSV
using JSON: parsefile, json, print as json_print
using JLD2: @save, load
using YAXArrays: YAXArrays, YAXArray
using YAXArrays.Datasets: savedataset

using SindbadCore.Reexport: @reexport
@reexport using SindbadCore

include("Setup/Setup.jl")
include("DataLoaders/DataLoaders.jl")
include("TEM/TEM.jl")
include("ML/ML.jl")
include("Optimization/Optimization.jl")

include("Experiment/runExperiment.jl")
include("Experiment/saveOutput.jl")

# extensions interfaces
include("Interfaces/plotsrecipes.jl")

@reexport using .Setup
@reexport using .TEM
@reexport using .ML
@reexport using .Optimization
@reexport using .DataLoaders

end