## Optimization 

In the settings file contains information on the optimization, such as the optimization scheme, the parameters to be optimized, a list of observational constraints and a function to read them, etc. 

### Optimization algorithm
:::tabs

== Explanation
````json
{
  "algorithm": a string with name of the optimization algorithm or a path to a json file with the information,
}
````
== Example
````json
{
"algorithm": "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
}
````
:::

The algorithm sets the optimization scheme to use for calibrating parameters. Its value can either be a name of the algorithm or a path to a ```.json``` file that includes the specific options of the algorithm.

An example of the json file is

:::tabs

== Explanation
````json
{
  "method": the optimization method,
  "options": {
    "maxfevals": maximum functional evaluations,
    "multi_threading": flag to use multithreading in optimization, which is only supported by some packages
  },
  "package": the source package of optimization
}
````
== Example
````json
{
  "method": "CMAES",
  "options": {
    "maxfevals": 1000,
    "multi_threading": false
  },
  "package": "CMAEvolutionStrategy"
}
````
:::

::: warning

that same method can be available through different packages and hence both are required. In the ```options``` field, one can freely set all the options for a given method of a given package.

:::

Internally, the algorithm settings are parsed and optimization settings are defined as different types in SINDBAD under SindbadOptimizationMethod. Convention is ```${package}${method}```. So, the type implementing the optimization from the above settings would be ```CMAEvolutionStrategyCMAES```. And setting that value as ```CMAEvolutionStrategyCMAES``` in algorithm would run the same method with the default option. So, essentially, the ```.json``` method is to allow for over-riding of default options of an implemented method.

````json
{
"algorithm": "CMAEvolutionStrategyCMAES",
}
````

::: tip

To list all the implemented methods, use

````julia
julia> using SindbadOptimization
julia> subtypes(SindbadOptimizationMethod)
````
:::

### Optimization parameters
This section defines the default properties of optimization parameters and list all the parameters that will be optimized.

By default all parameters have a normal ```distribution``` and are not optimized by machine learning methods (```is_ml``` = false) in ```hybrid``` settings.

:::tabs

== Explanation
````json
  "model_parameter_default": {
    "distribution": [name of the distribution, a vector with parameters of the distribution],
    "is_ml": flag to identify machine-learned parameters
  },
  "model_parameters_to_optimize": {
    "autoRespiration,RMN": information to override default parameter setting or null
  },
````
== Example
````json
"model_parameter_default": {
    "distribution": ["normal", [0.0, 1.0]],
    "is_ml": false
  },
"model_parameters_to_optimize": {
    "autoRespiration,RMN": null,
    "autoRespiration,YG": null,
    "autoRespirationAirT,Q10": null,
    "cCycleBase,c_remain": null,
    "cCycleBase,c_τ_LitFast": null,
    "cCycleBase,c_τ_LitSlow": null,
    "cCycleBase,c_τ_Root": null,
    "cCycleBase,c_τ_SoilOld": null,
    "cCycleBase,c_τ_SoilSlow": null,
    "cCycleBase,c_τ_Wood": null,
    "cCycleBase,ηH": null,
    "cFlow,f_τ": null,
    "cFlow,k_shedding": null,
    "cFlow,slope_leaf_root_to_reserve": null,
    "cFlow,slope_reserve_to_leaf_root": null,
    "cTauSoilT,Q10": null
}
````
:::

Under ```model_parameters_to_optimize```, there can be a list of parameters or a dictionary with parameter as the key and the ```distribution``` and ```is_ml``` values to allow for different setting for different parameter. ```null``` indicates that the default parameter properties are used. Each parameter/key should follow a convention of ```${approach},${parameter_name}``` that matches a given model parameter. 


### Optimization objective
In this section, options related to observational variables/constraint, and how cost of each variable is combined are set.

:::tabs

== Explanation
````json
{
"multi_constraint_method": how to combine cost of each variable, e.g., by doing sum as "metric_sum",
"observational_constraints": a list of variables under "variables" which are used during cost calculation,
],
}
````
== Example
````json
{
"multi_constraint_method": "metric_sum",
"multi_objective_algorithm": false,
"observational_constraints": ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi"]
}
````
:::

::: tip

check ```subtypes(SindbadSpatialCostAggr)``` for a list of all supported ```multi_constraint_method```.

:::

### Observational Constraints
Under "observations" section, configuration related to cost metric for each observation variable and how they are used during optimization are set.

#### Cost Metric
First, the default cost metric is set to avoid duplication and set common configuration across all variables.

:::tabs

== Explanation
````json
"default_cost": {
    "aggr_func": function/method to aggregate the data in space or time, e.g., "nanmean",
    "aggr_obs": flag to indicate if the observational data has to be aggregated on the go before calculating the cost,
    "aggr_order": order of aggregating data, e.g. "time_space" for aggregating in time before that in space,
    "cost_metric": name of cost metric, e.g., "NNSE_inv",
    "cost_weight": numeric weight of the cost of a given variable,
    "min_data_points": minimum number of valid data points for calculation of cost for a variable,
    "spatial_data_aggr": method to aggregate data in space , e.g. "concat_data" for concatenating the data in space,
    "spatial_cost_aggr": method to aggregate cost in multiple pixels/grids were evaluated as once, e.g., "metric_spatial"means returning a cost per pixel,
    "spatial_weight": if the cost were to be weighted by grid area,
    "temporal_data_aggr": function to temporally aggregate and subset data
},
````
== Example
````json
{
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
}
````
:::

::: tip

- to list all the cost metrics available in SINDBAD, use ```subtypes(SindbadMetric)```
- to list all the spatial cost aggregation available in SINDBAD, use ```subtypes(SindbadSpatialCostAggr)```
- to list all the temporal aggregation and subsetting method, use ```subtypes(SindbadTimeAggregator)```

