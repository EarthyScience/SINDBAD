module SindbadUtils
using Crayons
using Logging
@reexport using NaNStatistics
using StatsBase: mean, rle, sample

include("getArrayView.jl")
include("utils.jl")
end # module SindbadUtils
