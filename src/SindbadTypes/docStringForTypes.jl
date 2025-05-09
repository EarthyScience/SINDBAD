@doc """

# ArrayType

Abstract type for all array types in SINDBAD

## Type Hierarchy

```ArrayType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.ArrayType

@doc """

# ModelArrayType

Abstract type for internal model array types in SINDBAD

## Type Hierarchy

```ModelArrayType <: ArrayType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `ModelArrayArray`: Use standard Julia arrays for model variables 
 -  `ModelArrayStaticArray`: Use StaticArrays for model variables 
 -  `ModelArrayView`: Use array views for model variables 



"""
Sindbad.SindbadTypes.ModelArrayType

@doc """

# ModelArrayArray

Use standard Julia arrays for model variables

## Type Hierarchy

```ModelArrayArray <: ModelArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ModelArrayArray

@doc """

# ModelArrayStaticArray

Use StaticArrays for model variables

## Type Hierarchy

```ModelArrayStaticArray <: ModelArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ModelArrayStaticArray

@doc """

# ModelArrayView

Use array views for model variables

## Type Hierarchy

```ModelArrayView <: ModelArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ModelArrayView

@doc """

# OutputArrayType

Abstract type for output array types in SINDBAD

## Type Hierarchy

```OutputArrayType <: ArrayType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `OutputArray`: Use standard Julia arrays for output 
 -  `OutputMArray`: Use MArray for output 
 -  `OutputSizedArray`: Use SizedArray for output 
 -  `OutputYAXArray`: Use YAXArray for output 



"""
Sindbad.SindbadTypes.OutputArrayType

@doc """

# OutputArray

Use standard Julia arrays for output

## Type Hierarchy

```OutputArray <: OutputArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OutputArray

@doc """

# OutputMArray

Use MArray for output

## Type Hierarchy

```OutputMArray <: OutputArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OutputMArray

@doc """

# OutputSizedArray

Use SizedArray for output

## Type Hierarchy

```OutputSizedArray <: OutputArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OutputSizedArray

@doc """

# OutputYAXArray

Use YAXArray for output

## Type Hierarchy

```OutputYAXArray <: OutputArrayType <: ArrayType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OutputYAXArray

@doc """

# ExperimentType

Abstract type for model run flags and experimental setup and simulations in SINDBAD

## Type Hierarchy

```ExperimentType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.ExperimentType

@doc """

# OutputStrategy

Abstract type for model output strategies in SINDBAD

## Type Hierarchy

```OutputStrategy <: ExperimentType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `DoNotOutputAll`: Disable output of all model variables 
 -  `DoNotSaveSingleFile`: Save output variables in separate files 
 -  `DoOutputAll`: Enable output of all model variables 
 -  `DoSaveSingleFile`: Save all output variables in a single file 



"""
Sindbad.SindbadTypes.OutputStrategy

@doc """

# DoNotOutputAll

Disable output of all model variables

## Type Hierarchy

```DoNotOutputAll <: OutputStrategy <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotOutputAll

@doc """

# DoNotSaveSingleFile

Save output variables in separate files

## Type Hierarchy

```DoNotSaveSingleFile <: OutputStrategy <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotSaveSingleFile

@doc """

# DoOutputAll

Enable output of all model variables

## Type Hierarchy

```DoOutputAll <: OutputStrategy <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoOutputAll

@doc """

# DoSaveSingleFile

Save all output variables in a single file

## Type Hierarchy

```DoSaveSingleFile <: OutputStrategy <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoSaveSingleFile

@doc """

# ParallelizationPackage

Abstract type for using different parallelization packages in SINDBAD

## Type Hierarchy

```ParallelizationPackage <: ExperimentType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `QbmapParallelization`: Use Qbmap for parallelization 
 -  `ThreadsParallelization`: Use Julia threads for parallelization 



"""
Sindbad.SindbadTypes.ParallelizationPackage

@doc """

# QbmapParallelization

Use Qbmap for parallelization

## Type Hierarchy

```QbmapParallelization <: ParallelizationPackage <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.QbmapParallelization

@doc """

# ThreadsParallelization

Use Julia threads for parallelization

## Type Hierarchy

```ThreadsParallelization <: ParallelizationPackage <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ThreadsParallelization

@doc """

# RunFlag

Abstract type for model run configuration flags in SINDBAD

## Type Hierarchy

```RunFlag <: ExperimentType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.RunFlag

@doc """

# DoCalcCost

Enable cost calculation between model output and observations

## Type Hierarchy

```DoCalcCost <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoCalcCost

@doc """

# DoDebugModel

Enable model debugging mode

## Type Hierarchy

```DoDebugModel <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoDebugModel

@doc """

# DoFilterNanPixels

Enable filtering of NaN values in spatial data

## Type Hierarchy

```DoFilterNanPixels <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoFilterNanPixels

@doc """

# DoInlineUpdate

Enable inline updates of model state

## Type Hierarchy

```DoInlineUpdate <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoInlineUpdate

@doc """

# DoNotCalcCost

Disable cost calculation between model output and observations

## Type Hierarchy

```DoNotCalcCost <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotCalcCost

@doc """

# DoNotDebugModel

Disable model debugging mode

## Type Hierarchy

```DoNotDebugModel <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotDebugModel

@doc """

# DoNotFilterNanPixels

Disable filtering of NaN values in spatial data

## Type Hierarchy

```DoNotFilterNanPixels <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotFilterNanPixels

@doc """

# DoNotInlineUpdate

Disable inline updates of model state

## Type Hierarchy

```DoNotInlineUpdate <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotInlineUpdate

@doc """

# DoNotRunForward

Disable forward model run

## Type Hierarchy

```DoNotRunForward <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotRunForward

@doc """

# DoNotRunOptimization

Disable model parameter optimization

## Type Hierarchy

```DoNotRunOptimization <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotRunOptimization

@doc """

# DoNotSaveInfo

Disable saving of model information

## Type Hierarchy

```DoNotSaveInfo <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotSaveInfo

@doc """

# DoNotSpinupTEM

Disable terrestrial ecosystem model spinup

## Type Hierarchy

```DoNotSpinupTEM <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotSpinupTEM

@doc """

# DoNotStoreSpinup

Disable storing of spinup results

## Type Hierarchy

```DoNotStoreSpinup <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotStoreSpinup

@doc """

# DoNotUseForwardDiff

Disable forward mode automatic differentiation

## Type Hierarchy

```DoNotUseForwardDiff <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotUseForwardDiff

@doc """

