module Sindbad

using SindbadCore
using SindbadData
using SindbadSetup
using SindbadTEM
using SindbadOptimization
using SindbadML

using SindbadCore.Reexport: @reexport
@reexport using SindbadCore
@reexport using SindbadData
@reexport using SindbadSetup
@reexport using SindbadTEM
@reexport using SindbadOptimization
@reexport using SindbadML

include("Experiment/runExperiment.jl")
include("Experiment/saveOutput.jl")

end