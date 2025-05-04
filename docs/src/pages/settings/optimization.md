# Optimization Configuration

The `optimization.json` file configures parameter optimization settings, including the optimization algorithm, target parameters, observational constraints, and cost calculation methods.

## Optimization Algorithm

The `algorithm_optimization` field specifies the optimization scheme, which can be either:
- A direct algorithm name
- A path to a JSON file with detailed algorithm settings

:::tabs

== Explanation
```json
"algorithm_optimization": "Path to algorithm configuration or algorithm name"
```

== Example
```json
"algorithm_optimization": "opti_algorithms/CMAEvolutionStrategy_CMAES.json"
```
:::

### Algorithm Configuration File

The algorithm configuration file specifies detailed optimization settings:

:::tabs

== Explanation
```json
{
    "method": "Optimization method name",
    "options": {
        "maxfevals": "Maximum function evaluations",
        "multi_threading": "Enable multi-threading support"
    },
    "package": "Source package for optimization"
}
```

== Example
```json
{
    "method": "CMAES",
    "options": {
        "maxfevals": 1000,
        "multi_threading": false
    },
    "package": "CMAEvolutionStrategy"
}
```
:::

::: warning Algorithm Selection
- The same method may be available through different packages
- Both method and package must be specified
- Options can be customized for each method/package combination
:::

::: tip Available Methods
To list all implemented optimization methods:
```julia
using SindbadOptimization
showMethodsOf(SindbadOptimizationMethod)
```
:::

## Optimization Parameters

This section defines default parameter properties and lists parameters to optimize.

### Default Parameter Settings

:::tabs

== Explanation
```json
"model_parameter_default": {
    "distribution": ["Distribution type", "Distribution parameters"],
    "is_ml": "Flag for machine learning optimization"
}
```

== Example
```json
"model_parameter_default": {
    "distribution": ["normal", [0.0, 1.0]],
    "is_ml": false
}
```
:::

### Parameter List

:::tabs

== Explanation
```json
"model_parameters_to_optimize": {
    "approach,parameter_name": "Override settings or null for defaults"
}
```

== Example
```json
"model_parameters_to_optimize": {
    "autoRespiration,RMN": null,
    "autoRespiration,YG": null,
    "cCycleBase,c_τ_LitFast": null
}
```
:::

::: info Parameter Naming

Parameters follow the convention: `${approach},${parameter_name}`

:::

## Optimization Objective

This section configures observational constraints and cost combination methods.

:::tabs

== Explanation
```json
{
    "multi_constraint_method": "Method to combine variable costs",
    "multi_objective_algorithm": "Flag for multi-objective optimization",
    "observational_constraints": ["List of variables for cost calculation"]
}
```

== Example
```json
{
    "multi_constraint_method": "metric_sum",
    "multi_objective_algorithm": false,
    "observational_constraints": ["gpp", "nee", "reco", "transpiration"]
}
```
:::

::: tip Available Methods
- Use `showMethodsOf(SindbadSpatialMetricAggr)` for supported `multi_constraint_method` options
:::

## Observational Constraints

### Default Cost Settings

:::tabs

== Explanation
```json
"default_cost": {
    "aggr_func": "Spatial/temporal aggregation function",
    "aggr_obs": "Flag for observational data aggregation",
    "aggr_order": "Aggregation order (time_space or space_time)",
    "cost_metric": "Cost calculation method",
    "cost_weight": "Variable weight in cost calculation",
    "min_data_points": "Minimum valid data points required",
    "spatial_data_aggr": "Spatial data aggregation method",
    "spatial_cost_aggr": "Spatial cost aggregation method",
    "spatial_weight": "Enable area-based weighting",
    "temporal_data_aggr": "Temporal aggregation method"
}
```

== Example
```json
"default_cost": {
    "aggr_func": "nanmean",
    "aggr_obs": false,
    "aggr_order": "time_space",
    "cost_metric": "NNSE_inv",
    "cost_weight": 1.0,
    "min_data_points": 1,
    "spatial_data_aggr": "concat_data",
    "spatial_cost_aggr": "metric_spatial",
    "spatial_weight": false,
    "temporal_data_aggr": "day"
}
```
:::

### Data Quality Settings

:::tabs

== Explanation
```json
{
    "use_quality_flag": "Apply data quality flags",
    "use_spatial_weight": "Apply spatial area weights",
    "use_uncertainty": "Consider data uncertainty"
}
```

== Example
```json
{
    "use_quality_flag": true,
    "use_spatial_weight": false,
    "use_uncertainty": false
}
```
:::

::: tip Available Methods
- Use `showMethodsOf(SindbadMetric)` for cost metrics
- Use `showMethodsOf(SindbadSpatialMetricAggr)` for spatial aggregation
- Use `showMethodsOf(SindbadTimeAggregator)` for temporal methods
:::

### Default Observation Settings

:::tabs

== Explanation
```json
"default_observation": {
    "additive_unit_conversion": "Additive (true) or multiplicative (false) unit conversion",
    "bounds": "Valid data range after conversion",
    "data_path": "Path to observation data file",
    "is_categorical": "Flag for categorical data",
    "standard_name": "Descriptive variable name",
    "sindbad_unit": "Unit used within SINDBAD",
    "source_product": "Data source identifier",
    "source_to_sindbad_unit": "Unit conversion factor",
    "source_unit": "Original data unit",
    "source_variable": "Variable name in source file",
    "space_time_type": "Data type classification"
}
```

== Example
```json
"default_observation": {
    "additive_unit_conversion": false,
    "bounds": [0, 100],
    "data_path": "../data/observations.nc",
    "is_categorical": false,
    "standard_name": "GPP",
    "sindbad_unit": "gC/m²/day",
    "source_product": "FLUXNET",
    "source_to_sindbad_unit": 1.0,
    "source_unit": "gC/m²/day",
    "source_variable": "GPP_NT_VUT_REF",
    "space_time_type": "spatiotemporal"
}
```
:::

::: warning Data Handling
- Values outside bounds are replaced with NaN/missing
- Unit conversions are applied during data processing
- Ensure data paths are accessible from the experiment environment
:::
