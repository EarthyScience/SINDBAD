@doc """

# ArrayTypes

Abstract type for all array types in SINDBAD

## Type Hierarchy

```ArrayTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `ModelArrayType`: Abstract type for internal model array types in SINDBAD 
     -  `ModelArrayArray`: Use standard Julia arrays for model variables 
     -  `ModelArrayStaticArray`: Use StaticArrays for model variables 
     -  `ModelArrayView`: Use array views for model variables 
 -  `OutputArrayType`: Abstract type for output array types in SINDBAD 
     -  `OutputArray`: Use standard Julia arrays for output 
     -  `OutputMArray`: Use MArray for output 
     -  `OutputSizedArray`: Use SizedArray for output 
     -  `OutputYAXArray`: Use YAXArray for output 



"""
SindbadCore.Types.ArrayTypes

@doc """

# ModelArrayType

Abstract type for internal model array types in SINDBAD

## Type Hierarchy

```ModelArrayType <: ArrayTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `ModelArrayArray`: Use standard Julia arrays for model variables 
 -  `ModelArrayStaticArray`: Use StaticArrays for model variables 
 -  `ModelArrayView`: Use array views for model variables 



"""
SindbadCore.Types.ModelArrayType

@doc """

# ModelArrayArray

Use standard Julia arrays for model variables

## Type Hierarchy

```ModelArrayArray <: ModelArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ModelArrayArray

@doc """

# ModelArrayStaticArray

Use StaticArrays for model variables

## Type Hierarchy

```ModelArrayStaticArray <: ModelArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ModelArrayStaticArray

@doc """

# ModelArrayView

Use array views for model variables

## Type Hierarchy

```ModelArrayView <: ModelArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ModelArrayView

@doc """

# OutputArrayType

Abstract type for output array types in SINDBAD

## Type Hierarchy

```OutputArrayType <: ArrayTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `OutputArray`: Use standard Julia arrays for output 
 -  `OutputMArray`: Use MArray for output 
 -  `OutputSizedArray`: Use SizedArray for output 
 -  `OutputYAXArray`: Use YAXArray for output 



"""
SindbadCore.Types.OutputArrayType

@doc """

# OutputArray

Use standard Julia arrays for output

## Type Hierarchy

```OutputArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OutputArray

@doc """

# OutputMArray

Use MArray for output

## Type Hierarchy

```OutputMArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OutputMArray

@doc """

# OutputSizedArray

Use SizedArray for output

## Type Hierarchy

```OutputSizedArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OutputSizedArray

@doc """

# OutputYAXArray

Use YAXArray for output

## Type Hierarchy

```OutputYAXArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OutputYAXArray

@doc """

# ExperimentTypes

Abstract type for model run flags and experimental setup and simulations in SINDBAD

## Type Hierarchy

```ExperimentTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `OutputStrategy`: Abstract type for model output strategies in SINDBAD 
     -  `DoNotOutputAll`: Disable output of all model variables 
     -  `DoNotSaveSingleFile`: Save output variables in separate files 
     -  `DoOutputAll`: Enable output of all model variables 
     -  `DoSaveSingleFile`: Save all output variables in a single file 
 -  `ParallelizationPackage`: Abstract type for using different parallelization packages in SINDBAD 
     -  `QbmapParallelization`: Use Qbmap for parallelization 
     -  `ThreadsParallelization`: Use Julia threads for parallelization 
 -  `RunFlag`: Abstract type for model run configuration flags in SINDBAD 
     -  `DoCalcCost`: Enable cost calculation between model output and observations 
     -  `DoDebugModel`: Enable model debugging mode 
     -  `DoFilterNanPixels`: Enable filtering of NaN values in spatial data 
     -  `DoInlineUpdate`: Enable inline updates of model state 
     -  `DoNotCalcCost`: Disable cost calculation between model output and observations 
     -  `DoNotDebugModel`: Disable model debugging mode 
     -  `DoNotFilterNanPixels`: Disable filtering of NaN values in spatial data 
     -  `DoNotInlineUpdate`: Disable inline updates of model state 
     -  `DoNotRunForward`: Disable forward model run 
     -  `DoNotRunOptimization`: Disable model parameter optimization 
     -  `DoNotSaveInfo`: Disable saving of model information 
     -  `DoNotSpinupTEM`: Disable terrestrial ecosystem model spinup 
     -  `DoNotStoreSpinup`: Disable storing of spinup results 
     -  `DoNotUseForwardDiff`: Disable forward mode automatic differentiation 
     -  `DoRunForward`: Enable forward model run 
     -  `DoRunOptimization`: Enable model parameter optimization 
     -  `DoSaveInfo`: Enable saving of model information 
     -  `DoSpinupTEM`: Enable terrestrial ecosystem model spinup 
     -  `DoStoreSpinup`: Enable storing of spinup results 
     -  `DoUseForwardDiff`: Enable forward mode automatic differentiation 



"""
SindbadCore.Types.ExperimentTypes

@doc """

# OutputStrategy

Abstract type for model output strategies in SINDBAD

## Type Hierarchy

```OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `DoNotOutputAll`: Disable output of all model variables 
 -  `DoNotSaveSingleFile`: Save output variables in separate files 
 -  `DoOutputAll`: Enable output of all model variables 
 -  `DoSaveSingleFile`: Save all output variables in a single file 



"""
SindbadCore.Types.OutputStrategy

@doc """

# DoNotOutputAll

Disable output of all model variables

## Type Hierarchy

```DoNotOutputAll <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotOutputAll

@doc """

# DoNotSaveSingleFile

Save output variables in separate files

## Type Hierarchy

```DoNotSaveSingleFile <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotSaveSingleFile

@doc """

# DoOutputAll

Enable output of all model variables

## Type Hierarchy

```DoOutputAll <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoOutputAll

@doc """

# DoSaveSingleFile

Save all output variables in a single file

## Type Hierarchy

```DoSaveSingleFile <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoSaveSingleFile

@doc """

# ParallelizationPackage

Abstract type for using different parallelization packages in SINDBAD

## Type Hierarchy

```ParallelizationPackage <: ExperimentTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `QbmapParallelization`: Use Qbmap for parallelization 
 -  `ThreadsParallelization`: Use Julia threads for parallelization 



"""
SindbadCore.Types.ParallelizationPackage

@doc """

# QbmapParallelization

Use Qbmap for parallelization

## Type Hierarchy

```QbmapParallelization <: ParallelizationPackage <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.QbmapParallelization

@doc """

# ThreadsParallelization

Use Julia threads for parallelization

## Type Hierarchy

```ThreadsParallelization <: ParallelizationPackage <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ThreadsParallelization

@doc """

# RunFlag

Abstract type for model run configuration flags in SINDBAD

## Type Hierarchy

```RunFlag <: ExperimentTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `DoCalcCost`: Enable cost calculation between model output and observations 
 -  `DoDebugModel`: Enable model debugging mode 
 -  `DoFilterNanPixels`: Enable filtering of NaN values in spatial data 
 -  `DoInlineUpdate`: Enable inline updates of model state 
 -  `DoNotCalcCost`: Disable cost calculation between model output and observations 
 -  `DoNotDebugModel`: Disable model debugging mode 
 -  `DoNotFilterNanPixels`: Disable filtering of NaN values in spatial data 
 -  `DoNotInlineUpdate`: Disable inline updates of model state 
 -  `DoNotRunForward`: Disable forward model run 
 -  `DoNotRunOptimization`: Disable model parameter optimization 
 -  `DoNotSaveInfo`: Disable saving of model information 
 -  `DoNotSpinupTEM`: Disable terrestrial ecosystem model spinup 
 -  `DoNotStoreSpinup`: Disable storing of spinup results 
 -  `DoNotUseForwardDiff`: Disable forward mode automatic differentiation 
 -  `DoRunForward`: Enable forward model run 
 -  `DoRunOptimization`: Enable model parameter optimization 
 -  `DoSaveInfo`: Enable saving of model information 
 -  `DoSpinupTEM`: Enable terrestrial ecosystem model spinup 
 -  `DoStoreSpinup`: Enable storing of spinup results 
 -  `DoUseForwardDiff`: Enable forward mode automatic differentiation 



"""
SindbadCore.Types.RunFlag

@doc """

# DoCalcCost

Enable cost calculation between model output and observations

## Type Hierarchy

```DoCalcCost <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoCalcCost

@doc """

# DoDebugModel

Enable model debugging mode

## Type Hierarchy

```DoDebugModel <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoDebugModel

@doc """

# DoFilterNanPixels

Enable filtering of NaN values in spatial data

## Type Hierarchy

```DoFilterNanPixels <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoFilterNanPixels

@doc """

# DoInlineUpdate

Enable inline updates of model state

## Type Hierarchy

```DoInlineUpdate <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoInlineUpdate

@doc """

# DoNotCalcCost

Disable cost calculation between model output and observations

## Type Hierarchy

```DoNotCalcCost <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotCalcCost

@doc """

# DoNotDebugModel

Disable model debugging mode

## Type Hierarchy

```DoNotDebugModel <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotDebugModel

@doc """

# DoNotFilterNanPixels

Disable filtering of NaN values in spatial data

## Type Hierarchy

```DoNotFilterNanPixels <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotFilterNanPixels

@doc """

# DoNotInlineUpdate

Disable inline updates of model state

## Type Hierarchy

```DoNotInlineUpdate <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotInlineUpdate

@doc """

# DoNotRunForward

Disable forward model run

## Type Hierarchy

```DoNotRunForward <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotRunForward

@doc """

# DoNotRunOptimization

Disable model parameter optimization

## Type Hierarchy

```DoNotRunOptimization <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotRunOptimization

@doc """

# DoNotSaveInfo

Disable saving of model information

## Type Hierarchy

```DoNotSaveInfo <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotSaveInfo

@doc """

# DoNotSpinupTEM

Disable terrestrial ecosystem model spinup

## Type Hierarchy

```DoNotSpinupTEM <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotSpinupTEM

@doc """

# DoNotStoreSpinup

Disable storing of spinup results

## Type Hierarchy

```DoNotStoreSpinup <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotStoreSpinup

@doc """

# DoNotUseForwardDiff

Disable forward mode automatic differentiation

## Type Hierarchy

```DoNotUseForwardDiff <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotUseForwardDiff

@doc """

# DoRunForward

Enable forward model run

## Type Hierarchy

```DoRunForward <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoRunForward

@doc """

# DoRunOptimization

Enable model parameter optimization

## Type Hierarchy

```DoRunOptimization <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoRunOptimization

@doc """

# DoSaveInfo

Enable saving of model information

## Type Hierarchy

```DoSaveInfo <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoSaveInfo

@doc """

# DoSpinupTEM

Enable terrestrial ecosystem model spinup

## Type Hierarchy

```DoSpinupTEM <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoSpinupTEM

@doc """

# DoStoreSpinup

Enable storing of spinup results

## Type Hierarchy

```DoStoreSpinup <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoStoreSpinup

@doc """

