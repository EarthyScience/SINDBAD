# ------------------------- optimization TEM and algorithm -------------------------
export SindbadOptimizationMethods
export BayesOptKMaternARD5
export CMAEvolutionStrategyCMAES
export EvolutionaryCMAES
export LandOutArray
export LandOutArrayAll
export LandOutArrayFD
export LandOutStacked
export LandOutTimeseries
export LandOutYAXArray
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

abstract type SindbadOptimizationMethods end
struct BayesOptKMaternARD5 <: SindbadOptimizationMethods end
struct CMAEvolutionStrategyCMAES <: SindbadOptimizationMethods end
struct EvolutionaryCMAES <: SindbadOptimizationMethods end
struct OptimLBFGS <: SindbadOptimizationMethods end
struct OptimBFGS <: SindbadOptimizationMethods end
struct OptimizationBBOadaptive <: SindbadOptimizationMethods end
struct OptimizationBBOxnes <: SindbadOptimizationMethods end
struct OptimizationBFGS <: SindbadOptimizationMethods end
struct OptimizationFminboxGradientDescent <: SindbadOptimizationMethods end
struct OptimizationFminboxGradientDescentFD <: SindbadOptimizationMethods end
struct OptimizationGCMAESDef <: SindbadOptimizationMethods end
struct OptimizationGCMAESFD <: SindbadOptimizationMethods end
struct OptimizationMultistartOptimization <: SindbadOptimizationMethods end
struct OptimizationNelderMead <: SindbadOptimizationMethods end
struct OptimizationQuadDirect <: SindbadOptimizationMethods end

# ------------------------- loss calculation -------------------------

export IsMultiObjectiveAlgorithm
export IsNotMultiObjectiveAlgorithm

struct IsMultiObjectiveAlgorithm end
struct IsNotMultiObjectiveAlgorithm end


export SindbadCost
export CostModelObs
export CostModelObsPriors

abstract type SindbadCost end
struct CostModelObs <: SindbadCost end
struct CostModelObsPriors <: SindbadCost end

# ------------------------- running flags -------------------------
export SindbadRunMethods
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
export UseQbmapParallelization
export UseThreadsParallelization


abstract type SindbadRunMethods end
struct DoCalcCost <:SindbadRunMethods end
struct DoNotCalcCost <:SindbadRunMethods end
struct DoDebugModel <:SindbadRunMethods end
struct DoNotDebugModel <:SindbadRunMethods end
struct DoFilterNanPixels <:SindbadRunMethods end
struct DoNotFilterNanPixels <:SindbadRunMethods end
struct DoInlineUpdate <:SindbadRunMethods end
struct DoNotInlineUpdate <:SindbadRunMethods end
struct DoRunForward <:SindbadRunMethods end
struct DoNotRunForward <:SindbadRunMethods end
struct DoRunOptimization <:SindbadRunMethods end
struct DoNotRunOptimization <:SindbadRunMethods end
struct DoSaveInfo <:SindbadRunMethods end
struct DoNotSaveInfo <:SindbadRunMethods end
struct DoSpinupTEM <:SindbadRunMethods end
struct DoNotSpinupTEM <:SindbadRunMethods end
struct DoStoreSpinup <:SindbadRunMethods end
struct DoNotStoreSpinup <:SindbadRunMethods end
struct DoUseForwardDiff <:SindbadRunMethods end
struct DoNotUseForwardDiff <:SindbadRunMethods end
struct UseQbmapParallelization <:SindbadRunMethods end
struct UseThreadsParallelization <:SindbadRunMethods end

# ------------------------- spinup methods -------------------------
export SindbadSpinupMethods
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

abstract type SindbadSpinupMethods end
struct AllForwardModels <: SindbadSpinupMethods end
struct EtaScaleA0H <: SindbadSpinupMethods end
struct EtaScaleAH <: SindbadSpinupMethods end
struct NlsolveFixedpointTrustregionCEco <: SindbadSpinupMethods end
struct NlsolveFixedpointTrustregionCEcoTWS <: SindbadSpinupMethods end
struct NlsolveFixedpointTrustregionTWS <: SindbadSpinupMethods end
struct ODEAutoTsit5Rodas5 <: SindbadSpinupMethods end
struct ODEDP5 <: SindbadSpinupMethods end
struct ODETsit5 <: SindbadSpinupMethods end
struct SelSpinupModels <: SindbadSpinupMethods end
struct SSPDynamicSSTsit5 <: SindbadSpinupMethods end
struct SSPSSRootfind <: SindbadSpinupMethods end


# spinup sequence and types
export SpinSequence
export SpinSequenceWithAggregator

struct SpinSequenceWithAggregator
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SindbadSpinupMethods
    options::NamedTuple
    aggregator_indices::Vector{Int}
    aggregator::Vector{TimeAggregator}
    aggregator_type::SindbadTimeAggregator
end


struct SpinSequence
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SindbadSpinupMethods
    options::NamedTuple
end

# ------------------------- parallelization and model output options-------------------------
export SindbadOutputMethods
abstract type SindbadOutputMethods end
export DoOutputAll
export DoNotOutputAll
export DoSaveSingleFile
export DoNotSaveSingleFile
export UseQbmapParallelization
export UseThreadsParallelization

struct DoOutputAll <:SindbadOutputMethods end
struct DoNotOutputAll <:SindbadOutputMethods end
struct DoSaveSingleFile <:SindbadOutputMethods end
struct DoNotSaveSingleFile <:SindbadOutputMethods end

# ------------------------- model array types for internal model variables -------------------------

export ModelArrayArray
export ModelArrayStaticArray
export ModelArrayView

struct ModelArrayArray <:SindbadOutputMethods end
struct ModelArrayStaticArray <:SindbadOutputMethods end
struct ModelArrayView <:SindbadOutputMethods end


# ------------------------- output array types preallocated arrays -------------------------

export OutputArray
export OutputMArray
export OutputSizedArray
export OutputYAXArray
export LandOutArray
export LandOutArrayAll
export LandOutArrayFD
export LandOutStacked
export LandOutTimeseries
export LandOutYAXArray

struct OutputArray <:SindbadOutputMethods end
struct OutputMArray <:SindbadOutputMethods end
struct OutputSizedArray <:SindbadOutputMethods end
struct OutputYAXArray <:SindbadOutputMethods end

struct LandOutArray <:SindbadOutputMethods end
struct LandOutArrayAll <:SindbadOutputMethods end
struct LandOutArrayFD <:SindbadOutputMethods end
struct LandOutStacked <:SindbadOutputMethods end
struct LandOutTimeseries <:SindbadOutputMethods end
struct LandOutYAXArray <:SindbadOutputMethods end
