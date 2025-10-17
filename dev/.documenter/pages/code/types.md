<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types' href='#Sindbad.Types'><span class="jlbinding">Sindbad.Types</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
Types Module
```


The `Types` module consolidates and organizes all the types used in the SINDBAD framework into a central location. This ensures a single line for type definitions, promoting consistency and reusability across all SINDBAD packages. It also provides helper functions and utilities for working with these types.

**Provided Types and Their Purpose**

**1. `SindbadTypes`**
- **Purpose**: Abstract type serving as the base for all Julia types in the SINDBAD framework.
  
- **Use**: Provides a unified hierarchy for SINDBAD-specific types.
  

**2. `ModelTypes`**
- **Purpose**: Defines types for models in SINDBAD.
  
- **Use**: Represents various model/processes.
  

**3. `TimeTypes`**
- **Purpose**: Defines types for handling time-related operations.
  
- **Use**: Manages temporal aggregation of data on the go.
  

**4. `SpinupTypes`**
- **Purpose**: Defines types for spinup processes in SINDBAD.
  
- **Use**: Handles methods for initialization and equilibrium states for models.
  

**5. `LandTypes`**
- **Purpose**: Defines types for collecting variable from `land` and saving them.
  
- **Use**: Builds land and array for model execution.
  

**6. `ArrayTypes`**
- **Purpose**: Defines types for array structures used in SINDBAD.
  
- **Use**: Provides specialized array types for efficient data handling in model simulation and output.
  

**7. `InputTypes`**
- **Purpose**: Defines types for input data and configurations.
  
- **Use**: Manages input flows and forcing data.
  

**8. `ExperimentTypes`**
- **Purpose**: Defines types for experiments conducted in SINDBAD.
  
- **Use**: Represents experimental setups, configurations, and results.
  

**9. `OptimizationTypes`**
- **Purpose**: Defines types for optimization-related functions and methods in SINDBAD.
  
- **Use**: Separates methods for optimization methods, cost functions, methods, etc.
  

**10. `MetricsTypes`**
- **Purpose**: Defines types for metrics used to evaluate model performance in SINDBAD.
  
- **Use**: Represents performance metrics and cost evaluation.
  

**11. `MLTypes`**
- **Purpose**: Defines types for machine learning components in SINDBAD.
  
- **Use**: Supports machine learning workflows and data structures.
  

**12. `LongTuple`**
- **Purpose**: Provides definitions and methods for working with `longTuple` type.
  
- **Use**: Facilitates operations on tuples with many elements to break them down into smaller tuples.
  

**13. `TypesFunctions`**
- **Purpose**: Provides helper functions related to SINDBAD types.
  
- **Use**: Includes utilities for introspection, type manipulation, and documentation.
  

**Key Functionality**

**`purpose(T::Type)`**
- **Description**: Returns a string describing the purpose of a type in the SINDBAD framework.
  
- **Use**: Provides a descriptive string for each type, explaining its role or functionality.
  
- **Example**:
  

```julia
purpose(::Type{BayesOptKMaternARD5}) = "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"
```


**Notes**
- The `Types` module serves as the backbone for type definitions in SINDBAD, ensuring modularity and extensibility.
  
- Each type is documented with its purpose, making it easier for developers to understand and extend the framework.
  

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ArrayView' href='#Sindbad.Types.ArrayView'><span class="jlbinding">Sindbad.Types.ArrayView</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
ArrayView{T,N,S<:AbstractArray{<:Any,N}}
```


**Fields:**
- `s::S`: The underlying array being viewed.
  
- `groupname::Symbol`: The name of the group containing the array.
  
- `arrayname::Symbol`: The name of the array being accessed.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.GroupView' href='#Sindbad.Types.GroupView'><span class="jlbinding">Sindbad.Types.GroupView</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
GroupView{S}
```


**Fields:**
- `groupname::Symbol`: The name of the group being accessed.
  
- `s::S`: The underlying data structure containing the group.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.LandWrapper' href='#Sindbad.Types.LandWrapper'><span class="jlbinding">Sindbad.Types.LandWrapper</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
LandWrapper{S}
```


