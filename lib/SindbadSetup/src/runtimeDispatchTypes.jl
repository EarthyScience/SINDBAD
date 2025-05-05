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

abstract type SindbadOptimizationMethod end
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

export SindbadGlobalSensitivityMethod
export GlobalSensitivityMorris
export GlobalSensitivitySobol
export GlobalSensitivitySobolDM

abstract type SindbadGlobalSensitivityMethod end
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

abstract type SindbadCostMethod end
purpose(::Type{SindbadCostMethod}) = "Abstract type for cost calculation methods in SINDBAD"

struct CostModelObs <: SindbadCostMethod end
purpose(::Type{CostModelObs}) = "cost calculation between model output and observations"

struct CostModelObsLandTS <: SindbadCostMethod end
purpose(::Type{CostModelObsLandTS}) = "cost calculation between land model output and time series observations"

struct CostModelObsMT <: SindbadCostMethod end
purpose(::Type{CostModelObsMT}) = "multi-threaded cost calculation between model output and observations"

struct CostModelObsPriors <: SindbadCostMethod end
purpose(::Type{CostModelObsPriors}) = "cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET"

# ------------------------- running flags -------------------------
export SindbadRunMethod
export DoCalcCost
export DoNotCalcCost
export DoDebugModel
export DoNotDebugModel
export DoUseForwardDiff
export DoNotUseForwardDiff
export DoFilterNanPixels
export DoNotFilterNanPixels
export DoInlineUpdate
export DoNotInlineUpdate
export DoRunForward
export DoNotRunForward
export DoRunOptimization
export DoNotRunOptimization
export DoSaveInfo
export DoNotSaveInfo
export DoSpinupTEM
export DoNotSpinupTEM
export DoStoreSpinup
export DoNotStoreSpinup

abstract type SindbadRunMethod end
purpose(::Type{SindbadRunMethod}) = "Abstract type for model run configuration flags in SINDBAD"

struct DoCalcCost <:SindbadRunMethod end
purpose(::Type{DoCalcCost}) = "Enable cost calculation between model output and observations"

struct DoNotCalcCost <:SindbadRunMethod end
purpose(::Type{DoNotCalcCost}) = "Disable cost calculation between model output and observations"

struct DoDebugModel <:SindbadRunMethod end
purpose(::Type{DoDebugModel}) = "Enable model debugging mode"

struct DoNotDebugModel <:SindbadRunMethod end
purpose(::Type{DoNotDebugModel}) = "Disable model debugging mode"

struct DoFilterNanPixels <:SindbadRunMethod end
purpose(::Type{DoFilterNanPixels}) = "Enable filtering of NaN values in spatial data"

struct DoNotFilterNanPixels <:SindbadRunMethod end
purpose(::Type{DoNotFilterNanPixels}) = "Disable filtering of NaN values in spatial data"

struct DoInlineUpdate <:SindbadRunMethod end
purpose(::Type{DoInlineUpdate}) = "Enable inline updates of model state"

struct DoNotInlineUpdate <:SindbadRunMethod end
purpose(::Type{DoNotInlineUpdate}) = "Disable inline updates of model state"

struct DoRunForward <:SindbadRunMethod end
purpose(::Type{DoRunForward}) = "Enable forward model run"

struct DoNotRunForward <:SindbadRunMethod end
purpose(::Type{DoNotRunForward}) = "Disable forward model run"

struct DoRunOptimization <:SindbadRunMethod end
purpose(::Type{DoRunOptimization}) = "Enable model parameter optimization"

struct DoNotRunOptimization <:SindbadRunMethod end
purpose(::Type{DoNotRunOptimization}) = "Disable model parameter optimization"

struct DoSaveInfo <:SindbadRunMethod end
purpose(::Type{DoSaveInfo}) = "Enable saving of model information"

struct DoNotSaveInfo <:SindbadRunMethod end
purpose(::Type{DoNotSaveInfo}) = "Disable saving of model information"

struct DoSpinupTEM <:SindbadRunMethod end
purpose(::Type{DoSpinupTEM}) = "Enable terrestrial ecosystem model spinup"

struct DoNotSpinupTEM <:SindbadRunMethod end
purpose(::Type{DoNotSpinupTEM}) = "Disable terrestrial ecosystem model spinup"