# DoRunForward

Enable forward model run

## Type Hierarchy

```DoRunForward <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoRunForward

@doc """

# DoRunOptimization

Enable model parameter optimization

## Type Hierarchy

```DoRunOptimization <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoRunOptimization

@doc """

# DoSaveInfo

Enable saving of model information

## Type Hierarchy

```DoSaveInfo <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoSaveInfo

@doc """

# DoSpinupTEM

Enable terrestrial ecosystem model spinup

## Type Hierarchy

```DoSpinupTEM <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoSpinupTEM

@doc """

# DoStoreSpinup

Enable storing of spinup results

## Type Hierarchy

```DoStoreSpinup <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoStoreSpinup

@doc """

# DoUseForwardDiff

Enable forward mode automatic differentiation

## Type Hierarchy

```DoUseForwardDiff <: RunFlag <: ExperimentType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoUseForwardDiff

@doc """

# InputType

Abstract type for input data and processing related options in SINDBAD

## Type Hierarchy

```InputType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.InputType

@doc """

# DataFormatBackend

Abstract type for input data backends in SINDBAD

## Type Hierarchy

```DataFormatBackend <: InputType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `BackendNetcdf`: Use NetCDF format for input data 
 -  `BackendZarr`: Use Zarr format for input data 



"""
Sindbad.SindbadTypes.DataFormatBackend

@doc """

# BackendNetcdf

Use NetCDF format for input data

## Type Hierarchy

```BackendNetcdf <: DataFormatBackend <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.BackendNetcdf

@doc """

# BackendZarr

Use Zarr format for input data

## Type Hierarchy

```BackendZarr <: DataFormatBackend <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.BackendZarr

@doc """

# ForcingWithTime

Forcing variable with time dimension

## Type Hierarchy

```ForcingWithTime <: ForcingTime <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ForcingWithTime

@doc """

# ForcingWithoutTime

Forcing variable without time dimension

## Type Hierarchy

```ForcingWithoutTime <: ForcingTime <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ForcingWithoutTime

@doc """

# InputArrayBackend

Abstract type for input data array types in SINDBAD

## Type Hierarchy

```InputArrayBackend <: InputType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `InputArray`: Use standard Julia arrays for input data 
 -  `InputKeyedArray`: Use keyed arrays for input data 
 -  `InputNamedDimsArray`: Use named dimension arrays for input data 
 -  `InputYaxArray`: Use YAXArray for input data 



"""
Sindbad.SindbadTypes.InputArrayBackend

@doc """

# InputArray

Use standard Julia arrays for input data

## Type Hierarchy

```InputArray <: InputArrayBackend <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.InputArray

@doc """

# InputKeyedArray

Use keyed arrays for input data

## Type Hierarchy

```InputKeyedArray <: InputArrayBackend <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.InputKeyedArray

@doc """

# InputNamedDimsArray

Use named dimension arrays for input data

## Type Hierarchy

```InputNamedDimsArray <: InputArrayBackend <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.InputNamedDimsArray

@doc """

# InputYaxArray

Use YAXArray for input data

## Type Hierarchy

```InputYaxArray <: InputArrayBackend <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.InputYaxArray

@doc """

# SpatialSubsetter

Abstract type for spatial subsetting methods in SINDBAD

## Type Hierarchy

```SpatialSubsetter <: InputType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.SpatialSubsetter

@doc """

# SpaceID

Use site ID (all caps) for spatial subsetting

## Type Hierarchy

```SpaceID <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SpaceID

@doc """

# SpaceId

Use site ID (capitalized) for spatial subsetting

## Type Hierarchy

```SpaceId <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SpaceId

@doc """

# Spaceid

Use site ID for spatial subsetting

## Type Hierarchy

```Spaceid <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spaceid

@doc """

# Spacelat

Use latitude for spatial subsetting

## Type Hierarchy

```Spacelat <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spacelat

@doc """

# Spacelatitude

Use full latitude for spatial subsetting

## Type Hierarchy

```Spacelatitude <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spacelatitude

@doc """

# Spacelon

Use longitude for spatial subsetting

## Type Hierarchy

```Spacelon <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spacelon

@doc """

# Spacelongitude

Use full longitude for spatial subsetting

## Type Hierarchy

```Spacelongitude <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spacelongitude

@doc """

# Spacesite

Use site location for spatial subsetting

## Type Hierarchy

```Spacesite <: SpatialSubsetter <: InputType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spacesite

@doc """

# LandType

Abstract type for land related types that are typically used in preparing objects for model runs in SINDBAD

## Type Hierarchy

```LandType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.LandType

@doc """

# PreAlloc

Abstract type for preallocated land helpers types in prepTEM of SINDBAD

## Type Hierarchy

```PreAlloc <: LandType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `PreAllocArray`: use a preallocated array for model output 
 -  `PreAllocArrayAll`: use a preallocated array to output all land variables 
 -  `PreAllocArrayFD`: use a preallocated array for finite difference (FD) hybrid experiments 
 -  `PreAllocArrayMT`: use arrays of nThreads size for land model output for replicates of multiple threads 
 -  `PreAllocStacked`: save output as a stacked vector of land using map over temporal dimension 
 -  `PreAllocTimeseries`: save land output as a preallocated vector for time series of land 
 -  `PreAllocYAXArray`: use YAX arrays for model output 



"""
Sindbad.SindbadTypes.PreAlloc

@doc """

# PreAllocArray

use a preallocated array for model output

## Type Hierarchy

```PreAllocArray <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocArray

@doc """

# PreAllocArrayAll

use a preallocated array to output all land variables

## Type Hierarchy

```PreAllocArrayAll <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocArrayAll

@doc """

# PreAllocArrayFD

use a preallocated array for finite difference (FD) hybrid experiments

## Type Hierarchy

```PreAllocArrayFD <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocArrayFD

@doc """

# PreAllocArrayMT

use arrays of nThreads size for land model output for replicates of multiple threads

## Type Hierarchy

```PreAllocArrayMT <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocArrayMT

@doc """

# PreAllocStacked

save output as a stacked vector of land using map over temporal dimension

## Type Hierarchy

```PreAllocStacked <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocStacked

@doc """

# PreAllocTimeseries

save land output as a preallocated vector for time series of land

## Type Hierarchy

```PreAllocTimeseries <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocTimeseries

@doc """

# PreAllocYAXArray

use YAX arrays for model output

## Type Hierarchy

```PreAllocYAXArray <: PreAlloc <: LandType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PreAllocYAXArray

@doc """