**Fields:**
- `s::S`: The underlying NamedTuple or data structure being wrapped.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.LongTuple' href='#Sindbad.Types.LongTuple'><span class="jlbinding">Sindbad.Types.LongTuple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
LongTuple{NSPLIT,T}
```


A data structure that represents a tuple split into smaller chunks for better memory management and performance.

**Fields**
- `data::T`: The underlying tuple data
  
- `n::Val{NSPLIT}`: The number of splits as a value type
  

**Type Parameters**
- `NSPLIT`: The number of elements in each split
  
- `T`: The type of the underlying tuple
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SindbadTypes' href='#Sindbad.Types.SindbadTypes'><span class="jlbinding">Sindbad.Types.SindbadTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SindbadTypes**

Abstract type for all Julia types in SINDBAD

**Type Hierarchy**

`SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `ArrayTypes`: Abstract type for all array types in SINDBAD 
  - `ModelArrayType`: Abstract type for internal model array types in SINDBAD 
    - `ModelArrayArray`: Use standard Julia arrays for model variables 
      
    - `ModelArrayStaticArray`: Use StaticArrays for model variables 
      
    - `ModelArrayView`: Use array views for model variables 
      
    
  - `OutputArrayType`: Abstract type for output array types in SINDBAD 
    - `OutputArray`: Use standard Julia arrays for output 
      
    - `OutputMArray`: Use MArray for output 
      
    - `OutputSizedArray`: Use SizedArray for output 
      
    - `OutputYAXArray`: Use YAXArray for output 
      
    
  
- `ExperimentTypes`: Abstract type for model run flags and experimental setup and simulations in SINDBAD 
  - `OutputStrategy`: Abstract type for model output strategies in SINDBAD 
    - `DoNotOutputAll`: Disable output of all model variables 
      
    - `DoNotSaveSingleFile`: Save output variables in separate files 
      
    - `DoOutputAll`: Enable output of all model variables 
      
    - `DoSaveSingleFile`: Save all output variables in a single file 
      
    
  - `ParallelizationPackage`: Abstract type for using different parallelization packages in SINDBAD 
    - `QbmapParallelization`: Use Qbmap for parallelization 
      
    - `ThreadsParallelization`: Use Julia threads for parallelization 
      
    
  - `RunFlag`: Abstract type for model run configuration flags in SINDBAD 
    - `DoCalcCost`: Enable cost calculation between model output and observations 
      
    - `DoDebugModel`: Enable model debugging mode 
      
    - `DoFilterNanPixels`: Enable filtering of NaN values in spatial data 
      
    - `DoInlineUpdate`: Enable inline updates of model state 
      
    - `DoNotCalcCost`: Disable cost calculation between model output and observations 
      
    - `DoNotDebugModel`: Disable model debugging mode 
      
    - `DoNotFilterNanPixels`: Disable filtering of NaN values in spatial data 
      
    - `DoNotInlineUpdate`: Disable inline updates of model state 
      
    - `DoNotRunForward`: Disable forward model run 
      
    - `DoNotRunOptimization`: Disable model parameter optimization 
      
    - `DoNotSaveInfo`: Disable saving of model information 
      
    - `DoNotSpinupTEM`: Disable terrestrial ecosystem model spinup 
      
    - `DoNotStoreSpinup`: Disable storing of spinup results 
      
    - `DoNotUseForwardDiff`: Disable forward mode automatic differentiation 
      
    - `DoRunForward`: Enable forward model run 
      
    - `DoRunOptimization`: Enable model parameter optimization 
      
    - `DoSaveInfo`: Enable saving of model information 
      
    - `DoSpinupTEM`: Enable terrestrial ecosystem model spinup 
      
    - `DoStoreSpinup`: Enable storing of spinup results 
      
    - `DoUseForwardDiff`: Enable forward mode automatic differentiation 
      
    
  