# DoUseForwardDiff

Enable forward mode automatic differentiation

## Type Hierarchy

```DoUseForwardDiff <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoUseForwardDiff

@doc """

# InputTypes

Abstract type for input data and processing related options in SINDBAD

## Type Hierarchy

```InputTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `DataFormatBackend`: Abstract type for input data backends in SINDBAD 
     -  `BackendNetcdf`: Use NetCDF format for input data 
     -  `BackendZarr`: Use Zarr format for input data 
 -  `ForcingTime`: Abstract type for forcing variable types in SINDBAD 
     -  `ForcingWithTime`: Forcing variable with time dimension 
     -  `ForcingWithoutTime`: Forcing variable without time dimension 
 -  `InputArrayBackend`: Abstract type for input data array types in SINDBAD 
     -  `InputArray`: Use standard Julia arrays for input data 
     -  `InputKeyedArray`: Use keyed arrays for input data 
     -  `InputNamedDimsArray`: Use named dimension arrays for input data 
     -  `InputYaxArray`: Use YAXArray for input data 
 -  `SpatialSubsetter`: Abstract type for spatial subsetting methods in SINDBAD 
     -  `SpaceID`: Use site ID (all caps) for spatial subsetting 
     -  `SpaceId`: Use site ID (capitalized) for spatial subsetting 
     -  `Spaceid`: Use site ID for spatial subsetting 
     -  `Spacelat`: Use latitude for spatial subsetting 
     -  `Spacelatitude`: Use full latitude for spatial subsetting 
     -  `Spacelon`: Use longitude for spatial subsetting 
     -  `Spacelongitude`: Use full longitude for spatial subsetting 
     -  `Spacesite`: Use site location for spatial subsetting 



"""
SindbadCore.Types.InputTypes

@doc """

# DataFormatBackend

Abstract type for input data backends in SINDBAD

## Type Hierarchy

```DataFormatBackend <: InputTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `BackendNetcdf`: Use NetCDF format for input data 
 -  `BackendZarr`: Use Zarr format for input data 



"""
SindbadCore.Types.DataFormatBackend

@doc """

# BackendNetcdf

Use NetCDF format for input data

## Type Hierarchy

```BackendNetcdf <: DataFormatBackend <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.BackendNetcdf

@doc """

# BackendZarr

Use Zarr format for input data

## Type Hierarchy

```BackendZarr <: DataFormatBackend <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.BackendZarr

@doc """

# ForcingWithTime

Forcing variable with time dimension

## Type Hierarchy

```ForcingWithTime <: ForcingTime <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ForcingWithTime

@doc """

# ForcingWithoutTime

Forcing variable without time dimension

## Type Hierarchy

```ForcingWithoutTime <: ForcingTime <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ForcingWithoutTime

@doc """

# InputArrayBackend

Abstract type for input data array types in SINDBAD

## Type Hierarchy

```InputArrayBackend <: InputTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `InputArray`: Use standard Julia arrays for input data 
 -  `InputKeyedArray`: Use keyed arrays for input data 
 -  `InputNamedDimsArray`: Use named dimension arrays for input data 
 -  `InputYaxArray`: Use YAXArray for input data 



"""
SindbadCore.Types.InputArrayBackend

@doc """

# InputArray

Use standard Julia arrays for input data

## Type Hierarchy

```InputArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.InputArray

@doc """

# InputKeyedArray

Use keyed arrays for input data

## Type Hierarchy

```InputKeyedArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.InputKeyedArray

@doc """

# InputNamedDimsArray

Use named dimension arrays for input data

## Type Hierarchy

```InputNamedDimsArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.InputNamedDimsArray

@doc """

# InputYaxArray

Use YAXArray for input data

## Type Hierarchy

```InputYaxArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.InputYaxArray

@doc """

# SpatialSubsetter

Abstract type for spatial subsetting methods in SINDBAD

## Type Hierarchy

```SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `SpaceID`: Use site ID (all caps) for spatial subsetting 
 -  `SpaceId`: Use site ID (capitalized) for spatial subsetting 
 -  `Spaceid`: Use site ID for spatial subsetting 
 -  `Spacelat`: Use latitude for spatial subsetting 
 -  `Spacelatitude`: Use full latitude for spatial subsetting 
 -  `Spacelon`: Use longitude for spatial subsetting 
 -  `Spacelongitude`: Use full longitude for spatial subsetting 
 -  `Spacesite`: Use site location for spatial subsetting 



"""
SindbadCore.Types.SpatialSubsetter

@doc """

# SpaceID

Use site ID (all caps) for spatial subsetting

## Type Hierarchy

```SpaceID <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SpaceID

@doc """

# SpaceId

Use site ID (capitalized) for spatial subsetting

## Type Hierarchy

```SpaceId <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SpaceId

@doc """

# Spaceid

Use site ID for spatial subsetting

## Type Hierarchy

```Spaceid <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spaceid

@doc """

# Spacelat

Use latitude for spatial subsetting

## Type Hierarchy

```Spacelat <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spacelat

@doc """

# Spacelatitude

Use full latitude for spatial subsetting

## Type Hierarchy

```Spacelatitude <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spacelatitude

@doc """

# Spacelon

Use longitude for spatial subsetting

## Type Hierarchy

```Spacelon <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spacelon

@doc """

# Spacelongitude

Use full longitude for spatial subsetting

## Type Hierarchy

```Spacelongitude <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spacelongitude

@doc """

# Spacesite

Use site location for spatial subsetting

## Type Hierarchy

```Spacesite <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spacesite

@doc """

# LandTypes

Abstract type for land related types that are typically used in preparing objects for model runs in SINDBAD

## Type Hierarchy

```LandTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `LandWrapperType`: Abstract type for land wrapper types in SINDBAD 
     -  `GroupView`: Represents a group of data within a `LandWrapper`, allowing access to specific groups of variables. 
     -  `LandWrapper`: Wraps the nested fields of a NamedTuple output of SINDBAD land into a nested structure of views that can be easily accessed with dot notation. 
 -  `PreAlloc`: Abstract type for preallocated land helpers types in prepTEM of SINDBAD 
     -  `PreAllocArray`: use a preallocated array for model output 
     -  `PreAllocArrayAll`: use a preallocated array to output all land variables 
     -  `PreAllocArrayFD`: use a preallocated array for finite difference (FD) hybrid experiments 
     -  `PreAllocArrayMT`: use arrays of nThreads size for land model output for replicates of multiple threads 
     -  `PreAllocStacked`: save output as a stacked vector of land using map over temporal dimension 
     -  `PreAllocTimeseries`: save land output as a preallocated vector for time series of land 
     -  `PreAllocYAXArray`: use YAX arrays for model output 



"""
SindbadCore.Types.LandTypes

@doc """

# PreAlloc

Abstract type for preallocated land helpers types in prepTEM of SINDBAD

## Type Hierarchy

```PreAlloc <: LandTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `PreAllocArray`: use a preallocated array for model output 
 -  `PreAllocArrayAll`: use a preallocated array to output all land variables 
 -  `PreAllocArrayFD`: use a preallocated array for finite difference (FD) hybrid experiments 
 -  `PreAllocArrayMT`: use arrays of nThreads size for land model output for replicates of multiple threads 
 -  `PreAllocStacked`: save output as a stacked vector of land using map over temporal dimension 
 -  `PreAllocTimeseries`: save land output as a preallocated vector for time series of land 
 -  `PreAllocYAXArray`: use YAX arrays for model output 



"""
SindbadCore.Types.PreAlloc

@doc """

# PreAllocArray

use a preallocated array for model output

## Type Hierarchy

```PreAllocArray <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocArray

@doc """

# PreAllocArrayAll

use a preallocated array to output all land variables

## Type Hierarchy

```PreAllocArrayAll <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocArrayAll

@doc """

# PreAllocArrayFD

use a preallocated array for finite difference (FD) hybrid experiments

## Type Hierarchy

```PreAllocArrayFD <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocArrayFD

@doc """

# PreAllocArrayMT

use arrays of nThreads size for land model output for replicates of multiple threads

## Type Hierarchy

```PreAllocArrayMT <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocArrayMT

@doc """

# PreAllocStacked

save output as a stacked vector of land using map over temporal dimension

## Type Hierarchy

```PreAllocStacked <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocStacked

@doc """

# PreAllocTimeseries

save land output as a preallocated vector for time series of land

## Type Hierarchy

```PreAllocTimeseries <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocTimeseries

@doc """

# PreAllocYAXArray

use YAX arrays for model output

## Type Hierarchy

```PreAllocYAXArray <: PreAlloc <: LandTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PreAllocYAXArray

@doc """

# MLTypes

Abstract type for types in machine learning related methods in SINDBAD

## Type Hierarchy

```MLTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `MLGradType`: Abstract type for automatic differentiation or finite differences for gradient calculations 
     -  `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
     -  `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
     -  `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
     -  `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
     -  `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
     -  `ZygoteGrad`: Use Zygote.jl for automatic differentiation 



"""
SindbadCore.Types.MLTypes

@doc """

# MLGradType

Abstract type for automatic differentiation or finite differences for gradient calculations

## Type Hierarchy

```MLGradType <: MLTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
 -  `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
 -  `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
 -  `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
 -  `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
 -  `ZygoteGrad`: Use Zygote.jl for automatic differentiation 



"""
SindbadCore.Types.MLGradType

@doc """

# EnzymeGrad

Use Enzyme.jl for automatic differentiation

## Type Hierarchy

```EnzymeGrad <: MLGradType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.EnzymeGrad

@doc """

# FiniteDiffGrad

Use FiniteDiff.jl for finite difference calculations

## Type Hierarchy

```FiniteDiffGrad <: MLGradType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.FiniteDiffGrad

@doc """

# FiniteDifferencesGrad

Use FiniteDifferences.jl for finite difference calculations

## Type Hierarchy

```FiniteDifferencesGrad <: MLGradType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.FiniteDifferencesGrad

@doc """

# ForwardDiffGrad

Use ForwardDiff.jl for automatic differentiation

## Type Hierarchy

```ForwardDiffGrad <: MLGradType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ForwardDiffGrad

@doc """

# PolyesterForwardDiffGrad

Use PolyesterForwardDiff.jl for automatic differentiation

## Type Hierarchy

```PolyesterForwardDiffGrad <: MLGradType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PolyesterForwardDiffGrad

@doc """

# ZygoteGrad

Use Zygote.jl for automatic differentiation

## Type Hierarchy

```ZygoteGrad <: MLGradType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ZygoteGrad

@doc """

# MetricTypes

Abstract type for performance metrics and cost calculation methods in SINDBAD

## Type Hierarchy

```MetricTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `DataAggrOrder`: Abstract type for data aggregation order in SINDBAD 
     -  `SpaceTime`: Aggregate data first over space, then over time 
     -  `TimeSpace`: Aggregate data first over time, then over space 
 -  `PerfMetric`: Abstract type for performance metrics in SINDBAD 
     -  `MSE`: Mean Squared Error: Measures the average squared difference between predicted and observed values 
     -  `NAME1R`: Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations 
     -  `NMAE1R`: Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations 
     -  `NNSE`: Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range 
     -  `NNSEInv`: Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range 
     -  `NNSEσ`: Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure 
     -  `NNSEσInv`: Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems 
     -  `NPcor`: Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range 
     -  `NPcorInv`: Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems 
     -  `NSE`: Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations 
     -  `NSEInv`: Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems 
     -  `NSEσ`: Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure 
     -  `NSEσInv`: Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems 
     -  `NScor`: Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range 
     -  `NScorInv`: Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems 
     -  `Pcor`: Pearson Correlation: Measures linear correlation between predictions and observations 
     -  `Pcor2`: Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations 
     -  `Pcor2Inv`: Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems 
     -  `PcorInv`: Inverse Pearson Correlation: Inverse of Pcor for minimization problems 
     -  `Scor`: Spearman Correlation: Measures monotonic relationship between predictions and observations 
     -  `Scor2`: Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations 
     -  `Scor2Inv`: Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems 
     -  `ScorInv`: Inverse Spearman Correlation: Inverse of Scor for minimization problems 
 -  `SpatialDataAggr`: Abstract type for spatial data aggregation methods in SINDBAD 
 -  `SpatialMetricAggr`: Abstract type for spatial metric aggregation methods in SINDBAD 
     -  `MetricMaximum`: Take maximum value across spatial dimensions 
     -  `MetricMinimum`: Take minimum value across spatial dimensions 
     -  `MetricSpatial`: Apply spatial aggregation to metrics 
     -  `MetricSum`: Sum values across spatial dimensions 



"""
SindbadCore.Types.MetricTypes

@doc """

# DataAggrOrder

Abstract type for data aggregation order in SINDBAD

## Type Hierarchy

```DataAggrOrder <: MetricTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `SpaceTime`: Aggregate data first over space, then over time 
 -  `TimeSpace`: Aggregate data first over time, then over space 



"""
SindbadCore.Types.DataAggrOrder

@doc """

# SpaceTime

Aggregate data first over space, then over time

## Type Hierarchy

```SpaceTime <: DataAggrOrder <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SpaceTime

@doc """

# TimeSpace

Aggregate data first over time, then over space

## Type Hierarchy

```TimeSpace <: DataAggrOrder <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeSpace

@doc """

# PerfMetric

Abstract type for performance metrics in SINDBAD

## Type Hierarchy

```PerfMetric <: MetricTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `MSE`: Mean Squared Error: Measures the average squared difference between predicted and observed values 
 -  `NAME1R`: Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations 
 -  `NMAE1R`: Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations 
 -  `NNSE`: Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range 
 -  `NNSEInv`: Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range 
 -  `NNSEσ`: Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure 
 -  `NNSEσInv`: Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems 
 -  `NPcor`: Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range 
 -  `NPcorInv`: Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems 
 -  `NSE`: Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations 
 -  `NSEInv`: Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems 
 -  `NSEσ`: Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure 
 -  `NSEσInv`: Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems 
 -  `NScor`: Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range 
 -  `NScorInv`: Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems 
 -  `Pcor`: Pearson Correlation: Measures linear correlation between predictions and observations 
 -  `Pcor2`: Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations 
 -  `Pcor2Inv`: Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems 
 -  `PcorInv`: Inverse Pearson Correlation: Inverse of Pcor for minimization problems 
 -  `Scor`: Spearman Correlation: Measures monotonic relationship between predictions and observations 
 -  `Scor2`: Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations 
 -  `Scor2Inv`: Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems 
 -  `ScorInv`: Inverse Spearman Correlation: Inverse of Scor for minimization problems 



"""
SindbadCore.Types.PerfMetric

@doc """

# MSE

Mean Squared Error: Measures the average squared difference between predicted and observed values

## Type Hierarchy

```MSE <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.MSE

@doc """

# NAME1R

Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations

## Type Hierarchy

```NAME1R <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NAME1R

@doc """

# NMAE1R

Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations

## Type Hierarchy

```NMAE1R <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NMAE1R

@doc """

# NNSE

Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range

## Type Hierarchy

```NNSE <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NNSE

@doc """

# NNSEInv

Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range

## Type Hierarchy

```NNSEInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NNSEInv

@doc """

# NNSEσ

Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure

## Type Hierarchy

```NNSEσ <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NNSEσ

@doc """

# NNSEσInv

Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems

## Type Hierarchy

```NNSEσInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NNSEσInv

@doc """

# NPcor

Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range

## Type Hierarchy

```NPcor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NPcor

@doc """

# NPcorInv

Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems

## Type Hierarchy

```NPcorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NPcorInv

@doc """

# NSE

Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations

## Type Hierarchy

```NSE <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NSE

@doc """

# NSEInv

Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems

## Type Hierarchy

```NSEInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NSEInv

@doc """

# NSEσ

Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure

## Type Hierarchy

```NSEσ <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NSEσ

@doc """

# NSEσInv

Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems

## Type Hierarchy

```NSEσInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NSEσInv

@doc """

# NScor

Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range

## Type Hierarchy

```NScor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NScor

@doc """

# NScorInv

Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems

## Type Hierarchy

```NScorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NScorInv

@doc """

# Pcor

Pearson Correlation: Measures linear correlation between predictions and observations

## Type Hierarchy

```Pcor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Pcor

@doc """

# Pcor2

Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations

## Type Hierarchy

```Pcor2 <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Pcor2

@doc """

# Pcor2Inv

Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems

## Type Hierarchy

```Pcor2Inv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Pcor2Inv

@doc """

# PcorInv

Inverse Pearson Correlation: Inverse of Pcor for minimization problems

## Type Hierarchy

```PcorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.PcorInv

@doc """

# Scor

Spearman Correlation: Measures monotonic relationship between predictions and observations

## Type Hierarchy

```Scor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Scor

@doc """

# Scor2

Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations

## Type Hierarchy

```Scor2 <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Scor2

@doc """

# Scor2Inv

Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems

## Type Hierarchy

```Scor2Inv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Scor2Inv

@doc """

# ScorInv

Inverse Spearman Correlation: Inverse of Scor for minimization problems

## Type Hierarchy

```ScorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ScorInv

@doc """

# SpatialDataAggr

Abstract type for spatial data aggregation methods in SINDBAD

## Type Hierarchy

```SpatialDataAggr <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SpatialDataAggr

@doc """

# SpatialMetricAggr

Abstract type for spatial metric aggregation methods in SINDBAD

## Type Hierarchy

```SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `MetricMaximum`: Take maximum value across spatial dimensions 
 -  `MetricMinimum`: Take minimum value across spatial dimensions 
 -  `MetricSpatial`: Apply spatial aggregation to metrics 
 -  `MetricSum`: Sum values across spatial dimensions 



"""
SindbadCore.Types.SpatialMetricAggr

@doc """

# MetricMaximum

Take maximum value across spatial dimensions

## Type Hierarchy

```MetricMaximum <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.MetricMaximum

@doc """

# MetricMinimum

Take minimum value across spatial dimensions

## Type Hierarchy

```MetricMinimum <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.MetricMinimum

@doc """

# MetricSpatial

Apply spatial aggregation to metrics

## Type Hierarchy

```MetricSpatial <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.MetricSpatial

@doc """

# MetricSum

Sum values across spatial dimensions

## Type Hierarchy

```MetricSum <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.MetricSum

@doc """

# ModelTypes

Abstract type for model types in SINDBAD

## Type Hierarchy

```ModelTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `DoCatchModelErrors`: Enable error catching during model execution 
 -  `DoNotCatchModelErrors`: Disable error catching during model execution 
 -  `LandEcosystem`: Abstract type for all SINDBAD land ecosystem models/approaches 
     -  `EVI`: Enhanced vegetation index 
         -  `EVI_constant`: sets EVI as a constant 
         -  `EVI_forcing`: sets land.states.EVI from forcing 
     -  `LAI`: Leaf area index 
         -  `LAI_cVegLeaf`: sets land.states.LAI from the carbon in the leaves of the previous time step 
         -  `LAI_constant`: sets LAI as a constant 
         -  `LAI_forcing`: sets land.states.LAI from forcing 
     -  `NDVI`: Normalized difference vegetation index 
         -  `NDVI_constant`: sets NDVI as a constant 
         -  `NDVI_forcing`: sets land.states.NDVI from forcing 
     -  `NDWI`: Normalized difference water index 
         -  `NDWI_constant`: sets NDWI as a constant 
         -  `NDWI_forcing`: sets land.states.NDWI from forcing 
     -  `NIRv`: Near-infrared reflectance of terrestrial vegetation 
         -  `NIRv_constant`: sets NIRv as a constant 
         -  `NIRv_forcing`: sets land.states.NIRv from forcing 
     -  `PET`: Set/get potential evapotranspiration 
         -  `PET_Lu2005`: Calculates land.fluxes.PET from the forcing variables 
         -  `PET_PriestleyTaylor1972`: Calculates land.fluxes.PET from the forcing variables 
         -  `PET_forcing`: sets land.fluxes.PET from the forcing 
     -  `PFT`: Vegetation PFT 
         -  `PFT_constant`: sets a uniform PFT class 
     -  `WUE`: Estimate wue 
         -  `WUE_Medlyn2011`: calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD & ambient co2 
         -  `WUE_VPDDay`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
         -  `WUE_VPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
         -  `WUE_constant`: calculates the WUE/AOE as a constant in space & time 
         -  `WUE_expVPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
     -  `ambientCO2`: sets/gets ambient CO2 concentration 
         -  `ambientCO2_constant`: sets ambient_CO2 to a constant value 
         -  `ambientCO2_forcing`: sets ambient_CO2 from forcing 
     -  `autoRespiration`: estimates autotrophic respiration for growth and maintenance 
         -  `autoRespiration_Thornley2000A`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL A - maintenance respiration is given priority. 
         -  `autoRespiration_Thornley2000B`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL B - growth respiration is given priority. 
         -  `autoRespiration_Thornley2000C`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL C - growth, degradation & resynthesis view of respiration. Computes the km [maintenance [respiration] coefficient]. 
         -  `autoRespiration_none`: sets the autotrophic respiration flux from all vegetation pools to zero. 
     -  `autoRespirationAirT`: temperature effect on autotrophic respiration 
         -  `autoRespirationAirT_Q10`: temperature effect on autotrophic maintenance respiration following a Q10 response model 
         -  `autoRespirationAirT_none`: sets the temperature effect on autotrophic respiration to one (i.e. no effect) 
     -  `cAllocation`: Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step). 
         -  `cAllocation_Friedlingstein1999`: Compute the fraction of fixed C that is allocated to the different plant organs following the scheme of Friedlingstein et al., 1999 (section ```Allocation response to multiple stresses````). 
         -  `cAllocation_GSI`: Compute the fraction of fixated C that is allocated to the different plant organs. The allocation is dynamic in time according to temperature, water & radiation stressors estimated following the GSI approach. Inspired by the work of Friedlingstein et al., 1999, based on Sharpe and Rykiel 1991, but here following the growing season index (GSI) as stress diagnostics, following Forkel et al 2014 and 2015, based on Jolly et al., 2005. 
         -  `cAllocation_fixed`: Compute the fraction of net primary production (NPP) allocated to different plant organs with fixed allocation parameters. 