# MLType

Abstract type for types in machine learning related methods in SINDBAD

## Type Hierarchy

```MLType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `GradType`: Abstract type for automatic differentiation or finite differences for gradient calculations 
     -  `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
     -  `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
     -  `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
     -  `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
     -  `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
     -  `ZygoteGrad`: Use Zygote.jl for automatic differentiation 



"""
Sindbad.SindbadTypes.MLType

@doc """

# GradType

Abstract type for automatic differentiation or finite differences for gradient calculations

## Type Hierarchy

```GradType <: MLType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
 -  `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
 -  `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
 -  `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
 -  `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
 -  `ZygoteGrad`: Use Zygote.jl for automatic differentiation 



"""
Sindbad.SindbadTypes.GradType

@doc """

# EnzymeGrad

Use Enzyme.jl for automatic differentiation

## Type Hierarchy

```EnzymeGrad <: GradType <: MLType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.EnzymeGrad

@doc """

# FiniteDiffGrad

Use FiniteDiff.jl for finite difference calculations

## Type Hierarchy

```FiniteDiffGrad <: GradType <: MLType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.FiniteDiffGrad

@doc """

# FiniteDifferencesGrad

Use FiniteDifferences.jl for finite difference calculations

## Type Hierarchy

```FiniteDifferencesGrad <: GradType <: MLType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.FiniteDifferencesGrad

@doc """

# ForwardDiffGrad

Use ForwardDiff.jl for automatic differentiation

## Type Hierarchy

```ForwardDiffGrad <: GradType <: MLType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ForwardDiffGrad

@doc """

# PolyesterForwardDiffGrad

Use PolyesterForwardDiff.jl for automatic differentiation

## Type Hierarchy

```PolyesterForwardDiffGrad <: GradType <: MLType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PolyesterForwardDiffGrad

@doc """

# ZygoteGrad

Use Zygote.jl for automatic differentiation

## Type Hierarchy

```ZygoteGrad <: GradType <: MLType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ZygoteGrad

@doc """

# MetricsType

Abstract type for performance metrics and cost calculation methods in SINDBAD

## Type Hierarchy

```MetricsType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.MetricsType

@doc """

# DataAggrOrder

Abstract type for data aggregation order in SINDBAD

## Type Hierarchy

```DataAggrOrder <: MetricsType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `SpaceTime`: Aggregate data first over space, then over time 
 -  `TimeSpace`: Aggregate data first over time, then over space 



"""
Sindbad.SindbadTypes.DataAggrOrder

@doc """

# SpaceTime

Aggregate data first over space, then over time

## Type Hierarchy

```SpaceTime <: DataAggrOrder <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SpaceTime

@doc """

# TimeSpace

Aggregate data first over time, then over space

## Type Hierarchy

```TimeSpace <: DataAggrOrder <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeSpace

@doc """

# PerfMetric

Abstract type for performance metrics in SINDBAD

## Type Hierarchy

```PerfMetric <: MetricsType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.PerfMetric

@doc """

# MSE

Mean Squared Error: Measures the average squared difference between predicted and observed values

## Type Hierarchy

```MSE <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.MSE

@doc """

# NAME1R

Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations

## Type Hierarchy

```NAME1R <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NAME1R

@doc """

# NMAE1R

Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations

## Type Hierarchy

```NMAE1R <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NMAE1R

@doc """

# NNSE

Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range

## Type Hierarchy

```NNSE <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NNSE

@doc """

# NNSEInv

Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range

## Type Hierarchy

```NNSEInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NNSEInv

@doc """

# NNSEσ

Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure

## Type Hierarchy

```NNSEσ <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NNSEσ

@doc """

# NNSEσInv

Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems

## Type Hierarchy

```NNSEσInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NNSEσInv

@doc """

# NPcor

Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range

## Type Hierarchy

```NPcor <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NPcor

@doc """

# NPcorInv

Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems

## Type Hierarchy

```NPcorInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NPcorInv

@doc """

# NSE

Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations

## Type Hierarchy

```NSE <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NSE

@doc """

# NSEInv

Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems

## Type Hierarchy

```NSEInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NSEInv

@doc """

# NSEσ

Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure

## Type Hierarchy

```NSEσ <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NSEσ

@doc """

# NSEσInv

Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems

## Type Hierarchy

```NSEσInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NSEσInv

@doc """

# NScor

Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range

## Type Hierarchy

```NScor <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NScor

@doc """

# NScorInv

Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems

## Type Hierarchy

```NScorInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NScorInv

@doc """

# Pcor

Pearson Correlation: Measures linear correlation between predictions and observations

## Type Hierarchy

```Pcor <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Pcor

@doc """

# Pcor2

Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations

## Type Hierarchy

```Pcor2 <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Pcor2

@doc """

# Pcor2Inv

Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems

## Type Hierarchy

```Pcor2Inv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Pcor2Inv

@doc """

# PcorInv

Inverse Pearson Correlation: Inverse of Pcor for minimization problems

## Type Hierarchy

```PcorInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.PcorInv

@doc """

# Scor

Spearman Correlation: Measures monotonic relationship between predictions and observations

## Type Hierarchy

```Scor <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Scor

@doc """

# Scor2

Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations

## Type Hierarchy

```Scor2 <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Scor2

@doc """

# Scor2Inv

Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems

## Type Hierarchy

```Scor2Inv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Scor2Inv

@doc """

# ScorInv

Inverse Spearman Correlation: Inverse of Scor for minimization problems

## Type Hierarchy

```ScorInv <: PerfMetric <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ScorInv

@doc """

# SpatialDataAggr

Abstract type for spatial data aggregation methods in SINDBAD

## Type Hierarchy

```SpatialDataAggr <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SpatialDataAggr

@doc """

# SpatialMetricAggr

Abstract type for spatial metric aggregation methods in SINDBAD

## Type Hierarchy

```SpatialMetricAggr <: MetricsType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `MetricMaximum`: Take maximum value across spatial dimensions 
 -  `MetricMinimum`: Take minimum value across spatial dimensions 
 -  `MetricSpatial`: Apply spatial aggregation to metrics 
 -  `MetricSum`: Sum values across spatial dimensions 



"""
Sindbad.SindbadTypes.SpatialMetricAggr

@doc """

# MetricMaximum

Take maximum value across spatial dimensions

## Type Hierarchy

```MetricMaximum <: SpatialMetricAggr <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.MetricMaximum

@doc """

# MetricMinimum

Take minimum value across spatial dimensions