- `InputTypes`: Abstract type for input data and processing related options in SINDBAD 
  - `DataFormatBackend`: Abstract type for input data backends in SINDBAD 
    - `BackendNetcdf`: Use NetCDF format for input data 
      
    - `BackendZarr`: Use Zarr format for input data 
      
    
  - `ForcingTime`: Abstract type for forcing variable types in SINDBAD 
    - `ForcingWithTime`: Forcing variable with time dimension 
      
    - `ForcingWithoutTime`: Forcing variable without time dimension 
      
    
  - `InputArrayBackend`: Abstract type for input data array types in SINDBAD 
    - `InputArray`: Use standard Julia arrays for input data 
      
    - `InputKeyedArray`: Use keyed arrays for input data 
      
    - `InputNamedDimsArray`: Use named dimension arrays for input data 
      
    - `InputYaxArray`: Use YAXArray for input data 
      
    
  - `SpatialSubsetter`: Abstract type for spatial subsetting methods in SINDBAD 
    - `SpaceID`: Use site ID (all caps) for spatial subsetting 
      
    - `SpaceId`: Use site ID (capitalized) for spatial subsetting 
      
    - `Spaceid`: Use site ID for spatial subsetting 
      
    - `Spacelat`: Use latitude for spatial subsetting 
      
    - `Spacelatitude`: Use full latitude for spatial subsetting 
      
    - `Spacelon`: Use longitude for spatial subsetting 
      
    - `Spacelongitude`: Use full longitude for spatial subsetting 
      
    - `Spacesite`: Use site location for spatial subsetting 
      
    
  
- `LandTypes`: Abstract type for land related types that are typically used in preparing objects for model runs in SINDBAD 
  - `LandWrapperType`: Abstract type for land wrapper types in SINDBAD 
    - `GroupView`: Represents a group of data within a `LandWrapper`, allowing access to specific groups of variables. 
      
    - `LandWrapper`: Wraps the nested fields of a NamedTuple output of SINDBAD land into a nested structure of views that can be easily accessed with dot notation. 
      
    
  - `PreAlloc`: Abstract type for preallocated land helpers types in prepTEM of SINDBAD 
    - `PreAllocArray`: use a preallocated array for model output 
      
    - `PreAllocArrayAll`: use a preallocated array to output all land variables 
      
    - `PreAllocArrayFD`: use a preallocated array for finite difference (FD) hybrid experiments 
      
    - `PreAllocArrayMT`: use arrays of nThreads size for land model output for replicates of multiple threads 
      
    - `PreAllocStacked`: save output as a stacked vector of land using map over temporal dimension 
      
    - `PreAllocTimeseries`: save land output as a preallocated vector for time series of land 
      
    - `PreAllocYAXArray`: use YAX arrays for model output 
      
    
  
