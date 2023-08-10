module SindbadUtils

    using Crayons
    using DataStructures
    using Dates
    using Logging
    using Reexport: @reexport
    @reexport using NaNStatistics
    @reexport using StatsBase: mean, rle, sample, sum
    @reexport using TypedTables: Table

    include("getArrayView.jl")
    include("utils.jl")
    include("utilsNT.jl")
    include("utilsSpatial.jl")
    include("utilsTemporal.jl")

end # module SindbadUtils
