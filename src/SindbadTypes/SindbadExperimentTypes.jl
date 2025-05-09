
export SindbadExperimentType
abstract type SindbadExperimentType <: SindbadType end
purpose(::Type{SindbadExperimentType}) = "Abstract type for model run flags and experimental setup and simulations in SINDBAD"

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


abstract type SindbadRunFlag <: SindbadExperimentType end
purpose(::Type{SindbadRunFlag}) = "Abstract type for model run configuration flags in SINDBAD"

struct DoCalcCost <:SindbadRunFlag end
purpose(::Type{DoCalcCost}) = "Enable cost calculation between model output and observations"

struct DoNotCalcCost <:SindbadRunFlag end
purpose(::Type{DoNotCalcCost}) = "Disable cost calculation between model output and observations"

struct DoDebugModel <:SindbadRunFlag end
purpose(::Type{DoDebugModel}) = "Enable model debugging mode"

struct DoNotDebugModel <:SindbadRunFlag end
purpose(::Type{DoNotDebugModel}) = "Disable model debugging mode"

struct DoFilterNanPixels <:SindbadRunFlag end
purpose(::Type{DoFilterNanPixels}) = "Enable filtering of NaN values in spatial data"

struct DoNotFilterNanPixels <:SindbadRunFlag end
purpose(::Type{DoNotFilterNanPixels}) = "Disable filtering of NaN values in spatial data"

struct DoInlineUpdate <:SindbadRunFlag end
purpose(::Type{DoInlineUpdate}) = "Enable inline updates of model state"

struct DoNotInlineUpdate <:SindbadRunFlag end
purpose(::Type{DoNotInlineUpdate}) = "Disable inline updates of model state"

struct DoRunForward <:SindbadRunFlag end
purpose(::Type{DoRunForward}) = "Enable forward model run"

struct DoNotRunForward <:SindbadRunFlag end
purpose(::Type{DoNotRunForward}) = "Disable forward model run"

struct DoRunOptimization <:SindbadRunFlag end
purpose(::Type{DoRunOptimization}) = "Enable model parameter optimization"

struct DoNotRunOptimization <:SindbadRunFlag end
purpose(::Type{DoNotRunOptimization}) = "Disable model parameter optimization"

struct DoSaveInfo <:SindbadRunFlag end
purpose(::Type{DoSaveInfo}) = "Enable saving of model information"

struct DoNotSaveInfo <:SindbadRunFlag end
purpose(::Type{DoNotSaveInfo}) = "Disable saving of model information"

struct DoSpinupTEM <:SindbadRunFlag end
purpose(::Type{DoSpinupTEM}) = "Enable terrestrial ecosystem model spinup"

struct DoNotSpinupTEM <:SindbadRunFlag end
purpose(::Type{DoNotSpinupTEM}) = "Disable terrestrial ecosystem model spinup"

struct DoStoreSpinup <:SindbadRunFlag end
purpose(::Type{DoStoreSpinup}) = "Enable storing of spinup results"

struct DoNotStoreSpinup <:SindbadRunFlag end
purpose(::Type{DoNotStoreSpinup}) = "Disable storing of spinup results"

struct DoUseForwardDiff <:SindbadRunFlag end
purpose(::Type{DoUseForwardDiff}) = "Enable forward mode automatic differentiation"

struct DoNotUseForwardDiff <:SindbadRunFlag end
purpose(::Type{DoNotUseForwardDiff}) = "Disable forward mode automatic differentiation"

# ------------------------- parallelization options-------------------------
export SindbadParallelizationPackage
export UseQbmapParallelization
export UseThreadsParallelization


abstract type SindbadParallelizationPackage <: SindbadExperimentType end

purpose(::Type{SindbadParallelizationPackage}) = "Abstract type for using different parallelization packages in SINDBAD"

struct UseQbmapParallelization <:SindbadParallelizationPackage end
purpose(::Type{UseQbmapParallelization}) = "Use Qbmap for parallelization"

struct UseThreadsParallelization <:SindbadParallelizationPackage end
purpose(::Type{UseThreadsParallelization}) = "Use Julia threads for parallelization"

# ------------------------- model output options-------------------------
export SindbadOutputStrategyType
export DoOutputAll
export DoNotOutputAll
export DoSaveSingleFile
export DoNotSaveSingleFile

abstract type SindbadOutputStrategyType <: SindbadExperimentType end
purpose(::Type{SindbadOutputStrategyType}) = "Abstract type for model output strategies in SINDBAD"

struct DoOutputAll <:SindbadOutputStrategyType end
purpose(::Type{DoOutputAll}) = "Enable output of all model variables"

struct DoNotOutputAll <:SindbadOutputStrategyType end
purpose(::Type{DoNotOutputAll}) = "Disable output of all model variables"

struct DoSaveSingleFile <:SindbadOutputStrategyType end
purpose(::Type{DoSaveSingleFile}) = "Save all output variables in a single file"

struct DoNotSaveSingleFile <:SindbadOutputStrategyType end
purpose(::Type{DoNotSaveSingleFile}) = "Save output variables in separate files"
