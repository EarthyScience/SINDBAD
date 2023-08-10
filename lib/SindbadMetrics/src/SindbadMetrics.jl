module SindbadMetrics
using StatsBase: mean, percentile, cor, corspearman
using SindbadUtils

include("metricTypes.jl")
include("metrics.jl")
include("getMetrics.jl")

end # module SindbadMetrics
