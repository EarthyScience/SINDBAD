
export OptimizationType
abstract type OptimizationType <: SindbadType end
purpose(::Type{OptimizationType}) = "Abstract type for optimization related functions and methods in SINDBAD"

# ------------------------- optimization TEM and algorithm -------------------------
export OptimizationMethod
export BayesOptKMaternARD5
export CMAEvolutionStrategyCMAES
export EvolutionaryCMAES
export OptimLBFGS
export OptimBFGS
export OptimizationBBOadaptive
export OptimizationBBOxnes
export OptimizationBFGS
export OptimizationFminboxGradientDescent
export OptimizationFminboxGradientDescentFD
export OptimizationGCMAESDef
export OptimizationGCMAESFD
export OptimizationMultistartOptimization
export OptimizationNelderMead
export OptimizationQuadDirect

abstract type OptimizationMethod <: OptimizationType end
purpose(::Type{OptimizationMethod}) = "Abstract type for optimization methods in SINDBAD"

struct BayesOptKMaternARD5 <: OptimizationMethod end
purpose(::Type{BayesOptKMaternARD5}) = "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"

struct CMAEvolutionStrategyCMAES <: OptimizationMethod end
purpose(::Type{CMAEvolutionStrategyCMAES}) = "Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl"

struct EvolutionaryCMAES <: OptimizationMethod end
purpose(::Type{EvolutionaryCMAES}) = "Evolutionary version of CMA-ES optimization from Evolutionary.jl"

struct OptimLBFGS <: OptimizationMethod end
purpose(::Type{OptimLBFGS}) = "Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl"

struct OptimBFGS <: OptimizationMethod end
purpose(::Type{OptimBFGS}) = "Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl"

struct OptimizationBBOadaptive <: OptimizationMethod end
purpose(::Type{OptimizationBBOadaptive}) = "Black Box Optimization with adaptive parameters from Optimization.jl"

struct OptimizationBBOxnes <: OptimizationMethod end
purpose(::Type{OptimizationBBOxnes}) = "Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl"

struct OptimizationBFGS <: OptimizationMethod end
purpose(::Type{OptimizationBFGS}) = "BFGS optimization with box constraints from Optimization.jl"

struct OptimizationFminboxGradientDescent <: OptimizationMethod end
purpose(::Type{OptimizationFminboxGradientDescent}) = "Gradient descent optimization with box constraints from Optimization.jl"

struct OptimizationFminboxGradientDescentFD <: OptimizationMethod end
purpose(::Type{OptimizationFminboxGradientDescentFD}) = "Gradient descent optimization with box constraints using forward differentiation from Optimization.jl"

struct OptimizationGCMAESDef <: OptimizationMethod end
purpose(::Type{OptimizationGCMAESDef}) = "Global CMA-ES optimization with default settings from Optimization.jl"

struct OptimizationGCMAESFD <: OptimizationMethod end
purpose(::Type{OptimizationGCMAESFD}) = "Global CMA-ES optimization using forward differentiation from Optimization.jl"

struct OptimizationMultistartOptimization <: OptimizationMethod end
purpose(::Type{OptimizationMultistartOptimization}) = "Multi-start optimization to find global optimum from Optimization.jl"

struct OptimizationNelderMead <: OptimizationMethod end
purpose(::Type{OptimizationNelderMead}) = "Nelder-Mead simplex optimization method from Optimization.jl"

struct OptimizationQuadDirect <: OptimizationMethod end
purpose(::Type{OptimizationQuadDirect}) = "Quadratic Direct optimization method from Optimization.jl"

# ------------------------- global sensitivity analysis -------------------------

export GSAMethod
export GSAMorris
export GSASobol
export GSASobolDM

abstract type GSAMethod <: OptimizationType end
purpose(::Type{GSAMethod}) = "Abstract type for global sensitivity analysis methods in SINDBAD"

struct GSAMorris <: GSAMethod end
purpose(::Type{GSAMorris}) = "Morris method for global sensitivity analysis"

struct GSASobol <: GSAMethod end
purpose(::Type{GSASobol}) = "Sobol method for global sensitivity analysis"

struct GSASobolDM <: GSAMethod end
purpose(::Type{GSASobolDM}) = "Sobol method with derivative-based measures for global sensitivity analysis"

# ------------------------- loss calculation -------------------------

export CostMethod
export CostModelObs
export CostModelObsLandTS
export CostModelObsMT
export CostModelObsPriors

abstract type CostMethod <: OptimizationType end
purpose(::Type{CostMethod}) = "Abstract type for cost calculation methods in SINDBAD"

struct CostModelObs <: CostMethod end
purpose(::Type{CostModelObs}) = "cost calculation between model output and observations"

struct CostModelObsLandTS <: CostMethod end
purpose(::Type{CostModelObsLandTS}) = "cost calculation between land model output and time series observations"

struct CostModelObsMT <: CostMethod end
purpose(::Type{CostModelObsMT}) = "multi-threaded cost calculation between model output and observations"

struct CostModelObsPriors <: CostMethod end
purpose(::Type{CostModelObsPriors}) = "cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET"

# ------------------------- parameter scaling -------------------------

export ParameterScaling
export ScaleNone
export ScaleDefault
export ScaleBounds

abstract type ParameterScaling <: OptimizationType end
purpose(::Type{ParameterScaling}) = "Abstract type for parameter scaling methods in SINDBAD"

struct ScaleNone <: ParameterScaling end
purpose(::Type{ScaleNone}) = "No parameter scaling applied"

struct ScaleDefault <: ParameterScaling end
purpose(::Type{ScaleDefault}) = "Scale parameters relative to default values"

struct ScaleBounds <: ParameterScaling end
purpose(::Type{ScaleBounds}) = "Scale parameters relative to their bounds"
