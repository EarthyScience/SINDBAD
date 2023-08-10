module SindbadUtils

    using Crayons
    using Logging
    using Reexport: @reexport
    @reexport using NaNStatistics
    using StatsBase: mean, rle, sample
    @reexport using TypedTables: Table

    include("getArrayView.jl")
    include("utils.jl")
    include("utilsNT.jl")
    include("utilsSpatial.jl")
    include("utilsTemporal.jl")

end # module SindbadUtils