The allocation is adjusted based on the TreeFrac fraction (land.states.frac_tree). 
Root allocation is further divided into fine (cf2Root) and coarse roots (cf2RootCoarse) according to the frac_fine_to_coarse parameter.
 
         -  `cAllocation_none`: sets the carbon allocation to zero (nothing to allocated) 
     -  `cAllocationLAI`: Estimates allocation to the leaf pool given light limitation constraints to photosynthesis. Estimation via dynamics in leaf area index (LAI). Dynamic allocation approach. 
         -  `cAllocationLAI_Friedlingstein1999`: Estimate the effect of light limitation on carbon allocation via leaf area index (LAI) based on Friedlingstein et al., 1999. 
         -  `cAllocationLAI_none`: sets the LAI effect on allocation to one (no effect) 
     -  `cAllocationNutrients`: (pseudo)effect of nutrients on carbon allocation 
         -  `cAllocationNutrients_Friedlingstein1999`: pseudo-nutrient limitation calculation based on Friedlingstein1999 
         -  `cAllocationNutrients_none`: sets the pseudo-nutrient limitation to one (no effect) 
     -  `cAllocationRadiation`: Effect of radiation on carbon allocation 
         -  `cAllocationRadiation_GSI`: radiation effect on allocation using GSI method 
         -  `cAllocationRadiation_RgPot`: radiation effect on allocation using potential radiation instead of actual one 
         -  `cAllocationRadiation_gpp`: radiation effect on allocation = the same for GPP 
         -  `cAllocationRadiation_none`: sets the radiation effect on allocation to one (no effect) 
     -  `cAllocationSoilT`: Effect of soil temperature on carbon allocation 
         -  `cAllocationSoilT_Friedlingstein1999`: partial temperature effect on decomposition/mineralization based on Friedlingstein1999 
         -  `cAllocationSoilT_gpp`: temperature effect on allocation = the same as gpp 
         -  `cAllocationSoilT_gppGSI`: temperature effect on allocation from same for GPP based on GSI approach 
         -  `cAllocationSoilT_none`: sets the temperature effect on allocation to one (no effect) 
     -  `cAllocationSoilW`: Effect of soil moisture on carbon allocation 
         -  `cAllocationSoilW_Friedlingstein1999`: partial moisture effect on decomposition/mineralization based on Friedlingstein1999 
         -  `cAllocationSoilW_gpp`: moisture effect on allocation = the same as gpp 
         -  `cAllocationSoilW_gppGSI`: moisture effect on allocation from same for GPP based on GSI approach 
         -  `cAllocationSoilW_none`: sets the moisture effect on allocation to one (no effect) 
     -  `cAllocationTreeFraction`: Adjustment of carbon allocation according to tree cover 
         -  `cAllocationTreeFraction_Friedlingstein1999`: adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning 
     -  `cBiomass`: Compute aboveground_biomass 
         -  `cBiomass_simple`: calculates aboveground biomass as a sum of wood and leaf carbon pools. 
         -  `cBiomass_treeGrass`: This serves the in situ optimization of eddy covariance sites when using AGB as a constraint. In locations where tree cover is not zero, AGB = leaf + wood. In locations where is only grass, there are no observational constraints for AGB. AGB from EO mostly refers to forested locations. To ensure that the parameter set that emerges from optimization does not generate wood, while not assuming any prior on mass of leafs, the aboveground biomass of grasses is set to the wood value, that will be constrained against a pseudo-observational value close to 0. One expects that after optimization, cVegWood_sum will be close to 0 in locations where frac_tree = 0. 
         -  `cBiomass_treeGrass_cVegReserveScaling`: same as treeGrass, but includes scaling for relative fraction of cVegReserve pool 
     -  `cCycle`: Allocate carbon to vegetation components 
         -  `cCycle_CASA`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools 
         -  `cCycle_GSI`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools 
         -  `cCycle_simple`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools 
     -  `cCycleBase`: Pool structure of the carbon cycle 
         -  `cCycleBase_CASA`: Compute carbon to nitrogen ratio & base turnover rates 
         -  `cCycleBase_GSI`: sets the basics for carbon cycle in the GSI approach 
         -  `cCycleBase_GSI_PlantForm`: sets the basics for carbon cycle  pools as in the GSI, but allows for scaling of turnover parameters based on plant forms 
         -  `cCycleBase_GSI_PlantForm_LargeKReserve`: same as cCycleBase_GSI_PlantForm but with a larger turnover of reserve so that it respires and flows 
         -  `cCycleBase_simple`: Compute carbon to nitrogen ratio & annual turnover rates 
     -  `cCycleConsistency`: Consistency checks on the c allocation and transfers between pools 
         -  `cCycleConsistency_simple`: check consistency in cCycle vector: c_allocation; cFlow 
     -  `cCycleDisturbance`: Disturb the carbon cycle pools 
         -  `cCycleDisturbance_WROASTED`: move all vegetation carbon pools except reserve to respective flow target when there is disturbance 
         -  `cCycleDisturbance_cFlow`: move all vegetation carbon pools except reserve to respective flow target when there is disturbance 
     -  `cFlow`: Actual transfers of c between pools (of diagonal components) 
         -  `cFlow_CASA`: combine all the effects that change the transfers between carbon pools 
         -  `cFlow_GSI`: compute the flow rates between the different pools. The flow rates are based on the GSI approach. The flow rates are computed based on the stressors (soil moisture, temperature, and light) and the slope of the stressors. The flow rates are computed for the following pools: leaf, root, reserve, and litter. The flow rates are computed for the following processes: leaf to reserve, root to reserve, reserve to leaf, reserve to root, shedding from leaf, and shedding from root. 
         -  `cFlow_none`: set transfer between pools to 0 [i.e. nothing is transfered] set c*giver & c*taker matrices to [] get the transfer matrix transfers 
         -  `cFlow_simple`: combine all the effects that change the transfers between carbon pools 
     -  `cFlowSoilProperties`: Effect of soil properties on the c transfers between pools 
         -  `cFlowSoilProperties_CASA`: effects of soil that change the transfers between carbon pools 
         -  `cFlowSoilProperties_none`: set transfer between pools to 0 [i.e. nothing is transfered] 
     -  `cFlowVegProperties`: Effect of vegetation properties on the c transfers between pools 
         -  `cFlowVegProperties_CASA`: effects of vegetation that change the transfers between carbon pools 
         -  `cFlowVegProperties_none`: set transfer between pools to 0 [i.e. nothing is transfered] 
     -  `cTau`: Combine effects of different factors on decomposition rates 
         -  `cTau_mult`: multiply all effects that change the turnover rates [k] 
         -  `cTau_none`: set the actual τ to ones 
     -  `cTauLAI`: Calculate litterfall scalars (that affect the changes in the vegetation k) 
         -  `cTauLAI_CASA`: calc LAI stressor on τ. Compute the seasonal cycle of litter fall & root litterfall based on LAI variations. Necessarily in precomputation mode 
         -  `cTauLAI_none`: set values to ones 
     -  `cTauSoilProperties`: Effect of soil texture on soil decomposition rates 
         -  `cTauSoilProperties_CASA`: Compute soil texture effects on turnover rates [k] of cMicSoil 
         -  `cTauSoilProperties_none`: Set soil texture effects to ones (ineficient, should be pix zix_mic) 
     -  `cTauSoilT`: Effect of soil temperature on decomposition rates 
         -  `cTauSoilT_Q10`: Compute effect of temperature on psoil carbon fluxes 
         -  `cTauSoilT_none`: set the outputs to ones 
     -  `cTauSoilW`: Effect of soil moisture on decomposition rates 
         -  `cTauSoilW_CASA`: Compute effect of soil moisture on soil decomposition as modelled in CASA [BGME - below grounf moisture effect]. The below ground moisture effect; taken directly from the century model; uses soil moisture from the previous month to determine a scalar that is then used to determine the moisture effect on below ground carbon fluxes. BGME is dependent on PET; Rainfall. This approach is designed to work for Rainfall & PET values at the monthly time step & it is necessary to scale it to meet that criterion. 
         -  `cTauSoilW_GSI`: calculate the moisture stress for cTau based on temperature stressor function of CASA & Potter 
         -  `cTauSoilW_none`: set the moisture stress for all carbon pools to ones 
     -  `cTauVegProperties`: Effect of vegetation properties on soil decomposition rates 
         -  `cTauVegProperties_CASA`: Compute effect of vegetation type on turnover rates [k] 
         -  `cTauVegProperties_none`: set the outputs to ones 
     -  `cVegetationDieOff`: Disturb the carbon cycle pools 
         -  `cVegetationDieOff_forcing`: reads and passes along to the land diagnostics the fraction of vegetation pools that die off  
     -  `capillaryFlow`: Flux of water from lower to upper soil layers (upward soil moisture movement) 
         -  `capillaryFlow_VanDijk2010`: computes the upward water flow in the soil layers 
     -  `deriveVariables`: Derive extra variables 
         -  `deriveVariables_simple`: derives variables from other sindbad models and saves them into land.deriveVariables 
     -  `drainage`: Recharge the soil 
         -  `drainage_dos`: downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation 
         -  `drainage_kUnsat`: downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity 
         -  `drainage_wFC`: downward flow of moisture [drainage] in soil layers based on overflow over field capacity 
     -  `evaporation`: Soil evaporation 
         -  `evaporation_Snyder2000`: calculates the bare soil evaporation using relative drying rate of soil 
         -  `evaporation_bareFraction`: calculates the bare soil evaporation from 1-frac*vegetation of the grid & PET*evaporation 
         -  `evaporation_demandSupply`: calculates the bare soil evaporation from demand-supply limited approach.  
         -  `evaporation_fAPAR`: calculates the bare soil evaporation from 1-fAPAR & PET soil 
         -  `evaporation_none`: sets the soil evaporation to zero 
         -  `evaporation_vegFraction`: calculates the bare soil evaporation from 1-frac_vegetation & PET soil 
     -  `evapotranspiration`: Calculate the evapotranspiration as a sum of components 
         -  `evapotranspiration_sum`: calculates evapotranspiration as a sum of all potential components 
     -  `fAPAR`: Fraction of absorbed photosynthetically active radiation 
         -  `fAPAR_EVI`: calculates fAPAR as a linear function of EVI 
         -  `fAPAR_LAI`: sets fAPAR as a function of LAI 
         -  `fAPAR_cVegLeaf`: Compute FAPAR based on carbon pool of the leave; SLA; kLAI 
         -  `fAPAR_cVegLeafBareFrac`: Compute FAPAR based on carbon pool of the leaf, but only for the vegetation fraction 
         -  `fAPAR_constant`: sets fAPAR as a constant 
         -  `fAPAR_forcing`: sets land.states.fAPAR from forcing 
         -  `fAPAR_vegFraction`: sets fAPAR as a linear function of vegetation fraction 
     -  `getPools`: Get the amount of water at the beginning of timestep 
         -  `getPools_simple`: gets the amount of water available for the current time step 
     -  `gpp`: Combine effects as multiplicative or minimum; if coupled, uses transup 
         -  `gpp_coupled`: calculate GPP based on transpiration supply & water use efficiency [coupled] 
         -  `gpp_min`: compute the actual GPP with potential scaled by minimum stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration] 
         -  `gpp_mult`: compute the actual GPP with potential scaled by multiplicative stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration] 
         -  `gpp_none`: sets the actual GPP to zero 
         -  `gpp_transpirationWUE`: calculate GPP based on transpiration & water use efficiency 
     -  `gppAirT`: Effect of temperature 
         -  `gppAirT_CASA`: temperature stress for gpp_potential based on CASA & Potter 
         -  `gppAirT_GSI`: temperature stress on gpp_potential based on GSI implementation of LPJ 
         -  `gppAirT_MOD17`: temperature stress on gpp_potential based on GPP - MOD17 model 
         -  `gppAirT_Maekelae2008`: temperature stress on gpp_potential based on Maekelae2008 [eqn 3 & 4] 
         -  `gppAirT_TEM`: temperature stress for gpp_potential based on TEM 
         -  `gppAirT_Wang2014`: temperature stress on gpp_potential based on Wang2014 
         -  `gppAirT_none`: sets the temperature stress on gpp_potential to one (no stress) 
     -  `gppDemand`: Combine effects as multiplicative or minimum 
         -  `gppDemand_min`: compute the demand GPP as minimum of all stress scalars [most limited] 
         -  `gppDemand_mult`: compute the demand GPP as multipicative stress scalars 
         -  `gppDemand_none`: sets the scalar for demand GPP to ones & demand GPP to zero 
     -  `gppDiffRadiation`: Effect of diffuse radiation 
         -  `gppDiffRadiation_GSI`: cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ 
         -  `gppDiffRadiation_Turner2006`: cloudiness scalar [radiation diffusion] on gpp_potential based on Turner2006 
         -  `gppDiffRadiation_Wang2015`: cloudiness scalar [radiation diffusion] on gpp_potential based on Wang2015 
         -  `gppDiffRadiation_none`: sets the cloudiness scalar [radiation diffusion] for gpp_potential to one 
     -  `gppDirRadiation`: Effect of direct radiation 
         -  `gppDirRadiation_Maekelae2008`: light saturation scalar [light effect] on gpp_potential based on Maekelae2008 
         -  `gppDirRadiation_none`: sets the light saturation scalar [light effect] on gpp_potential to one 
     -  `gppPotential`: Maximum instantaneous radiation use efficiency 
         -  `gppPotential_Monteith`: set the potential GPP based on radiation use efficiency 
     -  `gppSoilW`: soil moisture stress on GPP 
         -  `gppSoilW_CASA`: soil moisture stress on gpp_potential based on base stress and relative ratio of PET and PAW (CASA) 
         -  `gppSoilW_GSI`: soil moisture stress on gpp_potential based on GSI implementation of LPJ 
         -  `gppSoilW_Keenan2009`: soil moisture stress on gpp_potential based on Keenan2009 
         -  `gppSoilW_Stocker2020`: soil moisture stress on gpp_potential based on Stocker2020 
         -  `gppSoilW_none`: sets the soil moisture stress on gpp_potential to one (no stress) 
     -  `gppVPD`: Vpd effect 
         -  `gppVPD_MOD17`: VPD stress on gpp_potential based on MOD17 model 
         -  `gppVPD_Maekelae2008`: calculate the VPD stress on gpp_potential based on Maekelae2008 [eqn 5] 
         -  `gppVPD_PRELES`: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect based on PRELES model 
         -  `gppVPD_expco2`: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect 
         -  `gppVPD_none`: sets the VPD stress on gpp_potential to one (no stress) 
     -  `groundWRecharge`: Recharge to the groundwater storage 
         -  `groundWRecharge_dos`: GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer 
         -  `groundWRecharge_fraction`: GW recharge as a fraction of moisture of the lowermost soil layer 
         -  `groundWRecharge_kUnsat`: GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer 
         -  `groundWRecharge_none`: sets the GW recharge to zero 
     -  `groundWSoilWInteraction`: Groundwater soil moisture interactions (e.g. capilary flux, water 
         -  `groundWSoilWInteraction_VanDijk2010`: calculates the upward flow of water from groundwater to lowermost soil layer using VanDijk method 
         -  `groundWSoilWInteraction_gradient`: calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low 
         -  `groundWSoilWInteraction_gradientNeg`: calculates a buffer storage that doesn't give water to the soil when the soil dries up; while the soil gives water to the groundW when the soil is wet but the groundW low; the groundW is only recharged by soil moisture 
         -  `groundWSoilWInteraction_none`: sets the groundwater capillary flux to zero 
     -  `groundWSurfaceWInteraction`: Water exchange between surface and groundwater 
         -  `groundWSurfaceWInteraction_fracGradient`: calculates the moisture exchange between groundwater & surface water as a fraction of difference between the storages 
         -  `groundWSurfaceWInteraction_fracGroundW`: calculates the depletion of groundwater to the surface water as a fraction of groundwater storage 
     -  `interception`: Interception evaporation 
         -  `interception_Miralles2010`: computes canopy interception evaporation according to the Gash model 
         -  `interception_fAPAR`: computes canopy interception evaporation as a fraction of fAPAR 
         -  `interception_none`: sets the interception evaporation to zero 
         -  `interception_vegFraction`: computes canopy interception evaporation as a fraction of vegetation cover 
     -  `percolation`: Calculate the soil percolation = wbp at this point 
         -  `percolation_WBP`: computes the percolation into the soil after the surface runoff process 
     -  `plantForm`: define the plant form of the ecosystem 
         -  `plantForm_PFT`: get the plant form based on PFT 
         -  `plantForm_fixed`: use a fixed plant form with 1: tree, 2: shrub, 3:herb 
     -  `rainIntensity`: Set rainfall intensity 
         -  `rainIntensity_forcing`: stores the time series of rainfall & snowfall from forcing 
         -  `rainIntensity_simple`: stores the time series of rainfall intensity 
     -  `rainSnow`: Set/get rain and snow 
         -  `rainSnow_Tair`: separates the rain & snow based on temperature threshold 
         -  `rainSnow_forcing`: stores the time series of rainfall and snowfall from forcing & scale snowfall if snowfall_scalar parameter is optimized 
         -  `rainSnow_rain`: set all precip to rain 
     -  `rootMaximumDepth`: Maximum rooting depth 
         -  `rootMaximumDepth_fracSoilD`: sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD 
     -  `rootWaterEfficiency`: Distribution of water uptake fraction/efficiency by root per soil layer 
         -  `rootWaterEfficiency_constant`: sets the maximum fraction of water that root can uptake from soil layers as constant 
         -  `rootWaterEfficiency_expCvegRoot`: maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot] 
         -  `rootWaterEfficiency_k2Layer`: sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers 
         -  `rootWaterEfficiency_k2fRD`: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; & for the second soil layer additional as function of RD 
         -  `rootWaterEfficiency_k2fvegFraction`: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction 
     -  `rootWaterUptake`: Root water uptake (extract water from soil) 
         -  `rootWaterUptake_proportion`: rootUptake from each soil layer proportional to the relative plant water availability in the layer 
         -  `rootWaterUptake_topBottom`: rootUptake from each of the soil layer from top to bottom using all water in each layer 
     -  `runoff`: Calculate the total runoff as a sum of components 
         -  `runoff_sum`: calculates runoff as a sum of all potential components 
     -  `runoffBase`: Baseflow 
         -  `runoffBase_Zhang2008`: computes baseflow from a linear ground water storage 
         -  `runoffBase_none`: sets the base runoff to zero 
     -  `runoffInfiltrationExcess`: Infiltration excess runoff 
         -  `runoffInfiltrationExcess_Jung`: infiltration excess runoff as a function of rainintensity and vegetated fraction 
         -  `runoffInfiltrationExcess_kUnsat`: infiltration excess runoff based on unsaτurated hydraulic conductivity 
         -  `runoffInfiltrationExcess_none`: sets infiltration excess runoff to zero 
     -  `runoffInterflow`: Interflow 
         -  `runoffInterflow_none`: sets interflow runoff to zero 
         -  `runoffInterflow_residual`: interflow as a fraction of the available water balance pool 
     -  `runoffOverland`: calculates total overland runoff that passes to the surface storage 
         -  `runoffOverland_Inf`: ## assumes overland flow to be infiltration excess runoff 
         -  `runoffOverland_InfIntSat`: assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs 
         -  `runoffOverland_Sat`: assumes overland flow to be saturation excess runoff 
         -  `runoffOverland_none`: sets overland runoff to zero 
     -  `runoffSaturationExcess`: Saturation runoff 
         -  `runoffSaturationExcess_Bergstroem1992`: saturation excess runoff using original Bergström method 
         -  `runoffSaturationExcess_Bergstroem1992MixedVegFraction`: saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions 
         -  `runoffSaturationExcess_Bergstroem1992VegFraction`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction 
         -  `runoffSaturationExcess_Bergstroem1992VegFractionFroSoil`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and frozen soil fraction 
         -  `runoffSaturationExcess_Bergstroem1992VegFractionPFT`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and PFT 
         -  `runoffSaturationExcess_Zhang2008`: saturation excess runoff as a function of incoming water and PET 
         -  `runoffSaturationExcess_none`: set the saturation excess runoff to zero 
         -  `runoffSaturationExcess_satFraction`: saturation excess runoff as a fraction of saturated fraction of land 
     -  `runoffSurface`: Surface runoff generation process 
         -  `runoffSurface_Orth2013`: calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff 
         -  `runoffSurface_Trautmann2018`: calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 & as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 & as it is used in Trautmannet al. 2018 
         -  `runoffSurface_all`: assumes all overland runoff is lost as surface runoff 
         -  `runoffSurface_directIndirect`: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage 
         -  `runoffSurface_directIndirectFroSoil`: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid 
         -  `runoffSurface_indirect`: assumes all overland runoff is recharged to surface water first, which then generates surface runoff 
         -  `runoffSurface_none`: sets surface runoff [surface_runoff] from the storage to zero 
     -  `saturatedFraction`: Saturated fraction of a grid cell 
         -  `saturatedFraction_none`: sets the land.states.soilWSatFrac [saturated soil fraction] to zero 
     -  `snowFraction`: Calculate snow cover fraction 
         -  `snowFraction_HTESSEL`: computes the snow pack & fraction of snow cover following the HTESSEL approach 
         -  `snowFraction_binary`: compute the fraction of snow cover. 
         -  `snowFraction_none`: sets the snow fraction to zero 
     -  `snowMelt`: Calculate snowmelt and update s.w.wsnow 
         -  `snowMelt_Tair`: computes the snow melt term as function of air temperature 
         -  `snowMelt_TairRn`: instantiate the potential snow melt based on temperature & net radiation on days with f*airT > 0.0°C. instantiate the potential snow melt based on temperature & net radiation on days with f*airT > 0.0 °C 
     -  `soilProperties`: Soil properties (hydraulic properties) 
         -  `soilProperties_Saxton1986`: assigns the soil hydraulic properties based on Saxton; 1986 
         -  `soilProperties_Saxton2006`: assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.sp_ 
     -  `soilTexture`: Soil texture (sand,silt,clay, and organic matter fraction) 
         -  `soilTexture_constant`: sets the soil texture properties as constant 
         -  `soilTexture_forcing`: sets the soil texture properties from input 
     -  `soilWBase`: Distribution of soil hydraulic properties over depth 
         -  `soilWBase_smax1Layer`: defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the model_structure.json based on the TWS model for the Northern Hemisphere 
         -  `soilWBase_smax2Layer`: defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the model_structure.json based on the older version of the Pre-Tokyo Model 
         -  `soilWBase_smax2fRD4`: defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing 
         -  `soilWBase_uniform`: distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties 
     -  `sublimation`: Calculate sublimation and update snow water equivalent 
         -  `sublimation_GLEAM`: instantiates the Priestley-Taylor term for sublimation following GLEAM. computes sublimation following GLEAM 
         -  `sublimation_none`: sets the snow sublimation to zero 
     -  `transpiration`: calclulate the actual transpiration 
         -  `transpiration_coupled`: calculate the actual transpiration as function of gpp & WUE 
         -  `transpiration_demandSupply`: calculate the actual transpiration as the minimum of the supply & demand 
         -  `transpiration_none`: sets the actual transpiration to zero 
     -  `transpirationDemand`: Demand-driven transpiration 
         -  `transpirationDemand_CASA`: calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model 
         -  `transpirationDemand_PET`: calculate the climate driven demand for transpiration as a function of PET & α for vegetation 
         -  `transpirationDemand_PETfAPAR`: calculate the climate driven demand for transpiration as a function of PET & fAPAR 
         -  `transpirationDemand_PETvegFraction`: calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction 
     -  `transpirationSupply`: Supply-limited transpiration 
         -  `transpirationSupply_CASA`: calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model 
         -  `transpirationSupply_Federer1982`: calculate the supply limited transpiration as a function of max rate parameter & avaialable water 
         -  `transpirationSupply_wAWC`: calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture 
         -  `transpirationSupply_wAWCvegFraction`: calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions 
     -  `treeFraction`: Fractional coverage of trees 
         -  `treeFraction_constant`: sets frac_tree as a constant 
         -  `treeFraction_forcing`: sets land.states.frac_tree from forcing 
     -  `vegAvailableWater`: Plant available water 
         -  `vegAvailableWater_rootWaterEfficiency`: sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants 
         -  `vegAvailableWater_sigmoid`: calculate the actual amount of water that is available for plants 
     -  `vegFraction`: Fractional coverage of vegetation 
         -  `vegFraction_constant`: sets frac_vegetation as a constant 
         -  `vegFraction_forcing`: sets land.states.frac_vegetation from forcing 
         -  `vegFraction_scaledEVI`: sets frac_vegetation by scaling the EVI value 
         -  `vegFraction_scaledLAI`: sets frac_vegetation by scaling the LAI value 
         -  `vegFraction_scaledNDVI`: sets frac_vegetation by scaling the NDVI value 
         -  `vegFraction_scaledNIRv`: sets frac_vegetation by scaling the NIRv value 
         -  `vegFraction_scaledfAPAR`: sets frac_vegetation by scaling the fAPAR value 
     -  `wCycle`: Apply the delta storage changes to storage variables 
         -  `wCycle_combined`: computes the algebraic sum of storage and delta storage 
         -  `wCycle_components`: update the water cycle pools per component 
     -  `wCycleBase`: set the basics of the water cycle pools 
         -  `wCycleBase_simple`: counts the number of layers in each water storage pools 
     -  `waterBalance`: Calculate the water balance 
         -  `waterBalance_simple`: check the water balance in every time step 



