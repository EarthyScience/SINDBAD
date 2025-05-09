
export SindbadOptimizationType
abstract type SindbadOptimizationType <: SindbadType end
purpose(::Type{SindbadOptimizationType}) = "Abstract type for optimization related functions and methods in SINDBAD"

# ------------------------- optimization TEM and algorithm -------------------------
export SindbadOptimizationMethod
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

abstract type SindbadOptimizationMethod <: SindbadOptimizationType end
purpose(::Type{SindbadOptimizationMethod}) = "Abstract type for optimization methods in SINDBAD"

struct BayesOptKMaternARD5 <: SindbadOptimizationMethod end
purpose(::Type{BayesOptKMaternARD5}) = "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"

struct CMAEvolutionStrategyCMAES <: SindbadOptimizationMethod end
purpose(::Type{CMAEvolutionStrategyCMAES}) = "Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl"

struct EvolutionaryCMAES <: SindbadOptimizationMethod end
purpose(::Type{EvolutionaryCMAES}) = "Evolutionary version of CMA-ES optimization from Evolutionary.jl"

struct OptimLBFGS <: SindbadOptimizationMethod end
purpose(::Type{OptimLBFGS}) = "Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl"

struct OptimBFGS <: SindbadOptimizationMethod end
purpose(::Type{OptimBFGS}) = "Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl"

struct OptimizationBBOadaptive <: SindbadOptimizationMethod end
purpose(::Type{OptimizationBBOadaptive}) = "Black Box Optimization with adaptive parameters from Optimization.jl"

struct OptimizationBBOxnes <: SindbadOptimizationMethod end
purpose(::Type{OptimizationBBOxnes}) = "Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl"

struct OptimizationBFGS <: SindbadOptimizationMethod end
purpose(::Type{OptimizationBFGS}) = "BFGS optimization with box constraints from Optimization.jl"

struct OptimizationFminboxGradientDescent <: SindbadOptimizationMethod end
purpose(::Type{OptimizationFminboxGradientDescent}) = "Gradient descent optimization with box constraints from Optimization.jl"

struct OptimizationFminboxGradientDescentFD <: SindbadOptimizationMethod end
purpose(::Type{OptimizationFminboxGradientDescentFD}) = "Gradient descent optimization with box constraints using forward differentiation from Optimization.jl"

struct OptimizationGCMAESDef <: SindbadOptimizationMethod end
purpose(::Type{OptimizationGCMAESDef}) = "Global CMA-ES optimization with default settings from Optimization.jl"

struct OptimizationGCMAESFD <: SindbadOptimizationMethod end
purpose(::Type{OptimizationGCMAESFD}) = "Global CMA-ES optimization using forward differentiation from Optimization.jl"

struct OptimizationMultistartOptimization <: SindbadOptimizationMethod end
purpose(::Type{OptimizationMultistartOptimization}) = "Multi-start optimization to find global optimum from Optimization.jl"

struct OptimizationNelderMead <: SindbadOptimizationMethod end
purpose(::Type{OptimizationNelderMead}) = "Nelder-Mead simplex optimization method from Optimization.jl"

struct OptimizationQuadDirect <: SindbadOptimizationMethod end
purpose(::Type{OptimizationQuadDirect}) = "Quadratic Direct optimization method from Optimization.jl"

# ------------------------- global sensitivity analysis -------------------------

export SindbadGlobalSensitivityMethod
export GlobalSensitivityMorris
export GlobalSensitivitySobol
export GlobalSensitivitySobolDM

abstract type SindbadGlobalSensitivityMethod <: SindbadOptimizationType end
purpose(::Type{SindbadGlobalSensitivityMethod}) = "Abstract type for global sensitivity analysis methods in SINDBAD"

struct GlobalSensitivityMorris <: SindbadGlobalSensitivityMethod end
purpose(::Type{GlobalSensitivityMorris}) = "Morris method for global sensitivity analysis"

struct GlobalSensitivitySobol <: SindbadGlobalSensitivityMethod end
purpose(::Type{GlobalSensitivitySobol}) = "Sobol method for global sensitivity analysis"

struct GlobalSensitivitySobolDM <: SindbadGlobalSensitivityMethod end
purpose(::Type{GlobalSensitivitySobolDM}) = "Sobol method with derivative-based measures for global sensitivity analysis"

# ------------------------- loss calculation -------------------------

export SindbadCostMethod
export CostModelObs
export CostModelObsLandTS
export CostModelObsMT
export CostModelObsPriors

abstract type SindbadCostMethod <: SindbadOptimizationType end
purpose(::Type{SindbadCostMethod}) = "Abstract type for cost calculation methods in SINDBAD"

struct CostModelObs <: SindbadCostMethod end
purpose(::Type{CostModelObs}) = "cost calculation between model output and observations"

struct CostModelObsLandTS <: SindbadCostMethod end
purpose(::Type{CostModelObsLandTS}) = "cost calculation between land model output and time series observations"

struct CostModelObsMT <: SindbadCostMethod end
purpose(::Type{CostModelObsMT}) = "multi-threaded cost calculation between model output and observations"

struct CostModelObsPriors <: SindbadCostMethod end
purpose(::Type{CostModelObsPriors}) = "cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET"

# ------------------------- parameter scaling -------------------------

export SindbadParameterScaling
export ScaleNone
export ScaleDefault
export ScaleBounds

abstract type SindbadParameterScaling <: SindbadOptimizationType end
purpose(::Type{SindbadParameterScaling}) = "Abstract type for parameter scaling methods in SINDBAD"

struct ScaleNone <: SindbadParameterScaling end
purpose(::Type{ScaleNone}) = "No parameter scaling applied"

struct ScaleDefault <: SindbadParameterScaling end
purpose(::Type{ScaleDefault}) = "Scale parameters relative to default values"

struct ScaleBounds <: SindbadParameterScaling end
purpose(::Type{ScaleBounds}) = "Scale parameters relative to their bounds"
