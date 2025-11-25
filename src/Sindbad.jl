module Sindbad

using SindbadTEM
using SindbadTEM.Reexport: @reexport
@reexport using SindbadTEM

using ConstructionBase
using CSV: CSV
using JSON: parsefile, json, print as json_print
using JLD2: @save, load
using YAXArrays: YAXArrays, YAXArray
using YAXArrays.Datasets: savedataset



include("DataLoaders/DataLoaders.jl")
@reexport using .DataLoaders
include("SetupSimulation/SetupSimulation.jl")
@reexport using .SetupSimulation
include("Simulation/Simulation.jl")
@reexport using .Simulation
include("Optimization/Optimization.jl")
@reexport using .Optimization
include("MachineLearning/MachineLearning.jl")
@reexport using .MachineLearning
include("Visualization/Visualization.jl")
@reexport using .Visualization

end # module Sindbad