"""
SindbadCore.Types.ModelTypes

@doc """

# DoCatchModelErrors

Enable error catching during model execution

## Type Hierarchy

```DoCatchModelErrors <: ModelTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoCatchModelErrors

@doc """

# DoNotCatchModelErrors

Disable error catching during model execution

## Type Hierarchy

```DoNotCatchModelErrors <: ModelTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.DoNotCatchModelErrors

@doc """

# OptimizationTypes

Abstract type for optimization related functions and methods in SINDBAD

## Type Hierarchy

```OptimizationTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `CostMethod`: Abstract type for cost calculation methods in SINDBAD 
     -  `CostModelObs`: cost calculation between model output and observations 
     -  `CostModelObsLandTS`: cost calculation between land model output and time series observations 
     -  `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
     -  `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 
 -  `GSAMethod`: Abstract type for global sensitivity analysis methods in SINDBAD 
     -  `GSAMorris`: Morris method for global sensitivity analysis 
     -  `GSASobol`: Sobol method for global sensitivity analysis 
     -  `GSASobolDM`: Sobol method with derivative-based measures for global sensitivity analysis 
 -  `OptimizationMethod`: Abstract type for optimization methods in SINDBAD 
     -  `BayesOptKMaternARD5`: Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl 
     -  `CMAEvolutionStrategyCMAES`: Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl 
     -  `EvolutionaryCMAES`: Evolutionary version of CMA-ES optimization from Evolutionary.jl 
     -  `OptimBFGS`: Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl 
     -  `OptimLBFGS`: Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl 
     -  `OptimizationBBOadaptive`: Black Box Optimization with adaptive parameters from Optimization.jl 
     -  `OptimizationBBOxnes`: Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl 
     -  `OptimizationBFGS`: BFGS optimization with box constraints from Optimization.jl 
     -  `OptimizationFminboxGradientDescent`: Gradient descent optimization with box constraints from Optimization.jl 
     -  `OptimizationFminboxGradientDescentFD`: Gradient descent optimization with box constraints using forward differentiation from Optimization.jl 
     -  `OptimizationGCMAESDef`: Global CMA-ES optimization with default settings from Optimization.jl 
     -  `OptimizationGCMAESFD`: Global CMA-ES optimization using forward differentiation from Optimization.jl 
     -  `OptimizationMultistartOptimization`: Multi-start optimization to find global optimum from Optimization.jl 
     -  `OptimizationNelderMead`: Nelder-Mead simplex optimization method from Optimization.jl 
     -  `OptimizationQuadDirect`: Quadratic Direct optimization method from Optimization.jl 
 -  `ParameterScaling`: Abstract type for parameter scaling methods in SINDBAD 
     -  `ScaleBounds`: Scale parameters relative to their bounds 
     -  `ScaleDefault`: Scale parameters relative to default values 
     -  `ScaleNone`: No parameter scaling applied 



"""
SindbadCore.Types.OptimizationTypes

