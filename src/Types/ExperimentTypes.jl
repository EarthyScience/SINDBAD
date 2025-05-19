
export ExperimentTypes
abstract type ExperimentTypes <: SindbadTypes end
purpose(::Type{ExperimentTypes}) = "Abstract type for model run flags and experimental setup and simulations in SINDBAD"

# ------------------------- running flags -------------------------
export RunFlag
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


abstract type RunFlag <: ExperimentTypes end
purpose(::Type{RunFlag}) = "Abstract type for model run configuration flags in SINDBAD"

struct DoCalcCost <: RunFlag end
purpose(::Type{DoCalcCost}) = "Enable cost calculation between model output and observations"

struct DoNotCalcCost <: RunFlag end
purpose(::Type{DoNotCalcCost}) = "Disable cost calculation between model output and observations"

struct DoDebugModel <: RunFlag end
purpose(::Type{DoDebugModel}) = "Enable model debugging mode"

struct DoNotDebugModel <: RunFlag end
purpose(::Type{DoNotDebugModel}) = "Disable model debugging mode"

struct DoFilterNanPixels <: RunFlag end
purpose(::Type{DoFilterNanPixels}) = "Enable filtering of NaN values in spatial data"

struct DoNotFilterNanPixels <: RunFlag end
purpose(::Type{DoNotFilterNanPixels}) = "Disable filtering of NaN values in spatial data"

struct DoInlineUpdate <: RunFlag end
purpose(::Type{DoInlineUpdate}) = "Enable inline updates of model state"

struct DoNotInlineUpdate <: RunFlag end
purpose(::Type{DoNotInlineUpdate}) = "Disable inline updates of model state"

struct DoRunForward <: RunFlag end
purpose(::Type{DoRunForward}) = "Enable forward model run"

struct DoNotRunForward <: RunFlag end
purpose(::Type{DoNotRunForward}) = "Disable forward model run"

struct DoRunOptimization <: RunFlag end
purpose(::Type{DoRunOptimization}) = "Enable model parameter optimization"

struct DoNotRunOptimization <: RunFlag end
purpose(::Type{DoNotRunOptimization}) = "Disable model parameter optimization"

struct DoSaveInfo <: RunFlag end
purpose(::Type{DoSaveInfo}) = "Enable saving of model information"

struct DoNotSaveInfo <: RunFlag end
purpose(::Type{DoNotSaveInfo}) = "Disable saving of model information"

struct DoSpinupTEM <: RunFlag end
purpose(::Type{DoSpinupTEM}) = "Enable terrestrial ecosystem model spinup"

struct DoNotSpinupTEM <: RunFlag end
purpose(::Type{DoNotSpinupTEM}) = "Disable terrestrial ecosystem model spinup"

struct DoStoreSpinup <: RunFlag end
purpose(::Type{DoStoreSpinup}) = "Enable storing of spinup results"

struct DoNotStoreSpinup <: RunFlag end
purpose(::Type{DoNotStoreSpinup}) = "Disable storing of spinup results"

struct DoUseForwardDiff <: RunFlag end
purpose(::Type{DoUseForwardDiff}) = "Enable forward mode automatic differentiation"

struct DoNotUseForwardDiff <: RunFlag end
purpose(::Type{DoNotUseForwardDiff}) = "Disable forward mode automatic differentiation"

# ------------------------- parallelization options-------------------------
export ParallelizationPackage
export QbmapParallelization
export ThreadsParallelization


abstract type ParallelizationPackage <: ExperimentTypes end

purpose(::Type{ParallelizationPackage}) = "Abstract type for using different parallelization packages in SINDBAD"

struct QbmapParallelization <: ParallelizationPackage end
purpose(::Type{QbmapParallelization}) = "Use Qbmap for parallelization"

struct ThreadsParallelization <: ParallelizationPackage end
purpose(::Type{ThreadsParallelization}) = "Use Julia threads for parallelization"

# ------------------------- model output options-------------------------
export OutputStrategy
export DoOutputAll
export DoNotOutputAll
export DoSaveSingleFile
export DoNotSaveSingleFile

abstract type OutputStrategy <: ExperimentTypes end
purpose(::Type{OutputStrategy}) = "Abstract type for model output strategies in SINDBAD"

struct DoOutputAll <: OutputStrategy end
purpose(::Type{DoOutputAll}) = "Enable output of all model variables"

struct DoNotOutputAll <: OutputStrategy end
purpose(::Type{DoNotOutputAll}) = "Disable output of all model variables"

struct DoSaveSingleFile <: OutputStrategy end
purpose(::Type{DoSaveSingleFile}) = "Save all output variables in a single file"

struct DoNotSaveSingleFile <: OutputStrategy end
purpose(::Type{DoNotSaveSingleFile}) = "Save output variables in separate files"
