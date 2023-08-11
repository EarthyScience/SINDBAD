# ------------------------- optimization algorithm -------------------------
export CMAEvolutionStrategy_CMAES
export Evolutionary_CMAES
export Optim_LBFGS
export Optim_BFGS
export Optimization_BBO_adaptive
export Optimization_BFGS
export Optimization_Fminbox_GradientDescent_FD
export Optimization_GCMAES
export Optimization_GCMAES_FD
export Optimization_MultistartOptimization
export Optimization_NelderMead

struct CMAEvolutionStrategy_CMAES end
struct Evolutionary_CMAES end
struct Optim_LBFGS end
struct Optim_BFGS end
struct Optimization_BBO_adaptive end
struct Optimization_BFGS end
struct Optimization_Fminbox_GradientDescent_FD end
struct Optimization_GCMAES end
struct Optimization_GCMAES_FD end
struct Optimization_MultistartOptimization end
struct Optimization_NelderMead end

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

# ------------------------- parallelization -------------------------
export UseQbmapParallelization
export UseThreadsParallelization

struct UseQbmapParallelization end
struct UseThreadsParallelization end