@doc """

# CostMethod

Abstract type for cost calculation methods in SINDBAD

## Type Hierarchy

```CostMethod <: OptimizationTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `CostModelObs`: cost calculation between model output and observations 
 -  `CostModelObsLandTS`: cost calculation between land model output and time series observations 
 -  `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
 -  `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 



"""
SindbadCore.Types.CostMethod

@doc """

# CostModelObs

cost calculation between model output and observations

## Type Hierarchy

```CostModelObs <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CostModelObs

@doc """

# CostModelObsLandTS

cost calculation between land model output and time series observations

## Type Hierarchy

```CostModelObsLandTS <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CostModelObsLandTS

@doc """

# CostModelObsMT

multi-threaded cost calculation between model output and observations

## Type Hierarchy

```CostModelObsMT <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CostModelObsMT

@doc """

# CostModelObsPriors

cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET

## Type Hierarchy

```CostModelObsPriors <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CostModelObsPriors

@doc """

# GSAMethod

Abstract type for global sensitivity analysis methods in SINDBAD

## Type Hierarchy

```GSAMethod <: OptimizationTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `GSAMorris`: Morris method for global sensitivity analysis 
 -  `GSASobol`: Sobol method for global sensitivity analysis 
 -  `GSASobolDM`: Sobol method with derivative-based measures for global sensitivity analysis 



"""
SindbadCore.Types.GSAMethod

@doc """

# GSAMorris

Morris method for global sensitivity analysis

## Type Hierarchy

```GSAMorris <: GSAMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.GSAMorris

@doc """

# GSASobol

Sobol method for global sensitivity analysis

## Type Hierarchy

```GSASobol <: GSAMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.GSASobol

@doc """

# GSASobolDM

Sobol method with derivative-based measures for global sensitivity analysis

## Type Hierarchy

```GSASobolDM <: GSAMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.GSASobolDM

@doc """

# OptimizationMethod

Abstract type for optimization methods in SINDBAD

## Type Hierarchy

```OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `BayesOptKMaternARD5`: Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl 
 -  `CMAEvolutionStrategyCMAES`: Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl 
 -  `EvolutionaryCMAES`: Evolutionary version of CMA-ES optimization from Evolutionary.jl 
 -  `OptimBFGS`: Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl 
 -  `OptimLBFGS`: Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl 
 -  `OptimizationBBOadaptive`: Black Box Optimization with adaptive parameters from Optimization.jl 
 -  `OptimizationBBOxnes`: Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl 
 -  `OptimizationBFGS`: BFGS optimization with box constraints from Optimization.jl 
 -  `OptimizationFminboxGradientDescent`: Gradient descent optimization with box constraints from Optimization.jl 
 -  `OptimizationFminboxGradientDescentFD`: Gradient descent optimization with box constraints using forward differentiation from Optimization.jl 
 -  `OptimizationGCMAESDef`: Global CMA-ES optimization with default settings from Optimization.jl 
 -  `OptimizationGCMAESFD`: Global CMA-ES optimization using forward differentiation from Optimization.jl 
 -  `OptimizationMultistartOptimization`: Multi-start optimization to find global optimum from Optimization.jl 
 -  `OptimizationNelderMead`: Nelder-Mead simplex optimization method from Optimization.jl 
 -  `OptimizationQuadDirect`: Quadratic Direct optimization method from Optimization.jl 



"""
SindbadCore.Types.OptimizationMethod

@doc """

# BayesOptKMaternARD5

Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl

## Type Hierarchy