struct DoStoreSpinup <:SindbadRunMethod end
purpose(::Type{DoStoreSpinup}) = "Enable storing of spinup results"

struct DoNotStoreSpinup <:SindbadRunMethod end
purpose(::Type{DoNotStoreSpinup}) = "Disable storing of spinup results"

struct DoUseForwardDiff <:SindbadRunMethod end
purpose(::Type{DoUseForwardDiff}) = "Enable forward mode automatic differentiation"

struct DoNotUseForwardDiff <:SindbadRunMethod end
purpose(::Type{DoNotUseForwardDiff}) = "Disable forward mode automatic differentiation"

export SindbadParallelizationMethod
export UseQbmapParallelization
export UseThreadsParallelization

abstract type SindbadParallelizationMethod end
purpose(::Type{SindbadParallelizationMethod}) = "Abstract type for parallelization methods in SINDBAD"

struct UseQbmapParallelization <:SindbadParallelizationMethod end
purpose(::Type{UseQbmapParallelization}) = "Use Qbmap for parallelization"

struct UseThreadsParallelization <:SindbadParallelizationMethod end
purpose(::Type{UseThreadsParallelization}) = "Use Julia threads for parallelization"

# ------------------------- spinup methods -------------------------
export SindbadSpinupMethod
export AllForwardModels
export SelSpinupModels
export EtaScaleA0H
export EtaScaleAH
export NlsolveFixedpointTrustregionCEco
export NlsolveFixedpointTrustregionCEcoTWS
export NlsolveFixedpointTrustregionTWS
export ODEAutoTsit5Rodas5
export ODEDP5
export ODETsit5
export SSPDynamicSSTsit5
export SSPSSRootfind

abstract type SindbadSpinupMethod end
purpose(::Type{SindbadSpinupMethod}) = "Abstract type for model spinup methods in SINDBAD"

struct AllForwardModels <: SindbadSpinupMethod end
purpose(::Type{AllForwardModels}) = "Use all forward models for spinup"

struct EtaScaleA0H <: SindbadSpinupMethod end
purpose(::Type{EtaScaleA0H}) = "scale carbon pools using diagnostic scalars for ηH and c_remain"

struct EtaScaleAH <: SindbadSpinupMethod end
purpose(::Type{EtaScaleAH}) = "scale carbon pools using diagnostic scalars for ηH and ηA"

struct NlsolveFixedpointTrustregionCEco <: SindbadSpinupMethod end
purpose(::Type{NlsolveFixedpointTrustregionCEco}) = "use a fixed-point nonlinear solver with trust region for carbon pools (cEco)"

struct NlsolveFixedpointTrustregionCEcoTWS <: SindbadSpinupMethod end
purpose(::Type{NlsolveFixedpointTrustregionCEcoTWS}) = "use a fixed-point nonlinear solver with trust region for both cEco and TWS"

struct NlsolveFixedpointTrustregionTWS <: SindbadSpinupMethod end
purpose(::Type{NlsolveFixedpointTrustregionTWS}) = "use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS)"

struct ODEAutoTsit5Rodas5 <: SindbadSpinupMethod end
purpose(::Type{ODEAutoTsit5Rodas5}) = "use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs"

struct ODEDP5 <: SindbadSpinupMethod end
purpose(::Type{ODEDP5}) = "use the DP5 method from DifferentialEquations.jl for solving ODEs"

struct ODETsit5 <: SindbadSpinupMethod end
purpose(::Type{ODETsit5}) = "use the Tsit5 method from DifferentialEquations.jl for solving ODEs"

struct SelSpinupModels <: SindbadSpinupMethod end
purpose(::Type{SelSpinupModels}) = "run only the models selected for spinup in the model structure"

struct SSPDynamicSSTsit5 <: SindbadSpinupMethod end
purpose(::Type{SSPDynamicSSTsit5}) = "use the SteadyState solver with DynamicSS and Tsit5 methods"

struct SSPSSRootfind <: SindbadSpinupMethod end
purpose(::Type{SSPSSRootfind}) = "use the SteadyState solver with SSRootfind method"

# spinup sequence and types
export SpinSequence
export SpinSequenceWithAggregator

struct SpinSequenceWithAggregator
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SindbadSpinupMethod
    options::NamedTuple
    aggregator_indices::Vector{Int}
    aggregator::Vector{TimeAggregator}
    aggregator_type::SindbadTimeAggregator
