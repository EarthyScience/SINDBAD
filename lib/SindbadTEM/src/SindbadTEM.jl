module SindbadTEM
    using ComponentArrays
    using ConstructionBase
    using InteractiveUtils
    using NLsolve
    using ProgressMeter
    using SindbadSetup
    @reexport using SindbadSetup

    using ThreadPools
    using YAXArrays

    include("utilsTEM.jl")
    include("deriveSpinupForcing.jl")
    include("prepTEMOut.jl")
    include("runModels.jl")
    include("prepTEM.jl")
    include("runTEMLoc.jl")
    include("runTEMSpace.jl")
    include("runTEMCube.jl")
    include("spinupTEM.jl")

end # module SindbadTEM