- `MLTypes`: Abstract type for types in machine learning related methods in SINDBAD 
  - `ActivationType`: Abstract type for activation functions used in ML models 
    - `CustomSigmoid`: Use a custom sigmoid activation function. In this case, the `k_σ` parameter in ml_model sections of the settings is used to control the steepness of the sigmoid function. 
      
    - `FluxRelu`: Use Flux.jl ReLU activation function 
      
    - `FluxSigmoid`: Use Flux.jl Sigmoid activation function 
      
    - `FluxTanh`: Use Flux.jl Tanh activation function 
      
    
  - `MLGradType`: Abstract type for automatic differentiation or finite differences for gradient calculations 
    - `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
      
    - `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
      
    - `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
      
    - `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
      
    - `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
      
    - `ZygoteGrad`: Use Zygote.jl for automatic differentiation 
      
    
  - `MLModelType`: Abstract type for machine learning models used in SINDBAD 
    - `FluxDenseNN`: simple dense neural network model implemented in Flux.jl 
      
    
  - `MLOptimizerType`: Abstract type for optimizers used for training ML models in SINDBAD 
    - `OptimisersAdam`: Use Optimisers.jl Adam optimizer for training ML models in SINDBAD 
      
    - `OptimisersDescent`: Use Optimisers.jl Descent optimizer for training ML models in SINDBAD 
      
    
  - `MLTrainingType`: Abstract type for training a hybrid algorithm in SINDBAD 
    - `CalcFoldFromSplit`: Use a split of the data to calculate the folds for cross-validation. The default wat to calculate the folds is by splitting the data into k-folds. In this case, the split is done on the go based on the values given in ml_training.split_ratios and n_folds. 
      
    - `LoadFoldFromFile`: Use precalculated data to load the folds for cross-validation. In this case, the data path has to be set under ml_training.fold_path and ml_training.which_fold. The data has to be in the format of a jld2 file with the following structure: /folds/0, /folds/1, /folds/2, ... /folds/n_folds. Each fold has to be a tuple of the form (train_indices, test_indices). 
      
    - `LossModelObsML`: Loss function using metrics between the predicted model and observation as defined in optimization.json 
      
    - `MixedGradient`: Use a mixed gradient approach for training using gradient from multiple methods and combining them with pullback from zygote 
      
    
  
- `MetricTypes`: Abstract type for performance metrics and cost calculation methods in SINDBAD 
  - `DataAggrOrder`: Abstract type for data aggregation order in SINDBAD 
    - `SpaceTime`: Aggregate data first over space, then over time 
      
    - `TimeSpace`: Aggregate data first over time, then over space 
      
    
  - `PerfMetric`: Abstract type for performance metrics in SINDBAD 
    - `MSE`: Mean Squared Error: Measures the average squared difference between predicted and observed values 
      
    - `NAME1R`: Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations 
      
    - `NMAE1R`: Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations 
      
    - `NNSE`: Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range 
      
    - `NNSEInv`: Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range 
      
    - `NNSEσ`: Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure 
      
    - `NNSEσInv`: Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems 
      
    - `NPcor`: Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range 
      
    - `NPcorInv`: Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems 
      
    - `NSE`: Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations 
      
    - `NSEInv`: Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems 
      
    - `NSEσ`: Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure 
      
    - `NSEσInv`: Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems 
      
    - `NScor`: Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range 
      
    - `NScorInv`: Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems 
      
    - `Pcor`: Pearson Correlation: Measures linear correlation between predictions and observations 
      
    - `Pcor2`: Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations 
      
    - `Pcor2Inv`: Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems 
      
    - `PcorInv`: Inverse Pearson Correlation: Inverse of Pcor for minimization problems 
      
    - `Scor`: Spearman Correlation: Measures monotonic relationship between predictions and observations 
      
    - `Scor2`: Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations 
      
    - `Scor2Inv`: Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems 
      
    - `ScorInv`: Inverse Spearman Correlation: Inverse of Scor for minimization problems 
      
    
  - `SpatialDataAggr`: Abstract type for spatial data aggregation methods in SINDBAD 
    
  - `SpatialMetricAggr`: Abstract type for spatial metric aggregation methods in SINDBAD 
    - `MetricMaximum`: Take maximum value across spatial dimensions 
      
    - `MetricMinimum`: Take minimum value across spatial dimensions 
      
    - `MetricSpatial`: Apply spatial aggregation to metrics 
      
    - `MetricSum`: Sum values across spatial dimensions 
      
    
  
- `ModelTypes`: Abstract type for model types in SINDBAD 
  - `DoCatchModelErrors`: Enable error catching during model execution 
    
  - `DoNotCatchModelErrors`: Disable error catching during model execution 
    
  - `LandEcosystem`: Abstract type for all SINDBAD land ecosystem models/approaches 
    
  
- `OptimizationTypes`: Abstract type for optimization related functions and methods in SINDBAD 
  - `CostMethod`: Abstract type for cost calculation methods in SINDBAD 
    - `CostModelObs`: cost calculation between model output and observations 
      
    - `CostModelObsLandTS`: cost calculation between land model output and time series observations 
      
    - `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
      
    - `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 
      
    
  - `GSAMethod`: Abstract type for global sensitivity analysis methods in SINDBAD 
    - `GSAMorris`: Morris method for global sensitivity analysis 
      
    - `GSASobol`: Sobol method for global sensitivity analysis 
      
    - `GSASobolDM`: Sobol method with derivative-based measures for global sensitivity analysis 
      
    
  - `OptimizationMethod`: Abstract type for optimization methods in SINDBAD 
    - `BayesOptKMaternARD5`: Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl 
      
    - `CMAEvolutionStrategyCMAES`: Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl 
      
    - `EvolutionaryCMAES`: Evolutionary version of CMA-ES optimization from Evolutionary.jl 
      
    - `OptimBFGS`: Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl 
      
    - `OptimLBFGS`: Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl 
      
    - `OptimizationBBOadaptive`: Black Box Optimization with adaptive parameters from Optimization.jl 
      
    - `OptimizationBBOxnes`: Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl 
      
    - `OptimizationBFGS`: BFGS optimization with box constraints from Optimization.jl 
      
    - `OptimizationFminboxGradientDescent`: Gradient descent optimization with box constraints from Optimization.jl 
      
    - `OptimizationFminboxGradientDescentFD`: Gradient descent optimization with box constraints using forward differentiation from Optimization.jl 
      
    - `OptimizationGCMAESDef`: Global CMA-ES optimization with default settings from Optimization.jl 
      
    - `OptimizationGCMAESFD`: Global CMA-ES optimization using forward differentiation from Optimization.jl 
      
    - `OptimizationMultistartOptimization`: Multi-start optimization to find global optimum from Optimization.jl 
      
    - `OptimizationNelderMead`: Nelder-Mead simplex optimization method from Optimization.jl 
      
    - `OptimizationQuadDirect`: Quadratic Direct optimization method from Optimization.jl 
      
    
  - `ParameterScaling`: Abstract type for parameter scaling methods in SINDBAD 
    - `ScaleBounds`: Scale parameters relative to their bounds 
      
    - `ScaleDefault`: Scale parameters relative to default values 
      
    - `ScaleNone`: No parameter scaling applied 
      
    
  
- `SpinupTypes`: Abstract type for model spinup related functions and methods in SINDBAD 
  - `SpinupMode`: Abstract type for model spinup modes in SINDBAD 
    - `AllForwardModels`: Use all forward models for spinup 
      
    - `EtaScaleA0H`: scale carbon pools using diagnostic scalars for ηH and c_remain 
      
    - `EtaScaleA0HCWD`: scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain 
      
    - `EtaScaleAH`: scale carbon pools using diagnostic scalars for ηH and ηA 
      
    - `EtaScaleAHCWD`: scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA 
      
    - `NlsolveFixedpointTrustregionCEco`: use a fixed-point nonlinear solver with trust region for carbon pools (cEco) 
      
    - `NlsolveFixedpointTrustregionCEcoTWS`: use a fixed-point nonlinear solver with trust region for both cEco and TWS 
      
    - `NlsolveFixedpointTrustregionTWS`: use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS) 
      
    - `ODEAutoTsit5Rodas5`: use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs 
      
    - `ODEDP5`: use the DP5 method from DifferentialEquations.jl for solving ODEs 
      
    - `ODETsit5`: use the Tsit5 method from DifferentialEquations.jl for solving ODEs 
      
    - `SSPDynamicSSTsit5`: use the SteadyState solver with DynamicSS and Tsit5 methods 
      
    - `SSPSSRootfind`: use the SteadyState solver with SSRootfind method 
      
    - `SelSpinupModels`: run only the models selected for spinup in the model structure 
      
    - `Spinup_TWS`: Spinup spinup_mode for Total Water Storage (TWS) 
      
    - `Spinup_cEco`: Spinup spinup_mode for cEco 
      
    - `Spinup_cEco_TWS`: Spinup spinup_mode for cEco and TWS 
      
    
  - `SpinupSequence`: Basic Spinup sequence without time aggregation 
    
  - `SpinupSequenceWithAggregator`: Spinup sequence with time aggregation for corresponding forcingtime series 
    
  
- `TimeTypes`: Abstract type for implementing time subset and aggregation types in SINDBAD 
  - `TimeAggregation`: Abstract type for time aggregation methods in SINDBAD 
    - `TimeAllYears`: aggregation/slicing to include all years 
      
    - `TimeArray`: use array-based time aggregation 
      
    - `TimeDay`: aggregation to daily time steps 
      
    - `TimeDayAnomaly`: aggregation to daily anomalies 
      
    - `TimeDayIAV`: aggregation to daily IAV 
      
    - `TimeDayMSC`: aggregation to daily MSC 
      
    - `TimeDayMSCAnomaly`: aggregation to daily MSC anomalies 
      
    - `TimeDiff`: aggregation to time differences, e.g. monthly anomalies 
      
    - `TimeFirstYear`: aggregation/slicing of the first year 
      
    - `TimeHour`: aggregation to hourly time steps 
      
    - `TimeHourAnomaly`: aggregation to hourly anomalies 
      
    - `TimeHourDayMean`: aggregation to mean of hourly data over days 
      
    - `TimeIndexed`: aggregation using time indices, e.g., TimeFirstYear 
      
    - `TimeMean`: aggregation to mean over all time steps 
      
    - `TimeMonth`: aggregation to monthly time steps 
      
    - `TimeMonthAnomaly`: aggregation to monthly anomalies 
      
    - `TimeMonthIAV`: aggregation to monthly IAV 
      
    - `TimeMonthMSC`: aggregation to monthly MSC 
      
    - `TimeMonthMSCAnomaly`: aggregation to monthly MSC anomalies 
      
    - `TimeNoDiff`: aggregation without time differences 
      
    - `TimeRandomYear`: aggregation/slicing of a random year 
      
    - `TimeShuffleYears`: aggregation/slicing/selection of shuffled years 
      
    - `TimeSizedArray`: aggregation to a sized array 
      
    - `TimeYear`: aggregation to yearly time steps 
      
    - `TimeYearAnomaly`: aggregation to yearly anomalies 
      
    
  - `TimeAggregator`: define a type for temporal aggregation of an array 
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeAggregator' href='#Sindbad.Types.TimeAggregator'><span class="jlbinding">Sindbad.Types.TimeAggregator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
TimeAggregator{I, aggr_func}
```


