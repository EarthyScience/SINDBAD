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
struct BayesOptKMaternARD5 <: SindbadOptimizationMethod end
struct CMAEvolutionStrategyCMAES <: SindbadOptimizationMethod end
struct EvolutionaryCMAES <: SindbadOptimizationMethod end
struct OptimLBFGS <: SindbadOptimizationMethod end
struct OptimBFGS <: SindbadOptimizationMethod end
struct OptimizationBBOadaptive <: SindbadOptimizationMethod end
struct OptimizationBBOxnes <: SindbadOptimizationMethod end
struct OptimizationBFGS <: SindbadOptimizationMethod end
struct OptimizationFminboxGradientDescent <: SindbadOptimizationMethod end
struct OptimizationFminboxGradientDescentFD <: SindbadOptimizationMethod end
struct OptimizationGCMAESDef <: SindbadOptimizationMethod end
struct OptimizationGCMAESFD <: SindbadOptimizationMethod end
struct OptimizationMultistartOptimization <: SindbadOptimizationMethod end
struct OptimizationNelderMead <: SindbadOptimizationMethod end
struct OptimizationQuadDirect <: SindbadOptimizationMethod end

# ------------------------- loss calculation -------------------------

export SindbadCostMethod
export CostModelObs
export CostModelObsLandTS
export CostModelObsMT
export CostModelObsPriors

abstract type SindbadCostMethod end
struct CostModelObs <: SindbadCostMethod end
struct CostModelObsLandTS <: SindbadCostMethod end
struct CostModelObsMT <: SindbadCostMethod end
struct CostModelObsPriors <: SindbadCostMethod end

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
struct DoCalcCost <:SindbadRunMethod end
struct DoNotCalcCost <:SindbadRunMethod end
struct DoDebugModel <:SindbadRunMethod end
struct DoNotDebugModel <:SindbadRunMethod end
struct DoFilterNanPixels <:SindbadRunMethod end
struct DoNotFilterNanPixels <:SindbadRunMethod end
struct DoInlineUpdate <:SindbadRunMethod end
struct DoNotInlineUpdate <:SindbadRunMethod end
struct DoRunForward <:SindbadRunMethod end
struct DoNotRunForward <:SindbadRunMethod end
struct DoRunOptimization <:SindbadRunMethod end
struct DoNotRunOptimization <:SindbadRunMethod end
struct DoSaveInfo <:SindbadRunMethod end
struct DoNotSaveInfo <:SindbadRunMethod end
struct DoSpinupTEM <:SindbadRunMethod end
struct DoNotSpinupTEM <:SindbadRunMethod end
struct DoStoreSpinup <:SindbadRunMethod end
struct DoNotStoreSpinup <:SindbadRunMethod end
struct DoUseForwardDiff <:SindbadRunMethod end
struct DoNotUseForwardDiff <:SindbadRunMethod end

export SindbadParallelizationMethod
export UseQbmapParallelization
export UseThreadsParallelization

abstract type SindbadParallelizationMethod end
struct UseQbmapParallelization <:SindbadParallelizationMethod end
struct UseThreadsParallelization <:SindbadParallelizationMethod end

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
struct AllForwardModels <: SindbadSpinupMethod end
struct EtaScaleA0H <: SindbadSpinupMethod end
struct EtaScaleAH <: SindbadSpinupMethod end
struct NlsolveFixedpointTrustregionCEco <: SindbadSpinupMethod end
struct NlsolveFixedpointTrustregionCEcoTWS <: SindbadSpinupMethod end
struct NlsolveFixedpointTrustregionTWS <: SindbadSpinupMethod end
struct ODEAutoTsit5Rodas5 <: SindbadSpinupMethod end
struct ODEDP5 <: SindbadSpinupMethod end
struct ODETsit5 <: SindbadSpinupMethod end
struct SelSpinupModels <: SindbadSpinupMethod end
struct SSPDynamicSSTsit5 <: SindbadSpinupMethod end
struct SSPSSRootfind <: SindbadSpinupMethod end


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


struct SpinSequence
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SindbadSpinupMethod
    options::NamedTuple
end

# ------------------------- parallelization and model output options-------------------------
export SindbadOutputStrategyType
export DoOutputAll
export DoNotOutputAll
export DoSaveSingleFile
export DoNotSaveSingleFile
export UseQbmapParallelization
export UseThreadsParallelization

abstract type SindbadOutputStrategyType end
struct DoOutputAll <:SindbadOutputStrategyType end
struct DoNotOutputAll <:SindbadOutputStrategyType end
struct DoSaveSingleFile <:SindbadOutputStrategyType end
struct DoNotSaveSingleFile <:SindbadOutputStrategyType end

# ------------------------- model array types for internal model variables -------------------------
export SindbadModelArrayType
export ModelArrayArray
export ModelArrayStaticArray
export ModelArrayView

abstract type SindbadModelArrayType end
struct ModelArrayArray <:SindbadModelArrayType end
struct ModelArrayStaticArray <:SindbadModelArrayType end
struct ModelArrayView <:SindbadModelArrayType end


# ------------------------- output array types preallocated arrays -------------------------

export SindbadOutputArrayType
export OutputArray
export OutputMArray
export OutputSizedArray
export OutputYAXArray

abstract type SindbadOutputArrayType end
struct OutputArray <:SindbadOutputArrayType end
struct OutputMArray <:SindbadOutputArrayType end
struct OutputSizedArray <:SindbadOutputArrayType end
struct OutputYAXArray <:SindbadOutputArrayType end

export SindbadLandOutType
export LandOutArray
export LandOutArrayAll
export LandOutArrayFD
export LandOutArrayMT
export LandOutStacked
export LandOutTimeseries
export LandOutYAXArray

abstract type SindbadLandOutType end
struct LandOutArray <:SindbadLandOutType end
struct LandOutArrayAll <:SindbadLandOutType end
struct LandOutArrayFD <:SindbadLandOutType end
struct LandOutArrayMT <:SindbadLandOutType end
struct LandOutStacked <:SindbadLandOutType end
struct LandOutTimeseries <:SindbadLandOutType end
struct LandOutYAXArray <:SindbadLandOutType end
