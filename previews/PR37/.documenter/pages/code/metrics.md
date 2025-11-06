<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics' href='#SindbadMetrics'><span class="jlbinding">SindbadMetrics</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadMetrics
```


The `SindbadMetrics` package provides tools for evaluating the performance of SINDBAD models. It includes a variety of metrics for comparing model outputs with observations, calculating statistical measures, and updating model parameters based on evaluation results.

**Purpose:**

This package is designed to define and compute metrics that assess the accuracy and reliability of SINDBAD models. It supports a wide range of statistical and performance metrics, enabling robust model evaluation and calibration.

It has heavy usage in `SindbadOptimization` but the package is separated to reduce to import burdens of optimization schemes. This allows for import into independent workflows for model evaluation and parameter estimation, e.g., in hybrid modeling.

**Dependencies:**
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `SindbadUtils`: Provides utility functions for handling data and NamedTuples, which are essential for metric calculations.
  

**Included Files:**
1. **`handleDataForLoss.jl`**:
  - Implements functions for preprocessing and handling data before calculating loss functions or metrics.
    
  
2. **`getMetrics.jl`**:
  - Provides functions for retrieving and organizing metrics based on model outputs and observations.
    
  
3. **`metrics.jl`**:
  - Contains the core metric definitions, including statistical measures (e.g., RMSE, correlation) and custom metrics for SINDBAD experiments.
    
  

::: tip Note
- The package is designed to be extensible, allowing users to define custom metrics for specific use cases.
  
- Metrics are computed in a modular fashion, ensuring compatibility with SINDBAD&#39;s optimization and evaluation workflows.
  
- Supports both standard statistical metrics and domain-specific metrics tailored to SINDBAD experiments.
  

:::

**Examples:**
1. **Calculating RMSE**:
  

```julia
using SindbadMetrics
rmse = metric(model_output, observations, RMSE())
```

1. **Computing correlation**:
  

```julia
using SindbadMetrics
correlation = metric(model_output, observations, Pcor())
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/SindbadMetrics.jl#L1-L46" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.combineMetric' href='#SindbadMetrics.combineMetric'><span class="jlbinding">SindbadMetrics.combineMetric</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
combineMetric(metric_vector::AbstractArray, ::MetricSum)
combineMetric(metric_vector::AbstractArray, ::MetricMinimum)
combineMetric(metric_vector::AbstractArray, ::MetricMaximum)
combineMetric(metric_vector::AbstractArray, percentile_value::T)
```


combines the metric from all constraints based on the type of combination.

**Arguments:**
- `metric_vector`: a vector of metrics for variables
  

**methods for combining the metric**
- `::MetricSum`: return the total sum as the metric.
  
- `::MetricMinimum`: return the minimum of the `metric_vector` as the metric.
  
- `::MetricMaximum`: return the maximum of the `metric_vector` as the metric.
  
- `percentile_value::T`: `percentile_value^th` percentile of metric of each constraint as the overall metric
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/getMetrics.jl#L5-L22" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.getData' href='#SindbadMetrics.getData'><span class="jlbinding">SindbadMetrics.getData</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getData(model_output::LandWrapper, observations, cost_option)
getData(model_output::NamedTuple, observations, cost_option)
getData(model_output::AbstractArray, observations, cost_option)
```


**Arguments:**
- `model_output`: a collection of SINDBAD model output time series as a time series of stacked land NT or as a preallocated array.
  
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
  
- `cost_option`: information for a observation constraint on how it should be used to calculate the loss/metric of model performance
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/handleDataForLoss.jl#L93-L102" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.getDataWithoutNaN' href='#SindbadMetrics.getDataWithoutNaN'><span class="jlbinding">SindbadMetrics.getDataWithoutNaN</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getDataWithoutNaN(y, yσ, ŷ, idxs)
getDataWithoutNaN(y, yσ, ŷ)
```


return model and obs data excluding for the common `NaN` or for the valid pixels `idxs`.

**Arguments:**
- `y`: observation data
  
- `yσ`: observational uncertainty data
  
- `ŷ`: model simulation data/estimate
  
- `idxs`: indices of valid data points    
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/getMetrics.jl#L43-L54" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.getModelOutputView-Union{Tuple{AbstractArray{<:Any, N}}, Tuple{N}} where N' href='#SindbadMetrics.getModelOutputView-Union{Tuple{AbstractArray{<:Any, N}}, Tuple{N}} where N'><span class="jlbinding">SindbadMetrics.getModelOutputView</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
 getModelOutputView(_dat::AbstractArray{<:Any,N}) where N
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/handleDataForLoss.jl#L158-L162" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.metric' href='#SindbadMetrics.metric'><span class="jlbinding">SindbadMetrics.metric</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, <: PerfMetric)
```