```BayesOptKMaternARD5 <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.BayesOptKMaternARD5

@doc """

# CMAEvolutionStrategyCMAES

Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl

## Type Hierarchy

```CMAEvolutionStrategyCMAES <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CMAEvolutionStrategyCMAES

@doc """

# EvolutionaryCMAES

Evolutionary version of CMA-ES optimization from Evolutionary.jl

## Type Hierarchy

```EvolutionaryCMAES <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.EvolutionaryCMAES

@doc """

# OptimBFGS

Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl

## Type Hierarchy

```OptimBFGS <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimBFGS

@doc """

# OptimLBFGS

Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl

## Type Hierarchy

```OptimLBFGS <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimLBFGS

@doc """

# OptimizationBBOadaptive

Black Box Optimization with adaptive parameters from Optimization.jl

## Type Hierarchy

```OptimizationBBOadaptive <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationBBOadaptive

@doc """

# OptimizationBBOxnes

Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl

## Type Hierarchy

```OptimizationBBOxnes <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationBBOxnes

@doc """

# OptimizationBFGS

BFGS optimization with box constraints from Optimization.jl

## Type Hierarchy

```OptimizationBFGS <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationBFGS

@doc """

# OptimizationFminboxGradientDescent

Gradient descent optimization with box constraints from Optimization.jl

## Type Hierarchy

```OptimizationFminboxGradientDescent <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationFminboxGradientDescent

@doc """

# OptimizationFminboxGradientDescentFD

Gradient descent optimization with box constraints using forward differentiation from Optimization.jl

## Type Hierarchy

```OptimizationFminboxGradientDescentFD <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationFminboxGradientDescentFD

@doc """

# OptimizationGCMAESDef

Global CMA-ES optimization with default settings from Optimization.jl

## Type Hierarchy

```OptimizationGCMAESDef <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationGCMAESDef

@doc """

# OptimizationGCMAESFD

Global CMA-ES optimization using forward differentiation from Optimization.jl

## Type Hierarchy

```OptimizationGCMAESFD <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationGCMAESFD

@doc """

# OptimizationMultistartOptimization

Multi-start optimization to find global optimum from Optimization.jl

## Type Hierarchy

```OptimizationMultistartOptimization <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationMultistartOptimization

@doc """

# OptimizationNelderMead

Nelder-Mead simplex optimization method from Optimization.jl

## Type Hierarchy

```OptimizationNelderMead <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationNelderMead

@doc """

# OptimizationQuadDirect

Quadratic Direct optimization method from Optimization.jl

## Type Hierarchy

```OptimizationQuadDirect <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimizationQuadDirect

@doc """

# ParameterScaling

Abstract type for parameter scaling methods in SINDBAD

## Type Hierarchy

```ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `ScaleBounds`: Scale parameters relative to their bounds 
 -  `ScaleDefault`: Scale parameters relative to default values 
 -  `ScaleNone`: No parameter scaling applied 



"""
SindbadCore.Types.ParameterScaling

@doc """

# ScaleBounds

Scale parameters relative to their bounds

## Type Hierarchy

```ScaleBounds <: ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ScaleBounds

@doc """

# ScaleDefault

Scale parameters relative to default values

## Type Hierarchy

```ScaleDefault <: ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ScaleDefault

@doc """

# ScaleNone

No parameter scaling applied

## Type Hierarchy

```ScaleNone <: ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ScaleNone

@doc """

# SpinupTypes

Abstract type for model spinup related functions and methods in SINDBAD

## Type Hierarchy

```SpinupTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `SpinupMode`: Abstract type for model spinup modes in SINDBAD 
     -  `AllForwardModels`: Use all forward models for spinup 
     -  `EtaScaleA0H`: scale carbon pools using diagnostic scalars for ηH and c_remain 
     -  `EtaScaleA0HCWD`: scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain 
     -  `EtaScaleAH`: scale carbon pools using diagnostic scalars for ηH and ηA 
     -  `EtaScaleAHCWD`: scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA 
     -  `NlsolveFixedpointTrustregionCEco`: use a fixed-point nonlinear solver with trust region for carbon pools (cEco) 
     -  `NlsolveFixedpointTrustregionCEcoTWS`: use a fixed-point nonlinear solver with trust region for both cEco and TWS 
     -  `NlsolveFixedpointTrustregionTWS`: use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS) 
     -  `ODEAutoTsit5Rodas5`: use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs 
     -  `ODEDP5`: use the DP5 method from DifferentialEquations.jl for solving ODEs 
     -  `ODETsit5`: use the Tsit5 method from DifferentialEquations.jl for solving ODEs 
     -  `SSPDynamicSSTsit5`: use the SteadyState solver with DynamicSS and Tsit5 methods 
     -  `SSPSSRootfind`: use the SteadyState solver with SSRootfind method 
     -  `SelSpinupModels`: run only the models selected for spinup in the model structure 
     -  `Spinup_TWS`: Spinup spinup_mode for Total Water Storage (TWS) 
     -  `Spinup_cEco`: Spinup spinup_mode for cEco 
     -  `Spinup_cEco_TWS`: Spinup spinup_mode for cEco and TWS 
 -  `SpinupSequence`: Basic Spinup sequence without time aggregation 
 -  `SpinupSequenceWithAggregator`: Spinup sequence with time aggregation for corresponding forcingtime series 



"""
SindbadCore.Types.SpinupTypes

@doc """

# SpinupMode

Abstract type for model spinup modes in SINDBAD

## Type Hierarchy

```SpinupMode <: SpinupTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `AllForwardModels`: Use all forward models for spinup 
 -  `EtaScaleA0H`: scale carbon pools using diagnostic scalars for ηH and c_remain 
 -  `EtaScaleA0HCWD`: scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain 
 -  `EtaScaleAH`: scale carbon pools using diagnostic scalars for ηH and ηA 
 -  `EtaScaleAHCWD`: scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA 
 -  `NlsolveFixedpointTrustregionCEco`: use a fixed-point nonlinear solver with trust region for carbon pools (cEco) 
 -  `NlsolveFixedpointTrustregionCEcoTWS`: use a fixed-point nonlinear solver with trust region for both cEco and TWS 
 -  `NlsolveFixedpointTrustregionTWS`: use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS) 
 -  `ODEAutoTsit5Rodas5`: use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs 
 -  `ODEDP5`: use the DP5 method from DifferentialEquations.jl for solving ODEs 
 -  `ODETsit5`: use the Tsit5 method from DifferentialEquations.jl for solving ODEs 
 -  `SSPDynamicSSTsit5`: use the SteadyState solver with DynamicSS and Tsit5 methods 
 -  `SSPSSRootfind`: use the SteadyState solver with SSRootfind method 
 -  `SelSpinupModels`: run only the models selected for spinup in the model structure 
 -  `Spinup_TWS`: Spinup spinup_mode for Total Water Storage (TWS) 
 -  `Spinup_cEco`: Spinup spinup_mode for cEco 
 -  `Spinup_cEco_TWS`: Spinup spinup_mode for cEco and TWS 



"""
SindbadCore.Types.SpinupMode

@doc """

# AllForwardModels

Use all forward models for spinup

## Type Hierarchy

```AllForwardModels <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.AllForwardModels

@doc """

# EtaScaleA0H

scale carbon pools using diagnostic scalars for ηH and c_remain

## Type Hierarchy

```EtaScaleA0H <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.EtaScaleA0H

@doc """

# EtaScaleA0HCWD

scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain

## Type Hierarchy

```EtaScaleA0HCWD <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.EtaScaleA0HCWD

@doc """

# EtaScaleAH

scale carbon pools using diagnostic scalars for ηH and ηA

## Type Hierarchy

```EtaScaleAH <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.EtaScaleAH

@doc """

# EtaScaleAHCWD

scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA

## Type Hierarchy

```EtaScaleAHCWD <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.EtaScaleAHCWD

@doc """

# NlsolveFixedpointTrustregionCEco

use a fixed-point nonlinear solver with trust region for carbon pools (cEco)

## Type Hierarchy

```NlsolveFixedpointTrustregionCEco <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NlsolveFixedpointTrustregionCEco

@doc """

# NlsolveFixedpointTrustregionCEcoTWS

use a fixed-point nonlinear solver with trust region for both cEco and TWS

## Type Hierarchy

```NlsolveFixedpointTrustregionCEcoTWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NlsolveFixedpointTrustregionCEcoTWS

@doc """

# NlsolveFixedpointTrustregionTWS

use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS)

## Type Hierarchy

```NlsolveFixedpointTrustregionTWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.NlsolveFixedpointTrustregionTWS

@doc """

# ODEAutoTsit5Rodas5

use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs

## Type Hierarchy

```ODEAutoTsit5Rodas5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ODEAutoTsit5Rodas5

@doc """

# ODEDP5

use the DP5 method from DifferentialEquations.jl for solving ODEs

## Type Hierarchy

```ODEDP5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ODEDP5

@doc """

# ODETsit5

use the Tsit5 method from DifferentialEquations.jl for solving ODEs

## Type Hierarchy

```ODETsit5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.ODETsit5

@doc """

# SSPDynamicSSTsit5

use the SteadyState solver with DynamicSS and Tsit5 methods

## Type Hierarchy

```SSPDynamicSSTsit5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SSPDynamicSSTsit5

@doc """

# SSPSSRootfind

use the SteadyState solver with SSRootfind method

## Type Hierarchy

```SSPSSRootfind <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SSPSSRootfind

@doc """

# SelSpinupModels

run only the models selected for spinup in the model structure

## Type Hierarchy

```SelSpinupModels <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SelSpinupModels

@doc """

# Spinup_TWS

Spinup spinup_mode for Total Water Storage (TWS)

## Type Hierarchy

```Spinup_TWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spinup_TWS

@doc """

# Spinup_cEco

Spinup spinup_mode for cEco

## Type Hierarchy

```Spinup_cEco <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spinup_cEco

@doc """

# Spinup_cEco_TWS

Spinup spinup_mode for cEco and TWS

## Type Hierarchy

```Spinup_cEco_TWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.Spinup_cEco_TWS

@doc """

# SpinupSequence

Basic Spinup sequence without time aggregation

## Type Hierarchy

```SpinupSequence <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SpinupSequence

@doc """

# SpinupSequenceWithAggregator

Spinup sequence with time aggregation for corresponding forcingtime series

## Type Hierarchy

```SpinupSequenceWithAggregator <: SpinupTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.SpinupSequenceWithAggregator