define a type for temporal aggregation of an array

**Fields:**
- `indices::I`: indices to be collected for aggregation
  
- `aggr_func::aggr_func`: a function to use for aggregation, defaults to mean
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeAggregatorViewInstance' href='#Sindbad.Types.TimeAggregatorViewInstance'><span class="jlbinding">Sindbad.Types.TimeAggregatorViewInstance</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
TimeAggregatorViewInstance{T, N, D, P, AV <: TimeAggregator}
```


**Fields:**
- `parent::P`: the parent data
  
- `agg::AV`: a view of the parent data
  
- `dim::Val{D}`: a val instance of the type that stores the dimension to be aggregated on
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.getSindbadDefinitions-Tuple{Any, Any}' href='#Sindbad.Types.getSindbadDefinitions-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Types.getSindbadDefinitions</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSindbadDefinitions(sindbad_module, what_to_get; internal_only=true)
```


Returns all defined (and optionally internal) objects in the SINDBAD framework.

**Arguments**
- `sindbad_module`: The module to search for defined things
  
- `what_to_get`: The type of things to get (e.g., Type, Function)
  
- `internal_only`: Whether to only include internal definitions (default: true)
  

**Returns**
- An array of all defined things in the SINDBAD framework
  

**Example**

```julia
# Get all defined types in the SINDBAD framework
defined_types = getSindbadDefinitions(Sindbad, Type)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.getTypeDocString-Tuple{Type}' href='#Sindbad.Types.getTypeDocString-Tuple{Type}'><span class="jlbinding">Sindbad.Types.getTypeDocString</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTypeDocString(T::Type)
```


