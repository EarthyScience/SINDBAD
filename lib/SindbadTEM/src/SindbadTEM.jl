module SindbadTEM

    using Accessors
    using AxisKeys
    using ComponentArrays
    using InteractiveUtils
    using NLsolve
    using Pkg
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
    include("runTEMLand.jl")
    include("runTEMArray.jl")
    include("runTEMYax.jl")
    include("spinupTEM.jl")

end # module SindbadTEM
