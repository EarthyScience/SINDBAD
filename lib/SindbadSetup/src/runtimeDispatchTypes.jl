# ------------------------- optimization TEM and algorithm -------------------------
export CMAEvolutionStrategyCMAES
export EvolutionaryCMAES
export LandOutArray
export LandOutStacked
export LandOutTimeseries
export OptimLBFGS
export OptimBFGS
export OptimizationBBOadaptive
export OptimizationBFGS
export OptimizationFminboxGradientDescentFD
export OptimizationGCMAESDef
export OptimizationGCMAESFD
export OptimizationMultistartOptimization
export OptimizationNelderMead

struct CMAEvolutionStrategyCMAES end
struct EvolutionaryCMAES end
struct LandOutArray end
struct LandOutStacked end
struct LandOutTimeseries end
struct OptimLBFGS end
struct OptimBFGS end
struct OptimizationBBOadaptive end
struct OptimizationBFGS end
struct OptimizationFminboxGradientDescentFD end
struct OptimizationGCMAESDef end
struct OptimizationGCMAESFD end
struct OptimizationMultistartOptimization end
struct OptimizationNelderMead end

# ------------------------- loss calculation -------------------------

export IsMultiObjectiveAlgorithm
export IsNotMultiObjectiveAlgorithm

struct IsMultiObjectiveAlgorithm end
struct IsNotMultiObjectiveAlgorithm end

# ------------------------- running flags -------------------------

export DoCalcCost
export DoNotCalcCost
export DoDebugModel
export DoNotDebugModel
export DoUseForwardDiff
export DoNotUseForwardDiff
export DoInlineUpdate
export DoNotInlineUpdate
export DoRunForward
export DoNotRunForward
export DoRunOptimization
export DoNotRunOptimization
export DoSaveInfo
export DoNotSaveInfo
export DoLoadSpinup
export DoNotLoadSpinup
export DoSaveSpinup
export DoNotSaveSpinup
export DoSpinupTEM
export DoNotSpinupTEM
export DoStoreSpinup
export DoNotStoreSpinup
export DoRunSpinup
export DoNotRunSpinup

struct DoCalcCost end
struct DoNotCalcCost end
struct DoDebugModel end
struct DoNotDebugModel end
struct DoInlineUpdate end
struct DoNotInlineUpdate end
struct DoRunForward end
struct DoNotRunForward end
struct DoRunOptimization end
struct DoNotRunOptimization end
struct DoSaveInfo end
struct DoNotSaveInfo end
struct DoLoadSpinup end
struct DoNotLoadSpinup end
struct DoSaveSpinup end
struct DoNotSaveSpinup end
struct DoRunSpinup end
struct DoNotRunSpinup end
struct DoSpinupTEM end
struct DoNotSpinupTEM end
struct DoStoreSpinup end
struct DoNotStoreSpinup end
struct DoUseForwardDiff end
struct DoNotUseForwardDiff end

# ------------------------- spinup methods -------------------------

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

struct AllForwardModels end
struct EtaScaleA0H end
struct EtaScaleAH end
struct NlsolveFixedpointTrustregionCEco end
struct NlsolveFixedpointTrustregionCEcoTWS end
struct NlsolveFixedpointTrustregionTWS end
struct ODEAutoTsit5Rodas5 end
struct ODEDP5 end
struct ODETsit5 end
struct SelSpinupModels end
struct SSPDynamicSSTsit5 end
struct SSPSSRootfind end

# ------------------------- parallelization and model output options-------------------------

export DoOutputAll
export DoNotOutputAll
export DoSaveSingleFile
export DoNotSaveSingleFile
export UseQbmapParallelization
export UseThreadsParallelization

struct DoOutputAll end
struct DoNotOutputAll end
struct DoSaveSingleFile end
struct DoNotSaveSingleFile end
struct UseQbmapParallelization end
struct UseThreadsParallelization end

# ------------------------- model array types for internal model variables -------------------------

export ModelArrayArray
export ModelArrayStaticArray
export ModelArrayView

struct ModelArrayArray end
struct ModelArrayStaticArray end
struct ModelArrayView end


# ------------------------- output array types preallocated arrays -------------------------

export OutputArray
export OutputKeyedArray
export OutputMarray
export OutputSizedArray
export OutputYaxArray

struct OutputArray end
struct OutputKeyedArray end
struct OutputMarray end
struct OutputSizedArray end
struct OutputYaxArray end