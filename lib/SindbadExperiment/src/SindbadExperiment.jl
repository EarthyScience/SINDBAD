module SindbadExperiment

    using NetCDF
    using Sindbad
    @reexport using Sindbad
    @reexport using SindbadUtils
    @reexport using SindbadSetup
    @reexport using SindbadData
    @reexport using SindbadTEM
    @reexport using SindbadOptimization
    @reexport using SindbadMetrics
    using YAXArrays
    using Zarr

    include("prepExperiment.jl")
    include("runExperiment.jl")
    include("saveOutput.jl")

end # module SindbadExperiment