## Type Hierarchy

```MetricMinimum <: SpatialMetricAggr <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.MetricMinimum

@doc """

# MetricSpatial

Apply spatial aggregation to metrics

## Type Hierarchy

```MetricSpatial <: SpatialMetricAggr <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.MetricSpatial

@doc """

# MetricSum

Sum values across spatial dimensions

## Type Hierarchy

```MetricSum <: SpatialMetricAggr <: MetricsType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.MetricSum

@doc """

# ModelType

Abstract type for model types in SINDBAD

## Type Hierarchy

```ModelType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `DoCatchModelErrors`: Enable error catching during model execution 
 -  `DoNotCatchModelErrors`: Disable error catching during model execution 
 -  `LandEcosystem`: Abstract type for all SINDBAD land ecosystem models/approaches 
     -  `EVI`: nothing 
         -  `EVI_constant`: nothing 
         -  `EVI_forcing`: nothing 
     -  `LAI`: nothing 
         -  `LAI_cVegLeaf`: nothing 
         -  `LAI_constant`: nothing 
         -  `LAI_forcing`: nothing 
     -  `NDVI`: nothing 
         -  `NDVI_constant`: nothing 
         -  `NDVI_forcing`: nothing 
     -  `NDWI`: nothing 
         -  `NDWI_constant`: nothing 
         -  `NDWI_forcing`: nothing 
     -  `NIRv`: nothing 
         -  `NIRv_constant`: nothing 
         -  `NIRv_forcing`: nothing 
     -  `PET`: nothing 
         -  `PET_Lu2005`: nothing 
         -  `PET_PriestleyTaylor1972`: nothing 
         -  `PET_forcing`: nothing 
     -  `PFT`: nothing 
         -  `PFT_constant`: nothing 
     -  `WUE`: nothing 
         -  `WUE_Medlyn2011`: nothing 
         -  `WUE_VPDDay`: nothing 
         -  `WUE_VPDDayCo2`: nothing 
         -  `WUE_constant`: nothing 
         -  `WUE_expVPDDayCo2`: nothing 
     -  `ambientCO2`: nothing 
         -  `ambientCO2_constant`: nothing 
         -  `ambientCO2_forcing`: nothing 
     -  `autoRespiration`: nothing 
         -  `autoRespiration_Thornley2000A`: nothing 
         -  `autoRespiration_Thornley2000B`: nothing 
         -  `autoRespiration_Thornley2000C`: nothing 
         -  `autoRespiration_none`: nothing 
     -  `autoRespirationAirT`: nothing 
         -  `autoRespirationAirT_Q10`: nothing 
         -  `autoRespirationAirT_none`: nothing 
     -  `cAllocation`: nothing 
         -  `cAllocation_Friedlingstein1999`: nothing 
         -  `cAllocation_GSI`: nothing 
         -  `cAllocation_fixed`: nothing 
         -  `cAllocation_none`: nothing 
     -  `cAllocationLAI`: nothing 
         -  `cAllocationLAI_Friedlingstein1999`: nothing 
         -  `cAllocationLAI_none`: nothing 
     -  `cAllocationNutrients`: nothing 
         -  `cAllocationNutrients_Friedlingstein1999`: nothing 
         -  `cAllocationNutrients_none`: nothing 
     -  `cAllocationRadiation`: nothing 
         -  `cAllocationRadiation_GSI`: nothing 
         -  `cAllocationRadiation_RgPot`: nothing 
         -  `cAllocationRadiation_gpp`: nothing 
         -  `cAllocationRadiation_none`: nothing 
     -  `cAllocationSoilT`: nothing 
         -  `cAllocationSoilT_Friedlingstein1999`: nothing 
         -  `cAllocationSoilT_gpp`: nothing 
         -  `cAllocationSoilT_gppGSI`: nothing 
         -  `cAllocationSoilT_none`: nothing 
     -  `cAllocationSoilW`: nothing 
         -  `cAllocationSoilW_Friedlingstein1999`: nothing 
         -  `cAllocationSoilW_gpp`: nothing 
         -  `cAllocationSoilW_gppGSI`: nothing 
         -  `cAllocationSoilW_none`: nothing 
     -  `cAllocationTreeFraction`: nothing 
         -  `cAllocationTreeFraction_Friedlingstein1999`: nothing 
     -  `cBiomass`: nothing 
         -  `cBiomass_simple`: nothing 
         -  `cBiomass_treeGrass`: nothing 
         -  `cBiomass_treeGrass_cVegReserveScaling`: nothing 
     -  `cCycle`: nothing 
         -  `cCycle_CASA`: nothing 
         -  `cCycle_GSI`: nothing 
         -  `cCycle_simple`: nothing 
     -  `cCycleBase`: nothing 
         -  `cCycleBase_CASA`: nothing 
         -  `cCycleBase_GSI`: nothing 
         -  `cCycleBase_GSI_PlantForm`: nothing 
         -  `cCycleBase_simple`: nothing 
     -  `cCycleConsistency`: nothing 
         -  `cCycleConsistency_simple`: nothing 
     -  `cCycleDisturbance`: nothing 
         -  `cCycleDisturbance_WROASTED`: nothing 
         -  `cCycleDisturbance_cFlow`: nothing 
     -  `cFlow`: nothing 
         -  `cFlow_CASA`: nothing 
         -  `cFlow_GSI`: nothing 
         -  `cFlow_none`: nothing 
         -  `cFlow_simple`: nothing 
     -  `cFlowSoilProperties`: nothing 
         -  `cFlowSoilProperties_CASA`: nothing 
         -  `cFlowSoilProperties_none`: nothing 
     -  `cFlowVegProperties`: nothing 
         -  `cFlowVegProperties_CASA`: nothing 
         -  `cFlowVegProperties_none`: nothing 
     -  `cTau`: nothing 
         -  `cTau_mult`: nothing 
         -  `cTau_none`: nothing 
     -  `cTauLAI`: nothing 
         -  `cTauLAI_CASA`: nothing 
         -  `cTauLAI_none`: nothing 
     -  `cTauSoilProperties`: nothing 
         -  `cTauSoilProperties_CASA`: nothing 
         -  `cTauSoilProperties_none`: nothing 
     -  `cTauSoilT`: nothing 
         -  `cTauSoilT_Q10`: nothing 
         -  `cTauSoilT_none`: nothing 
     -  `cTauSoilW`: nothing 
         -  `cTauSoilW_CASA`: nothing 
         -  `cTauSoilW_GSI`: nothing 
         -  `cTauSoilW_none`: nothing 
     -  `cTauVegProperties`: nothing 
         -  `cTauVegProperties_CASA`: nothing 
         -  `cTauVegProperties_none`: nothing 
     -  `cVegetationDieOff`: nothing 
         -  `cVegetationDieOff_forcing`: nothing 
     -  `capillaryFlow`: nothing 
         -  `capillaryFlow_VanDijk2010`: nothing 
     -  `deriveVariables`: nothing 
         -  `deriveVariables_simple`: nothing 
     -  `drainage`: nothing 
         -  `drainage_dos`: nothing 
         -  `drainage_kUnsat`: nothing 
         -  `drainage_wFC`: nothing 
     -  `evaporation`: nothing 
         -  `evaporation_Snyder2000`: nothing 
         -  `evaporation_bareFraction`: nothing 
         -  `evaporation_demandSupply`: nothing 
         -  `evaporation_fAPAR`: nothing 
         -  `evaporation_none`: nothing 
         -  `evaporation_vegFraction`: nothing 
     -  `evapotranspiration`: nothing 
         -  `evapotranspiration_sum`: nothing 
     -  `fAPAR`: nothing 
         -  `fAPAR_EVI`: nothing 
         -  `fAPAR_LAI`: nothing 
         -  `fAPAR_cVegLeaf`: nothing 
         -  `fAPAR_cVegLeafBareFrac`: nothing 
         -  `fAPAR_constant`: nothing 
         -  `fAPAR_forcing`: nothing 
         -  `fAPAR_vegFraction`: nothing 
     -  `getPools`: nothing 
         -  `getPools_simple`: nothing 
     -  `gpp`: nothing 
         -  `gpp_coupled`: nothing 
         -  `gpp_min`: nothing 
         -  `gpp_mult`: nothing 
         -  `gpp_none`: nothing 
         -  `gpp_transpirationWUE`: nothing 
     -  `gppAirT`: nothing 
         -  `gppAirT_CASA`: nothing 
         -  `gppAirT_GSI`: nothing 
         -  `gppAirT_MOD17`: nothing 
         -  `gppAirT_Maekelae2008`: nothing 
         -  `gppAirT_TEM`: nothing 
         -  `gppAirT_Wang2014`: nothing 
         -  `gppAirT_none`: nothing 
     -  `gppDemand`: nothing 
         -  `gppDemand_min`: nothing 
         -  `gppDemand_mult`: nothing 
         -  `gppDemand_none`: nothing 
     -  `gppDiffRadiation`: nothing 
         -  `gppDiffRadiation_GSI`: nothing 
         -  `gppDiffRadiation_Turner2006`: nothing 
         -  `gppDiffRadiation_Wang2015`: nothing 
         -  `gppDiffRadiation_none`: nothing 
     -  `gppDirRadiation`: nothing 
         -  `gppDirRadiation_Maekelae2008`: nothing 
         -  `gppDirRadiation_none`: nothing 
     -  `gppPotential`: nothing 
         -  `gppPotential_Monteith`: nothing 
     -  `gppSoilW`: nothing 
         -  `gppSoilW_CASA`: nothing 
         -  `gppSoilW_GSI`: nothing 
         -  `gppSoilW_Keenan2009`: nothing 
         -  `gppSoilW_Stocker2020`: nothing 
         -  `gppSoilW_none`: nothing 
     -  `gppVPD`: nothing 
         -  `gppVPD_MOD17`: nothing 
         -  `gppVPD_Maekelae2008`: nothing 
         -  `gppVPD_PRELES`: nothing 
         -  `gppVPD_expco2`: nothing 
         -  `gppVPD_none`: nothing 
     -  `groundWRecharge`: nothing 
         -  `groundWRecharge_dos`: nothing 
         -  `groundWRecharge_fraction`: nothing 
         -  `groundWRecharge_kUnsat`: nothing 
         -  `groundWRecharge_none`: nothing 
     -  `groundWSoilWInteraction`: nothing 
         -  `groundWSoilWInteraction_VanDijk2010`: nothing 
         -  `groundWSoilWInteraction_gradient`: nothing 
         -  `groundWSoilWInteraction_gradientNeg`: nothing 
         -  `groundWSoilWInteraction_none`: nothing 
     -  `groundWSurfaceWInteraction`: nothing 
         -  `groundWSurfaceWInteraction_fracGradient`: nothing 
         -  `groundWSurfaceWInteraction_fracGroundW`: nothing 
     -  `interception`: nothing 
         -  `interception_Miralles2010`: nothing 
         -  `interception_fAPAR`: nothing 
         -  `interception_none`: nothing 
         -  `interception_vegFraction`: nothing 
     -  `percolation`: nothing 
         -  `percolation_WBP`: nothing 
     -  `plantForm`: nothing 
         -  `plantForm_PFT`: nothing 
         -  `plantForm_fixed`: nothing 
     -  `rainIntensity`: nothing 
         -  `rainIntensity_forcing`: nothing 
         -  `rainIntensity_simple`: nothing 
     -  `rainSnow`: nothing 
         -  `rainSnow_Tair`: nothing 
         -  `rainSnow_forcing`: nothing 
         -  `rainSnow_rain`: nothing 
     -  `rootMaximumDepth`: nothing 
         -  `rootMaximumDepth_fracSoilD`: nothing 
     -  `rootWaterEfficiency`: nothing 
         -  `rootWaterEfficiency_constant`: nothing 
         -  `rootWaterEfficiency_expCvegRoot`: nothing 
         -  `rootWaterEfficiency_k2Layer`: nothing 
         -  `rootWaterEfficiency_k2fRD`: nothing 
         -  `rootWaterEfficiency_k2fvegFraction`: nothing 
     -  `rootWaterUptake`: nothing 
         -  `rootWaterUptake_proportion`: nothing 
         -  `rootWaterUptake_topBottom`: nothing 
     -  `runoff`: nothing 
         -  `runoff_sum`: nothing 
     -  `runoffBase`: nothing 
         -  `runoffBase_Zhang2008`: nothing 
         -  `runoffBase_none`: nothing 
     -  `runoffInfiltrationExcess`: nothing 
         -  `runoffInfiltrationExcess_Jung`: nothing 
         -  `runoffInfiltrationExcess_kUnsat`: nothing 
         -  `runoffInfiltrationExcess_none`: nothing 
     -  `runoffInterflow`: nothing 
         -  `runoffInterflow_none`: nothing 
         -  `runoffInterflow_residual`: nothing 
     -  `runoffOverland`: nothing 
         -  `runoffOverland_Inf`: nothing 
         -  `runoffOverland_InfIntSat`: nothing 
         -  `runoffOverland_Sat`: nothing 
         -  `runoffOverland_none`: nothing 
     -  `runoffSaturationExcess`: nothing 
         -  `runoffSaturationExcess_Bergstroem1992`: nothing 
         -  `runoffSaturationExcess_Bergstroem1992MixedVegFraction`: nothing 
         -  `runoffSaturationExcess_Bergstroem1992VegFraction`: nothing 
         -  `runoffSaturationExcess_Bergstroem1992VegFractionFroSoil`: nothing 
         -  `runoffSaturationExcess_Bergstroem1992VegFractionPFT`: nothing 
         -  `runoffSaturationExcess_Zhang2008`: nothing 
         -  `runoffSaturationExcess_none`: nothing 
         -  `runoffSaturationExcess_satFraction`: nothing 
     -  `runoffSurface`: nothing 
         -  `runoffSurface_Orth2013`: nothing 
         -  `runoffSurface_Trautmann2018`: nothing 
         -  `runoffSurface_all`: nothing 
         -  `runoffSurface_directIndirect`: nothing 
         -  `runoffSurface_directIndirectFroSoil`: nothing 
         -  `runoffSurface_indirect`: nothing 
         -  `runoffSurface_none`: nothing 
     -  `saturatedFraction`: nothing 
         -  `saturatedFraction_none`: nothing 
     -  `snowFraction`: nothing 
         -  `snowFraction_HTESSEL`: nothing 
         -  `snowFraction_binary`: nothing 
         -  `snowFraction_none`: nothing 
     -  `snowMelt`: nothing 
         -  `snowMelt_Tair`: nothing 
         -  `snowMelt_TairRn`: nothing 
     -  `soilProperties`: nothing 
         -  `soilProperties_Saxton1986`: nothing 
         -  `soilProperties_Saxton2006`: nothing 
     -  `soilTexture`: nothing 
         -  `soilTexture_constant`: nothing 
         -  `soilTexture_forcing`: nothing 
     -  `soilWBase`: nothing 
         -  `soilWBase_smax1Layer`: nothing 
         -  `soilWBase_smax2Layer`: nothing 
         -  `soilWBase_smax2fRD4`: nothing 
         -  `soilWBase_uniform`: nothing 
     -  `sublimation`: nothing 
         -  `sublimation_GLEAM`: nothing 
         -  `sublimation_none`: nothing 
     -  `transpiration`: nothing 
         -  `transpiration_coupled`: nothing 
         -  `transpiration_demandSupply`: nothing 
         -  `transpiration_none`: nothing 
     -  `transpirationDemand`: nothing 
         -  `transpirationDemand_CASA`: nothing 
         -  `transpirationDemand_PET`: nothing 
         -  `transpirationDemand_PETfAPAR`: nothing 
         -  `transpirationDemand_PETvegFraction`: nothing 
     -  `transpirationSupply`: nothing 
         -  `transpirationSupply_CASA`: nothing 
         -  `transpirationSupply_Federer1982`: nothing 
         -  `transpirationSupply_wAWC`: nothing 
         -  `transpirationSupply_wAWCvegFraction`: nothing 
     -  `treeFraction`: nothing 
         -  `treeFraction_constant`: nothing 
         -  `treeFraction_forcing`: nothing 
     -  `vegAvailableWater`: nothing 
         -  `vegAvailableWater_rootWaterEfficiency`: nothing 
         -  `vegAvailableWater_sigmoid`: nothing 
     -  `vegFraction`: nothing 
         -  `vegFraction_constant`: nothing 
         -  `vegFraction_forcing`: nothing 
         -  `vegFraction_scaledEVI`: nothing 
         -  `vegFraction_scaledLAI`: nothing 
         -  `vegFraction_scaledNDVI`: nothing 
         -  `vegFraction_scaledNIRv`: nothing 
         -  `vegFraction_scaledfAPAR`: nothing 
     -  `wCycle`: nothing 
         -  `wCycle_combined`: nothing 
         -  `wCycle_components`: nothing 
     -  `wCycleBase`: nothing 
         -  `wCycleBase_simple`: nothing 
     -  `waterBalance`: nothing 
         -  `waterBalance_simple`: nothing 



"""
Sindbad.SindbadTypes.ModelType

@doc """

# DoCatchModelErrors

Enable error catching during model execution

## Type Hierarchy

```DoCatchModelErrors <: ModelType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoCatchModelErrors

@doc """

# DoNotCatchModelErrors

Disable error catching during model execution

## Type Hierarchy

```DoNotCatchModelErrors <: ModelType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.DoNotCatchModelErrors

@doc """

# OptimizationType

Abstract type for optimization related functions and methods in SINDBAD

## Type Hierarchy

```OptimizationType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.OptimizationType

@doc """

# CostMethod

Abstract type for cost calculation methods in SINDBAD

## Type Hierarchy

```CostMethod <: OptimizationType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `CostModelObs`: cost calculation between model output and observations 
 -  `CostModelObsLandTS`: cost calculation between land model output and time series observations 
 -  `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
 -  `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 



"""
Sindbad.SindbadTypes.CostMethod

@doc """

# CostModelObs

cost calculation between model output and observations

## Type Hierarchy

```CostModelObs <: CostMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.CostModelObs

@doc """

# CostModelObsLandTS

cost calculation between land model output and time series observations

## Type Hierarchy

```CostModelObsLandTS <: CostMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.CostModelObsLandTS

@doc """

# CostModelObsMT

multi-threaded cost calculation between model output and observations

## Type Hierarchy

```CostModelObsMT <: CostMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.CostModelObsMT

@doc """

# CostModelObsPriors

cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET

## Type Hierarchy

```CostModelObsPriors <: CostMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.CostModelObsPriors

@doc """

# GSAMethod

Abstract type for global sensitivity analysis methods in SINDBAD

## Type Hierarchy

```GSAMethod <: OptimizationType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `GSAMorris`: Morris method for global sensitivity analysis 
 -  `GSASobol`: Sobol method for global sensitivity analysis 
 -  `GSASobolDM`: Sobol method with derivative-based measures for global sensitivity analysis 



