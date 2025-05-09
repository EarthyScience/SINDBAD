# SINDBAD Metrics

This document provides comprehensive documentation for the metrics used to evaluate and optimize SINDBAD models.


## Overview

The SINDBAD metrics are implemented in the `SindbadMetrics` library package located in the `lib` directory. The metrics system is designed to be modular and extensible, allowing users to define custom metrics for specific use cases while maintaining compatibility with SINDBAD's optimization and evaluation workflows.

## Available Metrics

To view the list of available metrics:


:::tip
To list all available cost metrics and their purposes, use:
```julia
using Sindbad
showMethodsOf(PerfMetric)
```
This will display a formatted list of all cost metrics and their descriptions, including:
- The metric's purpose
- Required parameters
- Return values
- Any special considerations

:::

The following metrics are currently supported:

### Error-based Metrics

- `MSE`: Mean squared error - Measures the average squared difference between predicted and observed values
- `NAME1R`: Normalized Absolute Mean Error with 1/R scaling - Measures the absolute difference between means normalized by the range of observations
- `NMAE1R`: Normalized Mean Absolute Error with 1/R scaling - Measures the average absolute error normalized by the range of observations

### Nash-Sutcliffe Efficiency Metrics

- `NSE`: Nash-Sutcliffe Efficiency - Measures model performance relative to the mean of observations
- `NSEInv`: Inverse Nash-Sutcliffe Efficiency - Inverse of NSE for minimization problems
- `NSEσ`: Nash-Sutcliffe Efficiency with uncertainty - Incorporates observation uncertainty in the performance measure
- `NSEσInv`: Inverse Nash-Sutcliffe Efficiency with uncertainty - Inverse of NSEσ for minimization problems
- `NNSE`: Normalized Nash-Sutcliffe Efficiency - Measures model performance relative to the mean of observations, normalized to [0,1] range
- `NNSEInv`: Inverse Normalized Nash-Sutcliffe Efficiency - Inverse of NNSE for minimization problems, normalized to [0,1] range
- `NNSEσ`: Normalized Nash-Sutcliffe Efficiency with uncertainty - Incorporates observation uncertainty in the normalized performance measure
- `NNSEσInv`: Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty - Inverse of NNSEσ for minimization problems

### Correlation-based Metrics

- `Pcor`: Pearson Correlation - Measures linear correlation between predictions and observations
- `PcorInv`: Inverse Pearson Correlation - Inverse of Pcor for minimization problems
- `Pcor2`: Squared Pearson Correlation - Measures the strength of linear relationship between predictions and observations
- `Pcor2Inv`: Inverse Squared Pearson Correlation - Inverse of Pcor2 for minimization problems
- `NPcor`: Normalized Pearson Correlation - Measures linear correlation between predictions and observations, normalized to [0,1] range
- `NPcorInv`: Inverse Normalized Pearson Correlation - Inverse of NPcor for minimization problems

### Rank Correlation Metrics

- `Scor`: Spearman Correlation - Measures monotonic relationship between predictions and observations
- `ScorInv`: Inverse Spearman Correlation - Inverse of Scor for minimization problems
- `Scor2`: Squared Spearman Correlation - Measures the strength of monotonic relationship between predictions and observations
- `Scor2Inv`: Inverse Squared Spearman Correlation - Inverse of Scor2 for minimization problems
- `NScor`: Normalized Spearman Correlation - Measures monotonic relationship between predictions and observations, normalized to [0,1] range
- `NScorInv`: Inverse Normalized Spearman Correlation - Inverse of NScor for minimization problems

## Adding a New Metric

### 1. Define the Metric Type

Create a new metric type in `lib/SindbadMetrics/src/metricTypes.jl`:

```julia
export NewMetric
struct NewMetric <: PerfMetric end
```

Requirements:
- Use PascalCase for the type name
- Make it a subtype of `PerfMetric`
- Export the type
- Add a purpose function describing the metric's role

### 2. Implement the Metric Function

Implement the metric calculation in `lib/SindbadMetrics/src/metrics.jl`:

```julia
function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NewMetric)
    # Your metric calculation here
    return metric_value
end
```

Requirements:
- Function must be named `metric`
- Must take four arguments:
  - `y`: Observation data
  - `yσ`: Observational uncertainty data
  - `ŷ`: Model simulation data/estimate
  - The metric type
- Must return a scalar value

### 3. Using the New Metric

To use your new metric in an experiment:

```julia
cost_options = (
    variable = :your_variable,
    cost_metric = NewMetric(),
    # other options...
)
```

### 4. Testing

Test your new metric by:
- Running it on sample data
- Comparing results with existing metrics
- Verifying it works in the optimization process

## Metric Implementation Details

### Data Handling

The metrics system includes several helper functions for data handling:

- `getDataWithoutNaN`: Returns model and observation data excluding NaN values
- `aggregateData`: Aggregates data based on specified order (TimeSpace or SpaceTime)
- `applySpatialWeight`: Applies area weights to the data
- `getHarmonizedData`: Harmonizes model and observation data for comparison

### Metric Combination

Metrics can be combined using various methods:

- `MetricSum`: Returns the total sum as the metric
- `MetricMinimum`: Returns the minimum value as the metric
- `MetricMaximum`: Returns the maximum value as the metric
- `percentile_value`: Returns the specified percentile as the metric

## Examples

### Calculating a Simple Metric

```julia
using SindbadMetrics

# Define observations and model output
y = [1.0, 2.0, 3.0]  # observations
yσ = [0.1, 0.1, 0.1]  # uncertainties
ŷ = [1.1, 2.1, 3.1]  # model output

# Calculate MSE
mse = metric(y, yσ, ŷ, MSE())

# Calculate correlation
correlation = metric(y, yσ, ŷ, Pcor())
```

### Using Multiple Metrics in Optimization

```julia
# Define cost options for multiple variables
cost_options = [
    (
        variable = :variable1,
        cost_metric = MSE(),
        cost_weight = 1.0
    ),
    (
        variable = :variable2,
        cost_metric = Pcor(),
        cost_weight = 0.5
    )
]

# Calculate combined metric
cost_vector = metricVector(model_output, observations, cost_options)
combined_metric = combineMetric(cost_vector, MetricSum())
```

## Best Practices

1. **Documentation**
   - Add clear documentation for your new metric
   - Include mathematical formulas if applicable
   - Provide usage examples

2. **Testing**
   - Test with various data types and sizes
   - Verify edge cases (e.g., NaN values)
   - Compare with existing metrics

3. **Performance**
   - Optimize for large datasets
   - Consider memory usage
   - Handle missing values appropriately

4. **Compatibility**
   - Ensure compatibility with existing workflows
   - Follow the established interface
   - Maintain consistent error handling

## Defining Purpose for Metric Types

Each metric type in SINDBAD should have a `purpose` function that describes its role in the framework. This helps with documentation and provides clear information about what each metric does.

### How to Define Purpose

1. Make sure that the base `purpose` function from SindbadUtils is already imported:
```julia
import SindbadUtils: purpose
```

2. Then, `purpose` can be easily extended for your metric type:
```julia
# For a concrete metric type
purpose(::Type{MyMetric}) = "Description of what MyMetric does"
```

### Best Practices
- Keep descriptions concise but informative
- Focus on what the metric measures and how it's calculated
- Include any normalization or scaling factors in the description
- For abstract types, clearly indicate their role in the type hierarchy
