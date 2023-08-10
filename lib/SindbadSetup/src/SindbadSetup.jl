module SindbadSetup

    using Sindbad
    using CodeTracking
    using CSV: CSV
    using Dates
    @reexport using Infiltrator
    using JSON: parsefile, json
    @reexport using JLD2: @save
    @reexport using Sindbad
    @reexport using SindbadUtils

    include("getConfiguration.jl")
    include("setupOptimInfo.jl")
    include("setupInfo.jl")

end # module SindbadSetup
