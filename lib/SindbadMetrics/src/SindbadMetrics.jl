module SindbadMetrics

    using SindbadUtils
    using StatsBase: mean, percentile, cor, corspearman

    include("metricTypes.jl")
    include("metrics.jl")
    include("getMetrics.jl")

end # module SindbadMetrics
