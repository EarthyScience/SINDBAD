module SindbadOptimization

    using CMAEvolutionStrategy: minimize, xbest
    using Evolutionary: Evolutionary
    using ForwardDiff
    using InteractiveUtils
    using MultistartOptimization: MultistartOptimization
    using NLopt: NLopt
    using Optim
    using Optimization
    using OptimizationOptimJL
    using OptimizationBBO
    using OptimizationGCMAES
    using SindbadTEM
    using SindbadMetrics

    include("optimizer.jl")
    include("optimizeTEM.jl")
    include("optimizeTEMYax.jl")

end # module SindbadOptimization
