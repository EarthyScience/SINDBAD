module SindbadTEM

    import AxisKeys
    using ComponentArrays
    using InteractiveUtils
    using NLsolve
    using ProgressMeter
    using SindbadSetup
    @reexport using Pkg
    @reexport using SindbadSetup
    using ThreadPools
    using YAXArrays

    include("utilsTEM.jl")
    include("deriveSpinupForcing.jl")
    include("prepTEMOut.jl")
    include("runModels.jl")
    include("prepTEM.jl")
    include("runTEMLand.jl")
    include("runTEMArray.jl")
    include("runTEMYax.jl")
    include("spinupTEM.jl")
    include("updateParameters.jl")
    include("runSpatial.jl")

end # module SindbadTEM
