"""
    SindbadMetrics

Here we define the metrics that are used to evaluate the performance of the models. 
"""
module SindbadMetrics

    using SindbadUtils
    using StatsBase: mean, percentile, cor, corspearman

    include("metricTypes.jl")
    include("handleDataForLoss.jl")
    include("getMetrics.jl")
    include("metrics.jl")
    include("updateParameters.jl")

end # module SindbadMetrics
