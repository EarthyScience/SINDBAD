module SindbadOptimization

    using CMAEvolutionStrategy: minimize, xbest
    # using BayesOpt: ConfigParameters, set_kernel!, bayes_optimization, SC_MAP
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
    # using OptimizationQuadDIRECT
    using SindbadTEM
    using SindbadMetrics

    include("optimizer.jl")
    include("optimizeTEM.jl")
    include("optimizeTEMCube.jl")

end # module SindbadOptimization