"""
Sindbad.SindbadTypes.GSAMethod

@doc """

# GSAMorris

Morris method for global sensitivity analysis

## Type Hierarchy

```GSAMorris <: GSAMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.GSAMorris

@doc """

# GSASobol

Sobol method for global sensitivity analysis

## Type Hierarchy

```GSASobol <: GSAMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.GSASobol

@doc """

# GSASobolDM

Sobol method with derivative-based measures for global sensitivity analysis

## Type Hierarchy

```GSASobolDM <: GSAMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.GSASobolDM

@doc """

# OptimizationMethod

Abstract type for optimization methods in SINDBAD

## Type Hierarchy

```OptimizationMethod <: OptimizationType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.OptimizationMethod

@doc """

# BayesOptKMaternARD5

Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl

## Type Hierarchy

```BayesOptKMaternARD5 <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.BayesOptKMaternARD5

@doc """

# CMAEvolutionStrategyCMAES

Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl

## Type Hierarchy

```CMAEvolutionStrategyCMAES <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.CMAEvolutionStrategyCMAES

@doc """

# EvolutionaryCMAES

Evolutionary version of CMA-ES optimization from Evolutionary.jl

## Type Hierarchy

```EvolutionaryCMAES <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.EvolutionaryCMAES

@doc """

# OptimBFGS

Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl

## Type Hierarchy

```OptimBFGS <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimBFGS

@doc """

# OptimLBFGS

Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl

## Type Hierarchy

```OptimLBFGS <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimLBFGS

@doc """

# OptimizationBBOadaptive

Black Box Optimization with adaptive parameters from Optimization.jl

## Type Hierarchy

```OptimizationBBOadaptive <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationBBOadaptive

@doc """

# OptimizationBBOxnes

Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl

## Type Hierarchy

```OptimizationBBOxnes <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationBBOxnes

@doc """

# OptimizationBFGS

BFGS optimization with box constraints from Optimization.jl

## Type Hierarchy

```OptimizationBFGS <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationBFGS

@doc """

# OptimizationFminboxGradientDescent

Gradient descent optimization with box constraints from Optimization.jl

## Type Hierarchy

```OptimizationFminboxGradientDescent <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationFminboxGradientDescent

@doc """

# OptimizationFminboxGradientDescentFD

Gradient descent optimization with box constraints using forward differentiation from Optimization.jl

## Type Hierarchy

```OptimizationFminboxGradientDescentFD <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationFminboxGradientDescentFD

@doc """

# OptimizationGCMAESDef

Global CMA-ES optimization with default settings from Optimization.jl

## Type Hierarchy

```OptimizationGCMAESDef <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationGCMAESDef

@doc """

# OptimizationGCMAESFD

Global CMA-ES optimization using forward differentiation from Optimization.jl

## Type Hierarchy

```OptimizationGCMAESFD <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationGCMAESFD

@doc """

# OptimizationMultistartOptimization

Multi-start optimization to find global optimum from Optimization.jl

## Type Hierarchy

```OptimizationMultistartOptimization <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationMultistartOptimization

@doc """

# OptimizationNelderMead

Nelder-Mead simplex optimization method from Optimization.jl

## Type Hierarchy

```OptimizationNelderMead <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationNelderMead

@doc """

# OptimizationQuadDirect

Quadratic Direct optimization method from Optimization.jl

## Type Hierarchy

```OptimizationQuadDirect <: OptimizationMethod <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.OptimizationQuadDirect

@doc """

# ParameterScaling

Abstract type for parameter scaling methods in SINDBAD

## Type Hierarchy

```ParameterScaling <: OptimizationType <: SindbadType <: Any```

-----

# Extended Help

## Available methods/subtypes:

 -  `ScaleBounds`: Scale parameters relative to their bounds 
 -  `ScaleDefault`: Scale parameters relative to default values 
 -  `ScaleNone`: No parameter scaling applied 



"""
Sindbad.SindbadTypes.ParameterScaling

@doc """

# ScaleBounds

Scale parameters relative to their bounds

## Type Hierarchy

```ScaleBounds <: ParameterScaling <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ScaleBounds

@doc """

# ScaleDefault

Scale parameters relative to default values

## Type Hierarchy

```ScaleDefault <: ParameterScaling <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ScaleDefault

@doc """

# ScaleNone

No parameter scaling applied

## Type Hierarchy

```ScaleNone <: ParameterScaling <: OptimizationType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ScaleNone

@doc """

# SpinupType

Abstract type for model spinup related functions and methods in SINDBAD

## Type Hierarchy

```SpinupType <: SindbadType <: Any```

-----

# Extended Help

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
 -  `SpinupSequence`: Undefined purpose for SpinupSequence of type DataType. Add `purpose(::Type{SpinupSequence}) = "the_purpose"` in one of the files in the `src/SindbadTypes` folder where the function/type is defined. 
 -  `SpinupSequenceWithAggregator`: Spinup sequence with time aggregation capabilities 



"""
Sindbad.SindbadTypes.SpinupType

@doc """

# SpinupMode

Abstract type for model spinup modes in SINDBAD

## Type Hierarchy

```SpinupMode <: SpinupType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.SpinupMode

@doc """

# AllForwardModels

Use all forward models for spinup

## Type Hierarchy

```AllForwardModels <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.AllForwardModels

@doc """

# EtaScaleA0H

scale carbon pools using diagnostic scalars for ηH and c_remain

## Type Hierarchy

```EtaScaleA0H <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.EtaScaleA0H

@doc """

# EtaScaleA0HCWD

scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain

## Type Hierarchy

```EtaScaleA0HCWD <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.EtaScaleA0HCWD

@doc """

# EtaScaleAH

scale carbon pools using diagnostic scalars for ηH and ηA

## Type Hierarchy

```EtaScaleAH <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.EtaScaleAH

@doc """

# EtaScaleAHCWD

scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA

## Type Hierarchy

```EtaScaleAHCWD <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.EtaScaleAHCWD

@doc """

# NlsolveFixedpointTrustregionCEco

use a fixed-point nonlinear solver with trust region for carbon pools (cEco)

## Type Hierarchy

```NlsolveFixedpointTrustregionCEco <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NlsolveFixedpointTrustregionCEco

@doc """

# NlsolveFixedpointTrustregionCEcoTWS

use a fixed-point nonlinear solver with trust region for both cEco and TWS

## Type Hierarchy

```NlsolveFixedpointTrustregionCEcoTWS <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NlsolveFixedpointTrustregionCEcoTWS

@doc """

# NlsolveFixedpointTrustregionTWS

use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS)

## Type Hierarchy