end
purpose(::Type{SpinSequenceWithAggregator}) = "Spinup sequence with time aggregation capabilities"

struct SpinSequence
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SindbadSpinupMethod
    options::NamedTuple
end
purpose(::Type{SpinSequence}) = "Basic spinup sequence configuration"

# ------------------------- parallelization and model output options-------------------------
export SindbadOutputStrategyType
export DoOutputAll
export DoNotOutputAll
export DoSaveSingleFile
export DoNotSaveSingleFile
export UseQbmapParallelization
export UseThreadsParallelization

abstract type SindbadOutputStrategyType end
purpose(::Type{SindbadOutputStrategyType}) = "Abstract type for model output strategies in SINDBAD"

struct DoOutputAll <:SindbadOutputStrategyType end
purpose(::Type{DoOutputAll}) = "Enable output of all model variables"

struct DoNotOutputAll <:SindbadOutputStrategyType end
purpose(::Type{DoNotOutputAll}) = "Disable output of all model variables"

struct DoSaveSingleFile <:SindbadOutputStrategyType end
purpose(::Type{DoSaveSingleFile}) = "Save all output variables in a single file"

struct DoNotSaveSingleFile <:SindbadOutputStrategyType end
purpose(::Type{DoNotSaveSingleFile}) = "Save output variables in separate files"

# ------------------------- model array types for internal model variables -------------------------
export SindbadModelArrayType
export ModelArrayArray
export ModelArrayStaticArray
export ModelArrayView

abstract type SindbadModelArrayType end
purpose(::Type{SindbadModelArrayType}) = "Abstract type for internal model array types in SINDBAD"

struct ModelArrayArray <:SindbadModelArrayType end
purpose(::Type{ModelArrayArray}) = "Use standard Julia arrays for model variables"

struct ModelArrayStaticArray <:SindbadModelArrayType end
purpose(::Type{ModelArrayStaticArray}) = "Use StaticArrays for model variables"

struct ModelArrayView <:SindbadModelArrayType end
purpose(::Type{ModelArrayView}) = "Use array views for model variables"

# ------------------------- output array types preallocated arrays -------------------------

export SindbadOutputArrayType
export OutputArray
export OutputMArray
export OutputSizedArray
export OutputYAXArray

abstract type SindbadOutputArrayType end
purpose(::Type{SindbadOutputArrayType}) = "Abstract type for output array types in SINDBAD"

struct OutputArray <:SindbadOutputArrayType end
purpose(::Type{OutputArray}) = "Use standard Julia arrays for output"

struct OutputMArray <:SindbadOutputArrayType end
purpose(::Type{OutputMArray}) = "Use MArray for output"

struct OutputSizedArray <:SindbadOutputArrayType end
purpose(::Type{OutputSizedArray}) = "Use SizedArray for output"

struct OutputYAXArray <:SindbadOutputArrayType end
purpose(::Type{OutputYAXArray}) = "Use YAXArray for output"

export SindbadLandOutType
export LandOutArray
export LandOutArrayAll
export LandOutArrayFD
export LandOutArrayMT
export LandOutStacked
export LandOutTimeseries
export LandOutYAXArray

abstract type SindbadLandOutType end
purpose(::Type{SindbadLandOutType}) = "Abstract type for land model output types in SINDBAD"

struct LandOutArray <: SindbadLandOutType end
purpose(::Type{LandOutArray}) = "use a preallocated array for model output"

struct LandOutArrayAll <: SindbadLandOutType end
purpose(::Type{LandOutArrayAll}) = "use a preallocated array to output all land variables"

struct LandOutArrayFD <: SindbadLandOutType end
purpose(::Type{LandOutArrayFD}) = "use a preallocated array for finite difference (FD) hybrid experiments"

struct LandOutArrayMT <: SindbadLandOutType end
purpose(::Type{LandOutArrayMT}) = "use arrays for land model output for replicates of multiple threads"

struct LandOutStacked <: SindbadLandOutType end
purpose(::Type{LandOutStacked}) = "save output as a stacked land vector"

struct LandOutTimeseries <: SindbadLandOutType end
purpose(::Type{LandOutTimeseries}) = "save land output as a preallocated time series"

struct LandOutYAXArray <: SindbadLandOutType end
purpose(::Type{LandOutYAXArray}) = "use a YAX array for model output"