Generate a docstring for a type in a formatted way.

**Description**

This function generates a formatted docstring for a type, including its purpose and type hierarchy.

**Arguments**
- `T`: The type for which the docstring is to be generated 
  

**Returns**
- A string containing the formatted docstring for the type.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.loopWriteTypeDocString-Tuple{Any, Any}' href='#Sindbad.Types.loopWriteTypeDocString-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Types.loopWriteTypeDocString</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loopWriteTypeDocString(o_file, T)
```


Write a docstring for a type to a file.

**Description**

This function writes a docstring for a type to a file.

**Arguments**
- `o_file`: The file to write the docstring to
  
- `T`: The type for which the docstring is to be generated
  

**Returns**
- `o_file`: The file with the docstring written to it
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.methodsOf' href='#Sindbad.Types.methodsOf'><span class="jlbinding">Sindbad.Types.methodsOf</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
methodsOf(T::Type; ds="", is_subtype=false, bullet=" - ")
methodsOf(M::Module; the_type=Type, internal_only=true)
```


Display subtypes and their purposes for a type or module in a formatted way.

**Description**

This function provides a hierarchical display of subtypes and their purposes for a given type or module. For types, it shows a tree-like structure of subtypes and their purposes. For modules, it shows all defined types and their subtypes.

**Arguments**
- `T::Type`: The type whose subtypes should be displayed
  
- `M::Module`: The module whose types should be displayed
  
- `ds::String`: Delimiter string between entries (default: newline)
  
- `is_subtype::Bool`: Whether to include nested subtypes (default: false)
  
- `bullet::String`: Bullet point for each entry (default: &quot; - &quot;)
  
- `the_type::Type`: Type of objects to display in module (default: Type)
  
