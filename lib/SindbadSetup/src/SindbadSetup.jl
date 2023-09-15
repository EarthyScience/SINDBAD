module SindbadSetup

    using Sindbad
    @reexport using Accessors
    @reexport using ForwardDiff
    using CodeTracking
    @reexport using CSV: CSV
    @reexport using Dates
    @reexport using Infiltrator
    using JSON: parsefile, json
    @reexport using JLD2: @save
    @reexport using Sindbad
    @reexport using SindbadUtils
    @reexport using SindbadMetrics

    include("runtimeDispatchTypes.jl")
    include("getConfiguration.jl")
    include("setupExperimentInfo.jl")
    include("setupOptimInfo.jl")
    include("setupInfo.jl")

end # module SindbadSetup
