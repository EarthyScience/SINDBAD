module SindbadSetup
using CodeTracking
using CSV: CSV
using JSON: parsefile, json
using Dates

include("getConfiguration.jl")
include("prepExperiment.jl")
include("setupExperiment.jl")

end # module SindbadSetup