- `internal_only::Bool`: Whether to only show internal definitions (default: true)
  

**Returns**
- A formatted string showing the hierarchy of subtypes and their purposes
  

**Examples**

```julia
# Display subtypes of a type
methodsOf(LandEcosystem)

# Display with custom formatting
methodsOf(LandEcosystem; ds=", ", bullet=" * ")

# Display including nested subtypes
methodsOf(LandEcosystem; is_subtype=true)

# Display types in a module
methodsOf(Sindbad)

# Display specific types in a module
methodsOf(Sindbad; the_type=Function)
```


**Extended help**

The output format for types is:

```julia
## TypeName
Purpose of the type

## Available methods/subtypes:
 - subtype1: purpose
 - subtype2: purpose
    - nested_subtype1: purpose
    - nested_subtype2: purpose
```


If no subtypes exist, it will show &quot; - `None`&quot;.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.purpose' href='#Sindbad.Types.purpose'><span class="jlbinding">Sindbad.Types.purpose</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
purpose(T::Type)
```


Returns a string describing the purpose of a type in the SINDBAD framework.

**Description**
- This is a base function that should be extended by each package for their specific types.
  
- When in SINDBAD models, purpose is a descriptive string that explains the role or functionality of the model or approach within the SINDBAD framework. If the purpose is not defined for a specific model or approach, it provides guidance on how to define it.
  
- When in SINDBAD lib, purpose is a descriptive string that explains the dispatch on the type for the specific function. For instance, metricTypes.jl has a purpose for the types of metrics that can be computed.
  

**Arguments**
- `T::Type`: The type whose purpose should be described
  

**Returns**
- A string describing the purpose of the type
  

**Example**

```julia
# Define the purpose for a specific model
purpose(::Type{BayesOptKMaternARD5}) = "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"

# Retrieve the purpose
println(purpose(BayesOptKMaternARD5))  # Output: "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.showMethodsOf-Tuple{Any}' href='#Sindbad.Types.showMethodsOf-Tuple{Any}'><span class="jlbinding">Sindbad.Types.showMethodsOf</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
showMethodsOf(T)
```


Display the subtypes and their purposes of a type in a formatted way.

**Description**

This function displays the hierarchical structure of subtypes and their purposes for a given type. It uses `methodsOf` internally to generate the formatted output and prints it to the console.

**Arguments**
- `T`: The type whose subtypes and purposes should be displayed
  

**Returns**
- `nothing`
  

**Examples**

```julia
# Display subtypes of LandEcosystem
showMethodsOf(LandEcosystem)

# Display subtypes of a specific model type
showMethodsOf(ambientCO2)
```


**Extended help**

The output format is the same as `methodsOf`, showing:

```julia
## TypeName
Purpose of the type

## Available methods/subtypes:
 - subtype1: purpose
 - subtype2: purpose
    - nested_subtype1: purpose
    - nested_subtype2: purpose
```


This function is a convenience wrapper around `methodsOf` that automatically prints the output to the console.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.writeTypeDocString-Tuple{Any, Any}' href='#Sindbad.Types.writeTypeDocString-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Types.writeTypeDocString</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
writeTypeDocString(o_file, T)
```


Write a docstring for a type to a file.

**Description**

This function writes a docstring for a type to a file.

**Arguments**
- `o_file`: The file to write the docstring to
  
- `T`: The type for which the docstring is to be generated
  

**Returns**
- `o_file`: The file with the docstring written to it
  

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='Base.getproperty-Tuple{GroupView, Symbol}' href='#Base.getproperty-Tuple{GroupView, Symbol}'><span class="jlbinding">Base.getproperty</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.getproperty(g::GroupView, aggr_func::Symbol)
```


Accesses a specific array within a group of data in a `GroupView`.

**Returns:**

An `ArrayView` object for the specified array.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.propertynames-Tuple{GroupView}' href='#Base.propertynames-Tuple{GroupView}'><span class="jlbinding">Base.propertynames</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.propertynames(o::GroupView)
```


Returns the property names of a group in a `GroupView`.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.show-Tuple{IO, GroupView}' href='#Base.show-Tuple{IO, GroupView}'><span class="jlbinding">Base.show</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.show(io::IO, gv::GroupView)
```


Displays a summary of the contents of a `GroupView`.

</details>

