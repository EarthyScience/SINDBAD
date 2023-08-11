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

# ------------------------- running flags -------------------------

export DoCalcCost
export DontCalcCost
export DoDebugModel
export DontDebugModel
export DoUseForwardDiff
export DontUseForwardDiff
export DoInlineUpdate
export DontInlineUpdate
export DoRunForward
export DontRunForward
export DoRunOptimization
export DontRunOptimization
export DoSaveInfo
export DontSaveInfo
export DoLoadSpinup
export DontLoadSpinup
export DoSaveSpinup
export DontSaveSpinup
export DoSpinupTEM
export DontSpinupTEM
export DoStoreSpinup
export DontStoreSpinup
export DoRunSpinup
export DontRunSpinup

struct DoCalcCost end
struct DontCalcCost end
struct DoDebugModel end
struct DontDebugModel end
struct DoInlineUpdate end
struct DontInlineUpdate end
struct DoRunForward end
struct DontRunForward end
struct DoRunOptimization end
struct DontRunOptimization end
struct DoSaveInfo end
struct DontSaveInfo end
struct DoLoadSpinup end
struct DontLoadSpinup end
struct DoSaveSpinup end
struct DontSaveSpinup end
struct DoRunSpinup end
struct DontRunSpinup end
struct DoSpinupTEM end
struct DontSpinupTEM end
struct DoStoreSpinup end
struct DontStoreSpinup end
struct DoUseForwardDiff end
struct DontUseForwardDiff end

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