calculate the performance/loss metric for given observation and model simulation data stream

**Arguments:**
- `y`: observation data
  
- `yσ`: observational uncertainty data
  
- `ŷ`: model simulation data
  

**Returns:**
- `metric`: The calculated metric value
  

**PerfMetric**

Abstract type for performance metrics in SINDBAD

**Available methods/subtypes:**
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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/metrics.jl#L3-L18" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.metricVector' href='#SindbadMetrics.metricVector'><span class="jlbinding">SindbadMetrics.metricVector</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
metricVector(model_output::LandWrapper, observations, cost_options)
metricVector(model_output, observations, cost_options)
```


returns a vector of metrics for variables in cost_options.variable.   

**Arguments:**
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
  
- `model_output`: a collection of SINDBAD model output time series as a time series of stacked land NT
  
- `cost_options`: a table listing each observation constraint and how it should be used to calculate the loss/metric of model performance    
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/getMetrics.jl#L71-L81" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.aggregateData' href='#SindbadMetrics.aggregateData'><span class="jlbinding">SindbadMetrics.aggregateData</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
aggregateData(dat, cost_option, ::TimeSpace)
aggregateData(dat, cost_option, ::SpaceTime)
```


aggregate the data based on the order of aggregation.

**Arguments:**
- `dat`: a data array/vector to aggregate
  
- `cost_option`: information for a observation constraint on how it should be used to calculate the loss/metric of model performance
  
- `::TimeSpace`: appropriate type dispatch for the order of aggregation
  
- `::SpaceTime`: appropriate type dispatch for the order of aggregation
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/handleDataForLoss.jl#L5-L16" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.aggregateObsData' href='#SindbadMetrics.aggregateObsData'><span class="jlbinding">SindbadMetrics.aggregateObsData</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
aggregateObsData(y, yσ, cost_option, ::DoAggrObs)
aggregateObsData(y, yσ, _, ::DoNotAggrObs)
```


**Arguments:**
- `y`: observation data
  
- `yσ`: observational uncertainty data
  
- `cost_option`: information for a observation constraint on how it should be used to calculate the loss/metric of model performance
  
- `::DoAggrObs`: appropriate type dispatch for aggregation of observation data
  
- `::DoNotAggrObs`: appropriate type dispatch for not aggregating observation data
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/handleDataForLoss.jl#L33-L43" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.applySpatialWeight' href='#SindbadMetrics.applySpatialWeight'><span class="jlbinding">SindbadMetrics.applySpatialWeight</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
applySpatialWeight(y, yσ, ŷ, cost_option, ::DoSpatialWeight)
applySpatialWeight(y, yσ, ŷ, _, ::DoNotSpatialWeight)
```


return model and obs data after applying the area weight.

**Arguments:**
- `y`: observation data
  
- `yσ`: observational uncertainty data
  
- `ŷ`: model simulation data/estimate
  
- `::DoSpatialWeight`: type dispatch for doing area weight
  
- `::DoNotSpatialWeight`: type dispatch for not doing area weight
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/handleDataForLoss.jl#L56-L68" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadMetrics.doSpatialAggregation-Tuple{Any, Any, ConcatData}' href='#SindbadMetrics.doSpatialAggregation-Tuple{Any, Any, ConcatData}'><span class="jlbinding">SindbadMetrics.doSpatialAggregation</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
doSpatialAggregation(dat, _, ::ConcatData)
```


**Arguments:**
- `dat`: a data array/vector to aggregate
  
- `_`: unused argument
  
- `::ConcatData`: A type indicating that the data should not be aggregated spatially
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadMetrics/src/handleDataForLoss.jl#L174-L181" target="_blank" rel="noreferrer">source</a></Badge>

</details>

