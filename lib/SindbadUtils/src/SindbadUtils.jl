module SindbadUtils

    using Crayons
    using StyledStrings
    using DataStructures
    using Dates
    using FIGlet
    using Logging
    using Reexport: @reexport
    @reexport using NaNStatistics
    using StaticArraysCore
    @reexport using StatsBase: mean, rle, sample, sum
    @reexport using TypedTables: Table

    include("utilsTypes.jl")
    include("getArrayView.jl")
    include("utils.jl")
    include("utilsNT.jl")
    include("utilsSpatial.jl")
    include("utilsTemporal.jl")
    include("updateParameters.jl")
    
end # module SindbadUtils