```NlsolveFixedpointTrustregionTWS <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.NlsolveFixedpointTrustregionTWS

@doc """

# ODEAutoTsit5Rodas5

use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs

## Type Hierarchy

```ODEAutoTsit5Rodas5 <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ODEAutoTsit5Rodas5

@doc """

# ODEDP5

use the DP5 method from DifferentialEquations.jl for solving ODEs

## Type Hierarchy

```ODEDP5 <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ODEDP5

@doc """

# ODETsit5

use the Tsit5 method from DifferentialEquations.jl for solving ODEs

## Type Hierarchy

```ODETsit5 <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.ODETsit5

@doc """

# SSPDynamicSSTsit5

use the SteadyState solver with DynamicSS and Tsit5 methods

## Type Hierarchy

```SSPDynamicSSTsit5 <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SSPDynamicSSTsit5

@doc """

# SSPSSRootfind

use the SteadyState solver with SSRootfind method

## Type Hierarchy

```SSPSSRootfind <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SSPSSRootfind

@doc """

# SelSpinupModels

run only the models selected for spinup in the model structure

## Type Hierarchy

```SelSpinupModels <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SelSpinupModels

@doc """

# Spinup_TWS

Spinup spinup_mode for Total Water Storage (TWS)

## Type Hierarchy

```Spinup_TWS <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spinup_TWS

@doc """

# Spinup_cEco

Spinup spinup_mode for cEco

## Type Hierarchy

```Spinup_cEco <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spinup_cEco

@doc """

# Spinup_cEco_TWS

Spinup spinup_mode for cEco and TWS

## Type Hierarchy

```Spinup_cEco_TWS <: SpinupMode <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.Spinup_cEco_TWS

@doc """

# SpinupSequence

Undefined purpose for SpinupSequence of type DataType. Add `purpose(::Type{SpinupSequence}) = "the_purpose"` in one of the files in the `src/SindbadTypes` folder where the function/type is defined.

## Type Hierarchy

```SpinupSequence <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SpinupSequence

@doc """

# SpinupSequenceWithAggregator

Spinup sequence with time aggregation capabilities

## Type Hierarchy

```SpinupSequenceWithAggregator <: SpinupType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.SpinupSequenceWithAggregator

@doc """

# TimeType

Abstract type for implementing time subset and aggregation types in SINDBAD

## Type Hierarchy

```TimeType <: SindbadType <: Any```

-----

# Extended Help

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
 -  `TimeAggregator`: Undefined purpose for TimeAggregator of type UnionAll. Add `purpose(::Type{TimeAggregator}) = "the_purpose"` in one of the files in the `src/SindbadTypes` folder where the function/type is defined. 



"""
Sindbad.SindbadTypes.TimeType

@doc """

# TimeAggregation

Abstract type for time aggregation methods in SINDBAD

## Type Hierarchy

```TimeAggregation <: TimeType <: SindbadType <: Any```

-----

# Extended Help

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
Sindbad.SindbadTypes.TimeAggregation

@doc """

# TimeAllYears

aggregation/slicing to include all years

## Type Hierarchy

```TimeAllYears <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeAllYears

@doc """

# TimeArray

use array-based time aggregation

## Type Hierarchy

```TimeArray <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeArray

@doc """

# TimeDay

aggregation to daily time steps

## Type Hierarchy

```TimeDay <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeDay

@doc """

# TimeDayAnomaly

aggregation to daily anomalies

## Type Hierarchy

```TimeDayAnomaly <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeDayAnomaly

@doc """

# TimeDayIAV

aggregation to daily IAV

## Type Hierarchy

```TimeDayIAV <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeDayIAV

@doc """

# TimeDayMSC

aggregation to daily MSC

## Type Hierarchy

```TimeDayMSC <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeDayMSC

@doc """

# TimeDayMSCAnomaly

aggregation to daily MSC anomalies

## Type Hierarchy

```TimeDayMSCAnomaly <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeDayMSCAnomaly

@doc """

# TimeDiff

aggregation to time differences, e.g. monthly anomalies

## Type Hierarchy

```TimeDiff <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeDiff

@doc """

# TimeFirstYear

aggregation/slicing of the first year

## Type Hierarchy

```TimeFirstYear <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeFirstYear

@doc """

# TimeHour

aggregation to hourly time steps

## Type Hierarchy

```TimeHour <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeHour

@doc """

# TimeHourAnomaly

aggregation to hourly anomalies

## Type Hierarchy

```TimeHourAnomaly <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeHourAnomaly

@doc """

# TimeHourDayMean

aggregation to mean of hourly data over days

## Type Hierarchy

```TimeHourDayMean <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeHourDayMean

@doc """

# TimeIndexed

aggregation using time indices, e.g., TimeFirstYear

## Type Hierarchy

```TimeIndexed <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeIndexed

@doc """

# TimeMean

aggregation to mean over all time steps

## Type Hierarchy

```TimeMean <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeMean

@doc """

# TimeMonth

aggregation to monthly time steps

## Type Hierarchy

```TimeMonth <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeMonth

@doc """

# TimeMonthAnomaly

aggregation to monthly anomalies

## Type Hierarchy

```TimeMonthAnomaly <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeMonthAnomaly

@doc """

# TimeMonthIAV

aggregation to monthly IAV

## Type Hierarchy

```TimeMonthIAV <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeMonthIAV

@doc """

# TimeMonthMSC

aggregation to monthly MSC

## Type Hierarchy

```TimeMonthMSC <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeMonthMSC

@doc """

# TimeMonthMSCAnomaly

aggregation to monthly MSC anomalies

## Type Hierarchy

```TimeMonthMSCAnomaly <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeMonthMSCAnomaly

@doc """

# TimeNoDiff

aggregation without time differences

## Type Hierarchy

```TimeNoDiff <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeNoDiff

@doc """

# TimeRandomYear

aggregation/slicing of a random year

## Type Hierarchy

```TimeRandomYear <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeRandomYear

@doc """

# TimeShuffleYears

aggregation/slicing/selection of shuffled years

## Type Hierarchy

```TimeShuffleYears <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeShuffleYears

@doc """

# TimeSizedArray

aggregation to a sized array

## Type Hierarchy

```TimeSizedArray <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeSizedArray

@doc """

# TimeYear

aggregation to yearly time steps

## Type Hierarchy

```TimeYear <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeYear

@doc """

# TimeYearAnomaly

aggregation to yearly anomalies

## Type Hierarchy

```TimeYearAnomaly <: TimeAggregation <: TimeType <: SindbadType <: Any```


"""
Sindbad.SindbadTypes.TimeYearAnomaly

