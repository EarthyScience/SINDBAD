module SindbadSetup

    using Sindbad
    using ConstructionBase
    @reexport using Accessors
    @reexport using ForwardDiff
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
    include("setupTypes.jl")
    include("setupPools.jl")
    include("updateParameters.jl")
    include("setupParameters.jl")
    include("setupModels.jl")
    include("setupOutput.jl")
    include("setupOptimization.jl")
    include("setupInfo.jl")

end # module SindbadSetup