@doc """

# TimeTypes

Abstract type for implementing time subset and aggregation types in SINDBAD

## Type Hierarchy

```TimeTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `TimeAggregation`: Abstract type for time aggregation methods in SINDBAD 
     -  `TimeAllYears`: aggregation/slicing to include all years 
     -  `TimeArray`: use array-based time aggregation 
     -  `TimeDay`: aggregation to daily time steps 
     -  `TimeDayAnomaly`: aggregation to daily anomalies 
     -  `TimeDayIAV`: aggregation to daily IAV 
     -  `TimeDayMSC`: aggregation to daily MSC 
     -  `TimeDayMSCAnomaly`: aggregation to daily MSC anomalies 
     -  `TimeDiff`: aggregation to time differences, e.g. monthly anomalies 
     -  `TimeFirstYear`: aggregation/slicing of the first year 
     -  `TimeHour`: aggregation to hourly time steps 
     -  `TimeHourAnomaly`: aggregation to hourly anomalies 
     -  `TimeHourDayMean`: aggregation to mean of hourly data over days 
     -  `TimeIndexed`: aggregation using time indices, e.g., TimeFirstYear 
     -  `TimeMean`: aggregation to mean over all time steps 
     -  `TimeMonth`: aggregation to monthly time steps 
     -  `TimeMonthAnomaly`: aggregation to monthly anomalies 
     -  `TimeMonthIAV`: aggregation to monthly IAV 
     -  `TimeMonthMSC`: aggregation to monthly MSC 
     -  `TimeMonthMSCAnomaly`: aggregation to monthly MSC anomalies 
     -  `TimeNoDiff`: aggregation without time differences 
     -  `TimeRandomYear`: aggregation/slicing of a random year 
     -  `TimeShuffleYears`: aggregation/slicing/selection of shuffled years 
     -  `TimeSizedArray`: aggregation to a sized array 
     -  `TimeYear`: aggregation to yearly time steps 
     -  `TimeYearAnomaly`: aggregation to yearly anomalies 
 -  `TimeAggregator`: define a type for temporal aggregation of an array 



"""
SindbadCore.Types.TimeTypes

@doc """

# TimeAggregation

Abstract type for time aggregation methods in SINDBAD

## Type Hierarchy

```TimeAggregation <: TimeTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `TimeAllYears`: aggregation/slicing to include all years 
 -  `TimeArray`: use array-based time aggregation 
 -  `TimeDay`: aggregation to daily time steps 
 -  `TimeDayAnomaly`: aggregation to daily anomalies 
 -  `TimeDayIAV`: aggregation to daily IAV 
 -  `TimeDayMSC`: aggregation to daily MSC 
 -  `TimeDayMSCAnomaly`: aggregation to daily MSC anomalies 
 -  `TimeDiff`: aggregation to time differences, e.g. monthly anomalies 
 -  `TimeFirstYear`: aggregation/slicing of the first year 
 -  `TimeHour`: aggregation to hourly time steps 
 -  `TimeHourAnomaly`: aggregation to hourly anomalies 
 -  `TimeHourDayMean`: aggregation to mean of hourly data over days 
 -  `TimeIndexed`: aggregation using time indices, e.g., TimeFirstYear 
 -  `TimeMean`: aggregation to mean over all time steps 
 -  `TimeMonth`: aggregation to monthly time steps 
 -  `TimeMonthAnomaly`: aggregation to monthly anomalies 
 -  `TimeMonthIAV`: aggregation to monthly IAV 
 -  `TimeMonthMSC`: aggregation to monthly MSC 
 -  `TimeMonthMSCAnomaly`: aggregation to monthly MSC anomalies 
 -  `TimeNoDiff`: aggregation without time differences 
 -  `TimeRandomYear`: aggregation/slicing of a random year 
 -  `TimeShuffleYears`: aggregation/slicing/selection of shuffled years 
 -  `TimeSizedArray`: aggregation to a sized array 
 -  `TimeYear`: aggregation to yearly time steps 
 -  `TimeYearAnomaly`: aggregation to yearly anomalies 



"""
SindbadCore.Types.TimeAggregation

@doc """

# TimeAllYears

aggregation/slicing to include all years

## Type Hierarchy

```TimeAllYears <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeAllYears

@doc """

# TimeArray

use array-based time aggregation

## Type Hierarchy

```TimeArray <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeArray

@doc """

# TimeDay

aggregation to daily time steps

## Type Hierarchy

```TimeDay <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeDay

@doc """

# TimeDayAnomaly

aggregation to daily anomalies

## Type Hierarchy

```TimeDayAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeDayAnomaly

@doc """

# TimeDayIAV

aggregation to daily IAV

## Type Hierarchy

```TimeDayIAV <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeDayIAV

@doc """

# TimeDayMSC

aggregation to daily MSC

## Type Hierarchy

```TimeDayMSC <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeDayMSC

@doc """

# TimeDayMSCAnomaly

aggregation to daily MSC anomalies

## Type Hierarchy

```TimeDayMSCAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeDayMSCAnomaly

@doc """

# TimeDiff

aggregation to time differences, e.g. monthly anomalies

## Type Hierarchy

```TimeDiff <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeDiff

@doc """

# TimeFirstYear

aggregation/slicing of the first year

## Type Hierarchy

```TimeFirstYear <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeFirstYear

@doc """

# TimeHour

aggregation to hourly time steps

## Type Hierarchy

```TimeHour <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeHour

@doc """

# TimeHourAnomaly

aggregation to hourly anomalies

## Type Hierarchy

```TimeHourAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeHourAnomaly

@doc """

# TimeHourDayMean

aggregation to mean of hourly data over days

## Type Hierarchy

```TimeHourDayMean <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeHourDayMean

@doc """

# TimeIndexed

aggregation using time indices, e.g., TimeFirstYear

## Type Hierarchy

```TimeIndexed <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeIndexed

@doc """

# TimeMean

aggregation to mean over all time steps

## Type Hierarchy

```TimeMean <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeMean

@doc """

# TimeMonth

aggregation to monthly time steps

## Type Hierarchy

```TimeMonth <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeMonth

@doc """

# TimeMonthAnomaly

aggregation to monthly anomalies

## Type Hierarchy

```TimeMonthAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeMonthAnomaly

@doc """

# TimeMonthIAV

aggregation to monthly IAV

## Type Hierarchy

```TimeMonthIAV <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeMonthIAV

@doc """

# TimeMonthMSC

aggregation to monthly MSC

## Type Hierarchy

```TimeMonthMSC <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeMonthMSC

@doc """

# TimeMonthMSCAnomaly

aggregation to monthly MSC anomalies

## Type Hierarchy

```TimeMonthMSCAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeMonthMSCAnomaly

@doc """

# TimeNoDiff

aggregation without time differences

## Type Hierarchy

```TimeNoDiff <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeNoDiff

@doc """

# TimeRandomYear

aggregation/slicing of a random year

## Type Hierarchy

```TimeRandomYear <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeRandomYear

@doc """

# TimeShuffleYears

aggregation/slicing/selection of shuffled years

## Type Hierarchy

```TimeShuffleYears <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeShuffleYears

@doc """

# TimeSizedArray

aggregation to a sized array

## Type Hierarchy

```TimeSizedArray <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeSizedArray

@doc """

# TimeYear

aggregation to yearly time steps

## Type Hierarchy

```TimeYear <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeYear

@doc """

# TimeYearAnomaly

aggregation to yearly anomalies

## Type Hierarchy

```TimeYearAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.TimeYearAnomaly

@doc """

# MLModelType

Abstract type for machine learning models used in SINDBAD

## Type Hierarchy

```MLModelType <: MLTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `FluxDenseNN`: simple dense neural network model implemented in Flux.jl 



"""
SindbadCore.Types.MLModelType

@doc """

# FluxDenseNN

simple dense neural network model implemented in Flux.jl

## Type Hierarchy

```FluxDenseNN <: MLModelType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.FluxDenseNN

@doc """

# MLOptimizerType

Abstract type for optimizers used for training ML models in SINDBAD

## Type Hierarchy

```MLOptimizerType <: MLTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `OptimisersAdam`: Use Optimisers.jl Adam optimizer for training ML models in SINDBAD 



"""
SindbadCore.Types.MLOptimizerType

@doc """

# OptimisersAdam

Use Optimisers.jl Adam optimizer for training ML models in SINDBAD

## Type Hierarchy

```OptimisersAdam <: MLOptimizerType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimisersAdam

@doc """

# MLTrainingType

Abstract type for training a hybrid algorithm in SINDBAD

## Type Hierarchy

```MLTrainingType <: MLTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `MixedGradient`: Use a mixed gradient approach for training using gradient from multiple methods and combining them with pullback from zygote 



"""
SindbadCore.Types.MLTrainingType

@doc """

# MixedGradient

Use a mixed gradient approach for training using gradient from multiple methods and combining them with pullback from zygote

## Type Hierarchy

```MixedGradient <: MLTrainingType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.MixedGradient

@doc """

# CalcFoldFromSplit

Use a split of the data to calculate the folds for cross-validation. The default wat to calculate the folds is by splitting the data into k-folds. In this case, the split is done on the go based on the values given in ml_training.split_ratios and n_folds.

## Type Hierarchy

```CalcFoldFromSplit <: MLTrainingType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CalcFoldFromSplit

@doc """

# LoadFoldFromFile

Use precalculated data to load the folds for cross-validation. In this case, the data path has to be set under ml_training.fold_path and ml_training.which_fold. The data has to be in the format of a jld2 file with the following structure: /folds/0, /folds/1, /folds/2, ... /folds/n_folds. Each fold has to be a tuple of the form (train_indices, test_indices).

## Type Hierarchy

```LoadFoldFromFile <: MLTrainingType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.LoadFoldFromFile

@doc """

# ActivationType

Abstract type for activation functions used in ML models

## Type Hierarchy

```ActivationType <: MLTypes <: SindbadTypes <: Any```

-----

# Extended help

## Available methods/subtypes:

 -  `FluxRelu`: Use Flux.jl ReLU activation function 
 -  `FluxSigmoid`: Use Flux.jl Sigmoid activation function 
 -  `FluxTanh`: Use Flux.jl Tanh activation function 



"""
SindbadCore.Types.ActivationType

@doc """

# FluxRelu

Use Flux.jl ReLU activation function

## Type Hierarchy

```FluxRelu <: ActivationType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.FluxRelu

@doc """

# FluxSigmoid

Use Flux.jl Sigmoid activation function

## Type Hierarchy

```FluxSigmoid <: ActivationType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.FluxSigmoid

@doc """

# FluxTanh

Use Flux.jl Tanh activation function

## Type Hierarchy

```FluxTanh <: ActivationType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.FluxTanh

@doc """

# LossModelObsML

Loss function using metrics between the predicted model and observation as defined in optimization.json

## Type Hierarchy

```LossModelObsML <: MLTrainingType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.LossModelObsML

@doc """

# CustomSigmoid

Use a custom sigmoid activation function. In this case, the `k_σ` parameter in ml_model sections of the settings is used to control the steepness of the sigmoid function.

## Type Hierarchy

```CustomSigmoid <: ActivationType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.CustomSigmoid

@doc """

# OptimisersDescent

Use Optimisers.jl Descent optimizer for training ML models in SINDBAD

## Type Hierarchy

```OptimisersDescent <: MLOptimizerType <: MLTypes <: SindbadTypes <: Any```


"""
SindbadCore.Types.OptimisersDescent