:::

#### Data quality and uncertainty
These are overall settings to use or not use key data aspects such as quality flag, uncertainty, and area weights while calculating the cost metric.


:::tabs

== Explanation
````json
{
"use_quality_flag": a flag to indicate if the data quality flag should be applied before calculating a cost metric,
"use_spatial_weight": a flag indicating if the spatial weight for area should be applied for data before calculating a cost metric. This option is not fully implemented yet.,
"use_uncertainty": a flag to indicate if the data uncertainty should be applied while calculating a cost metric, which supports it,
}
````
== Example
````json
{
"use_quality_flag": true,
"use_spatial_weight": false,
"use_uncertainty": false
}
````
:::

#### Observational variables
In this section, information related to each observation constraint/variable are set.

First, the default settings for all variables are set. Note that these can be overwritten per variable in individual settings for the variables.

:::tabs

== Explanation
````json
"default_observation": {
    "additive_unit_conversion": a flag to indicated if the unit conversion is additive. If true, the unit conversion factor is added to the data, if false, it is multiplied.,
    "bounds": a list of two numbers indicating the viable bounds of data after unit conversion, e.g., [0, 100] for a variable. Note that the data outside bounds are replaced by a NaN/missing for the observational data,
    "data_path": path to the data file, e.g., "../data/BE-Vie.1979.2017.daily.nc". Note that the path can be absolute or relative to the base Julia environment of a given experiment,
    "is_categorical": flag to indicate if the data is categorical variable,
    "standard_name": a metadata used to identify variable and improve clarity. Note that it is not used in data processing and calculation.,
    "sindbad_unit": a metadata used to identify variable units within SINDBAD and improve clarity. Note that it is not used in data processing and calculation.,
    "source_product": a metadata used to identify data source and improve clarity. Note that it is not used in data processing and calculation, e.g., "FLUXNET",
    "source_to_sindbad_unit": a numerical value used for unit conversion of the variable on the go,
    "source_unit": a metadata used to identify variable units in the source data and improve clarity. Note that it is not used in data processing and calculation.,
    "source_variable": a string variable name in the data file. Note that SINDBAD variable names are the keys listed under variables,
    "space_time_type": a string indicating the data type , e.g., "spatiotemporal" for data with time and space dimensions
},
````
== Example
````json
"default_observation": {
    "additive_unit_conversion": false,
    "bounds": null,
    "data_path": "../data/BE-Vie.1979.2017.daily.nc",
    "is_categorical": false,
    "standard_name": null,
    "sindbad_unit": null,
    "source_product": "",
    "source_to_sindbad_unit": 1.0,
    "source_unit": null,
    "source_variable": null,
    "space_time_type": "spatiotemporal"
}
````
:::

Now, information for each variable are set under the ```variables``` section. Only the options that are different from ```default_variable``` and  ```default_cost``` are set here. This helps reducing the redundancy and potential inconsistency of the settings.

:::tabs

== Explanation
````json
"evapotranspiration": {
    "cost_options": {
        "cost_metric": the name of the cost metric to be calculated for the variable, e.g., "NNSE_inv"
    },
    "data": set the information of the actual data variable {
        "bounds": see default_observation,
        "is_categorical": see default_observation,
        "standard_name": see default_observation,
        "sindbad_unit": see default_observation,
        "source_to_sindbad_unit": see default_observation,
        "source_unit": see default_observation,
        "source_variable": see default_observation
    },
    "model_full_var": the field and subfield of land that is used to compare against the observation, e.g., "fluxes.evapotranspiration". Note that the convention of $field.$subfield should be strictly followed.,
    "qflag": set the information of the variable used for quality flag. A source_variable of null means a quality flag of 1 will be used, which means all data have highest quality and will be used in calculating cost. {
        "bounds": bounds of the acceptable range of quality flag,
        "data_path": path to the quality flag data,
        "source_variable": source variable name for quality flag data
    },
    "unc": set the information of the variable used for uncertainty. A source_variable of null means an unc of 1 will be used which means no effect on cost. {
        "bounds": bounds of the data uncertainty variable,
        "data_path": path to the data of uncertainty,
        "source_to_sindbad_unit": unit conversion factor for uncertainty variable,
        "source_variable": source variable name for data uncertainty
    }
````
== Example
````json
{
"variables": {
    "agb": {
    "cost_options": {
        "cost_metric": "NMAE1R"
    },
    "data": {
        "bounds": [0.0, 100000.0],
        "standard_name": "Above-ground biomass",
        "sindbad_unit": "gC m-2",
        "source_unit": "gC m-2",
        "source_variable": "agb_merged_PFT"
    },
    "model_full_var": "states.aboveground_biomass"
    },
    "evapotranspiration": {
    "cost_options": {
        "cost_metric": "NNSE_inv"
    },
    "data": {
        "bounds": [0.0, 100.0],
        "is_categorical": false,
        "standard_name": "Evapotranspiration",
        "sindbad_unit": "mm day-1",
        "source_to_sindbad_unit": 0.4081632653,
        "source_unit": "MJ m-2 d-1",
        "source_variable": "LE"
    },
    "model_full_var": "fluxes.evapotranspiration",
    "qflag": {
        "bounds": [0.85, 1.0],
        "data_path": null,
        "source_variable": "LE_QC_merged"
    },
    "unc": {
        "bounds": [0.0, 100.0],
        "data_path": null,
        "source_to_sindbad_unit": 0.4081632653,
        "source_variable": "LE_RANDUNC"
    }
    }
}
````
:::
