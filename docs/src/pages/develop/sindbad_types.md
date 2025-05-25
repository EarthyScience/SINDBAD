# SINDBAD Types Module Documentation

This page serves as an overview of the type definitions and modules within the SINDBAD framework. Each section below corresponds to a separate Julia source file located in the `src/Types` directory.

## Types.jl
**Main module file that defines the core type system and includes type definitions for SINDBAD.**

This file establishes the `purpose` function, which provides descriptive information about types in the SINDBAD framework. It defines the base `SindbadTypes` abstract type from which all other SINDBAD types inherit. The file includes all other type definition files and provides documentation for the type system.

## ModelTypes.jl
**Defines the core model type hierarchy for SINDBAD.**

This file establishes the `ModelTypes` abstract type and its subtypes, particularly focusing on land ecosystem models. It includes:
- `LandEcosystem`: Abstract type for all land ecosystem models
- Error handling types: `DoCatchModelErrors` and `DoNotCatchModelErrors`

The file also implements recursive purpose retrieval for model types.

## TimeTypes.jl
**Defines time-related types for temporal subsetting and aggregation.**

This file defines `TimeTypes` abstract type and provides a comprehensive set of time-related types for handling different temporal scales and aggregation methods:
- `TimeAggregator`: Core structure for temporal aggregation
- Various time scales: `TimeHour`, `TimeDay`, `TimeMonth`, `TimeYear`
- Specialized time slice views: `TimeAllYears`, `TimeFirstYear`, `TimeRandomYear`
- Statistical time aggregations: `TimeMean`, `TimeDiff`, `TimeIAV` (Inter-Annual Variability)
- Mean Seasonal Cycle (MSC) types: `TimeDayMSC`, `TimeMonthMSC`
- Anomaly types: `TimeHourAnomaly`, `TimeDayAnomaly`, etc.

## SpinupTypes.jl
**Defines types for model spinup procedures and sequences.**

This file defines the `SpinupTypes` abstract type and its subtypes, which contains types for different spinup modes and methods:
- `SpinupMode`: Abstract type with numerous concrete implementations
- Scaling methods: `EtaScaleA0H`, `EtaScaleAH`, etc.
- Solver methods: `NlsolveFixedpointTrustregion`, `ODETsit5`, etc.
- Spinup sequence types: `SpinupSequence`, `SpinupSequenceWithAggregator`

These types control how models reach equilibrium states before simulation.

## LandTypes.jl
**Defines types for land model data structures and helpers.**

This file defines the `LandTypes` abstract type and its subtypes, which provides types for handling SINDBAD `land` and how the model output in every time step is organized:
- `PreAlloc`: Types for preallocating memory for model outputs
- `LandWrapper`: A wrapper for nested data structures with dot notation access
- `GroupView`: For accessing groups of data within a `LandWrapper`
- `ArrayView`: For accessing specific arrays within groups

Includes methods for pretty-printing and accessing data in these structures.

## ArrayTypes.jl
**Defines array types used throughout the SINDBAD framework.**

This file defines `ArrayTypes` and contains two main categories of array types:
- `ModelArrayType`: For internal model variables (standard arrays, static arrays, views)
- `OutputArrayType`: For model outputs (standard arrays, MArrays, SizedArrays, YAXArrays)

These types control how data is stored and manipulated within the model and output processes.

## InputTypes.jl
**Defines types for handling input data and processing.**

This file defines the `InputTypes` abstract type and its subtypes, which includes types for:
- Data backends: `BackendNetcdf`, `BackendZarr`
- Input array types: `InputArray`, `InputKeyedArray`, `InputNamedDimsArray`, `InputYaxArray`
- Forcing variable types: `ForcingWithTime`, `ForcingWithoutTime`
- Spatial subsetting methods: `Spaceid`, `Spacelatitude`, `Spacelon`, etc.

These types control how input data is loaded and processed.

## ExperimentTypes.jl
**Defines types for experiment configuration and execution.**

This file defines the `ExperimentTypes` abstract type and its subtypes, which contains types for controlling model runs:
- `RunFlag`: Boolean flags for various model behaviors (e.g., `DoSpinupTEM`, `DoSaveInfo`)
- `ParallelizationPackage`: Options for parallelization (`ThreadsParallelization`, `QbmapParallelization`)
- `OutputStrategy`: Controls for model output behavior (`DoOutputAll`, `DoSaveSingleFile`)

These types configure how model experiments are executed.

## OptimizationTypes.jl
**Defines types for model optimization and parameter estimation.**

This file defines the `OptimizationTypes` abstract type and its subtypes, which includes:
- `OptimizationMethod`: Various optimization algorithms (BFGS, CMA-ES, Nelder-Mead, etc.)
- `GSAMethod`: Global sensitivity analysis methods (Morris, Sobol)
- `CostMethod`: Methods for calculating cost between model and observations
- `ParameterScaling`: Methods for scaling parameters during optimization

These types control how model parameters are optimized.

## MetricsTypes.jl
**Defines types for model performance metrics and evaluation.**

This file defines `MetricTypes` abstract type and its subtypes, which contains:
- `PerfMetric`: Performance metrics (NSE, correlation, MSE, etc.)
- `DataAggrOrder`: Controls order of data aggregation (space-then-time or time-then-space)
- `SpatialDataAggr`: Methods for spatial data aggregation
- `SpatialMetricAggr`: Methods for aggregating metrics spatially

These types control how model performance is evaluated.

## MLTypes.jl
**Defines types for machine learning and gradient calculations.**

This file defines `MLTypes` abstract type and its subtypes, which focuses on gradient calculation methods:
- `MLGradType`: Abstract type for gradient calculation methods
- Various automatic differentiation methods: `ForwardDiffGrad`, `ZygoteGrad`, `EnzymeGrad`
- Finite difference methods: `FiniteDiffGrad`, `FiniteDifferencesGrad`

These types control how gradients are calculated for optimization.

## LongTuple.jl
**Defines a specialized tuple type for handling large collections of data.**

This file implements the `LongTuple` type, which splits large tuples into smaller chunks for better memory management and performance. It includes methods for indexing, mapping, and displaying these `LongTuple`s.

## TypesFunctions.jl
**Provides utility functions for working with SINDBAD types.**

This file contains functions for:
- `getSindbadDefinitions`: Retrieving defined objects in SINDBAD
- `getTypeDocString`: Generating formatted documentation for types
- `methodsOf`: Displaying subtypes and their purposes
- `writeTypeDocString`: Writing type documentation to files

These functions support documentation and introspection of the type system.

## docStringForTypes.jl
**Contains generated documentation for SINDBAD types.**

This file contains pre-generated documentation strings for all SINDBAD types, including their purpose, type hierarchy, and available subtypes. These docstrings are attached to the corresponding types at runtime.

::: warning

This file should not be edited manually; it's automatically generated by when `SindbadSetup` is precompiled, and changes are tracked when a new type is defined.

:::