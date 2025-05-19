<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup' href='#SindbadSetup'><span class="jlbinding">SindbadSetup</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



SindbadSetup

The `SindbadSetup` package provides tools for setting up and configuring SINDBAD experiments and runs. It handles the creation of experiment configurations, model structures, parameters, and output setups, ensuring a streamlined workflow for SINDBAD simulations.

**Purpose:**

This package is designed to produce the SINDBAD `info` object, which contains all the necessary configurations and metadata for running SINDBAD experiments. It facilitates reading configurations, building model structures, and preparing outputs.

**Dependencies:**
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `SindbadUtils`: Supplies utility functions for handling data and other helper tasks during the setup process.
  
- `ConstructionBase`: Provides a base type for constructing types, enabling the creation of custom types for SINDBAD experiments.
  
- `CSV`: Provides tools for reading and writing CSV files, commonly used for input and output data in SINDBAD experiments.
  
- `Infiltrator`: Enables interactive debugging during the setup process, improving development and troubleshooting.
  
- `JSON`: Provides tools for parsing and generating JSON files, commonly used for configuration files.
  
- `JLD2`: Facilitates saving and loading SINDBAD configurations and outputs in a binary format for efficient storage and retrieval.
  

**Included Files:**
1. **`defaultOptions.jl`**:
  - Defines default configuration options for various optimization and global sensitivity analysis methods in SINDBAD.
    
  
2. **`getConfiguration.jl`**:
  - Contains functions for reading and parsing configuration files (e.g., JSON or CSV) to initialize SINDBAD experiments.
    
  
3. **`setupExperimentInfo.jl`**:
  - Builds the `info` object, which contains all the metadata and configurations required for running SINDBAD experiments.
    
  
4. **`setupTypes.jl`**:
  - Defines instances of data types in SINDBAD after reading the information from settings files.
    
  
5. **`setupPools.jl`**:
  - Handles the initialization of SINDBAD land by creating model pools, including state variables.
    
  
6. **`updateParameters.jl`**:
  - Implements logic for updating model parameters based on metric evaluations, enabling iterative model calibration.
    
  
7. **`setupParameters.jl`**:
  - Manages the loading and setup of model parameters, including bounds, scaling, and initial values.
    
  
8. **`setupModels.jl`**:
  - Constructs the model structure, including the selection and configuration of orders SINDBAD models.
    
  
9. **`setupOutput.jl`**:
  - Prepares the output structure for SINDBAD experiments.
    
  
10. **`setupOptimization.jl`**:
  - Configures optimization settings for parameter estimation and model calibration.
    
  
11. **`setupInfo.jl`**:
  - Calls various functions to collect the `info` object by integrating all configurations, models, parameters, and outputs.
    
  

**Notes:**
- The package re-exports several key packages (`Infiltrator`, `CSV`, `JLD2`) for convenience, allowing users to access their functionality directly through `SindbadSetup`.
  
- Designed to be modular and extensible, enabling users to customize and expand the setup process for specific use cases.
  

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.backScaleParameters' href='#SindbadSetup.backScaleParameters'><span class="jlbinding">SindbadSetup.backScaleParameters</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
backScaleParameters(parameter_vector_scaled, parameter_table, <: ParameterScaling)
```


Reverts scaling of parameters using a specified scaling strategy.

**Arguments**
- `parameter_vector_scaled`: Vector of scaled parameters to be converted back to original scale
  
- `parameter_table`: Table containing parameter information and scaling factors
  
- `ParameterScaling`: Type indicating the scaling strategy to be used
  - `::ScaleDefault`: Type indicating scaling by initial parameter values
    
  - `::ScaleBounds`: Type indicating scaling by parameter bounds
    
  - `::ScaleNone`: Type indicating no scaling should be applied (parameters remain unchanged)
    
  

**Returns**

Returns the unscaled/actual parameter vector in original units.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.checkParameterBounds-Tuple{Any, Any, Any, Any, ParameterScaling}' href='#SindbadSetup.checkParameterBounds-Tuple{Any, Any, Any, Any, ParameterScaling}'><span class="jlbinding">SindbadSetup.checkParameterBounds</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
checkParameterBounds(p_names, parameter_values, lower_bounds, upper_bounds, _sc::ParameterScaling; show_info=false, model_names=nothing)
```


Check and display the parameter bounds information for given parameters.

**Arguments**
- `p_names`: Names or identifier of the parameters. Vector of strings.
  
- `parameter_values`: Default values of the parameters. Vector of Numbers.
  
- `lower_bounds`: Lower bounds for the parameters. Vector of Numbers.
  
- `upper_bounds`: Upper bounds for the parameters. Vector of Numbers.
  
- `_sc::ParameterScaling`: Scaling Type for the parameters
  
- `show_info`: a flag to display model parameters and their bounds. Boolean.
  
- `model_names`: Names or identifier of the approaches where the parameters are defined.
  

**Returns**

Displays a formatted output of parameter bounds information or returns an error when they are violated

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.convertRunFlagsToTypes-Tuple{Any}' href='#SindbadSetup.convertRunFlagsToTypes-Tuple{Any}'><span class="jlbinding">SindbadSetup.convertRunFlagsToTypes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
convertRunFlagsToTypes(info)
```


Converts model run-related flags from the experiment configuration into types for dispatch.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration, including model run flags.
  

**Returns:**
- A NamedTuple `new_run` where each flag is converted into a corresponding type instance.
  

**Notes:**
- Flags are processed recursively:
  - If a flag is a `NamedTuple`, its subfields are converted into types.
    
  - If a flag is a scalar, it is directly converted into a type using `getTypeInstanceForFlags`.
    
  
- The resulting `new_run` NamedTuple is used for type-based dispatch in SINDBAD&#39;s model execution.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.createArrayofType' href='#SindbadSetup.createArrayofType'><span class="jlbinding">SindbadSetup.createArrayofType</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
createArrayofType(input_values, pool_array, num_type, indx, ismain, array_type::ModelArrayType)
```


Creates an array or view of the specified type `array_type` based on the input values and configuration.

**Arguments:**
- `input_values`: The input data to be converted or used for creating the array.
  
- `pool_array`: A preallocated array from which a view may be created.
  
- `num_type`: The numerical type to which the input values should be converted (e.g., `Float64`, `Int`).
  
- `indx`: A tuple of indices used to create a view from the `pool_array`.
  
- `ismain`: A boolean flag indicating whether the main array should be created (`true`) or a view should be created (`false`).
  
- `array_type`: A type dispatch that determines the array type to be created:
  - `ModelArrayView`: Creates a view of the `pool_array` based on the indices `indx`.
    
  - `ModelArrayArray`: Creates a new array by converting `input_values` to the specified `num_type`.
    
  - `ModelArrayStaticArray`: Creates a static array (`SVector`) from the `input_values`.
    
  

**Returns:**
- An array or view of the specified type, created based on the input configuration.
  

**Notes:**
- When `ismain` is `true`, the function converts `input_values` to the specified `num_type`.
  
- When `ismain` is `false`, the function creates a view of the `pool_array` using the indices `indx`.
  
- For `ModelArrayStaticArray`, the function ensures that the resulting static array (`SVector`) has the correct type and length.
  

**Examples:**
1. **Creating a view from a preallocated array**:
  

```julia
pool_array = rand(10, 10)
indx = (1:5,)
view_array = createArrayofType(nothing, pool_array, Float64, indx, false, ModelArrayView())
```

1. **Creating a new array with a specific numerical type**:
  

```julia
input_values = [1.0, 2.0, 3.0]
new_array = createArrayofType(input_values, nothing, Float64, nothing, true, ModelArrayArray())
```

1. **Creating a static array (`SVector`)**:
  

```julia
input_values = [1.0, 2.0, 3.0]
static_array = createArrayofType(input_values, nothing, Float64, nothing, true, ModelArrayStaticArray())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.createInitLand-Tuple{Any, Any}' href='#SindbadSetup.createInitLand-Tuple{Any, Any}'><span class="jlbinding">SindbadSetup.createInitLand</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
createInitLand(pool_info, tem)
```


Initializes the land state by creating a NamedTuple with pools, states, and selected models.

**Arguments:**
- `pool_info`: Information about the pools to initialize.
  
- `tem`: A helper NamedTuple with necessary objects for pools and numbers.
  

**Returns:**
- A NamedTuple containing initialized pools, states, fluxes, diagnostics, properties, models, and constants.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.createInitPools-Tuple{NamedTuple, NamedTuple}' href='#SindbadSetup.createInitPools-Tuple{NamedTuple, NamedTuple}'><span class="jlbinding">SindbadSetup.createInitPools</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
createInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)
```


Creates a NamedTuple with initial pool variables as subfields, used in `land.pools`.

**Arguments:**
- `info_pools`: A NamedTuple containing pool information from the experiment configuration.
  
- `tem_helpers`: A NamedTuple containing helper information for numerical operations.
  

**Returns:**
- A NamedTuple with initialized pool variables.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.createInitStates-Tuple{NamedTuple, NamedTuple}' href='#SindbadSetup.createInitStates-Tuple{NamedTuple, NamedTuple}'><span class="jlbinding">SindbadSetup.createInitStates</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
createInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)
```


Creates a NamedTuple with initial state variables as subfields, used in `land.states`.

**Arguments:**
- `info_pools`: A NamedTuple containing pool information from the experiment configuration.
  
- `tem_helpers`: A NamedTuple containing helper information for numerical operations.
  

**Returns:**
- A NamedTuple with initialized state variables.
  

**Notes:**
- Extended from `createInitPools``
  
- State variables are derived from the `state_variables` field in `model_structure.json`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.createNestedDict-Tuple{AbstractDict}' href='#SindbadSetup.createNestedDict-Tuple{AbstractDict}'><span class="jlbinding">SindbadSetup.createNestedDict</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
createNestedDict(dict::AbstractDict)
```


Creates a nested dictionary from a flat dictionary where keys are strings separated by dots (`.`).

**Arguments:**
- `dict::AbstractDict`: A flat dictionary with keys as dot-separated strings.
  

**Returns:**
- A nested dictionary where each dot-separated key is converted into nested dictionaries.
  

**Example:**

```julia
dict = Dict("a.b.c" => 2)
nested_dict = createNestedDict(dict)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.deepMerge' href='#SindbadSetup.deepMerge'><span class="jlbinding">SindbadSetup.deepMerge</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
deepMerge(d::AbstractDict...) = merge(deepMerge, d...)
deepMerge(d...) = d[end]
```


Recursively merges multiple dictionaries, giving priority to the last dictionary.

**Arguments:**
- `d::AbstractDict...`: One or more dictionaries to merge.
  

**Returns:**
- A single dictionary with merged fields, where the last dictionary&#39;s values take precedence.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.filterParameterTable-Tuple{Table}' href='#SindbadSetup.filterParameterTable-Tuple{Table}'><span class="jlbinding">SindbadSetup.filterParameterTable</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
filterParameterTable(parameter_table::Table; prop_name::Symbol=:model, prop_values::Tuple{Symbol}=(:all,))
```


Filters a parameter table based on a specified property and values.

**Arguments**
- `parameter_table::Table`: The parameter table to filter
  
- `prop_name::Symbol`: The property to filter by (default: :model)
  
- `prop_values::Tuple{Symbol}`: The values to filter by (default: :all)
  

**Returns**

A filtered parameter table.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getConfiguration-Tuple{String}' href='#SindbadSetup.getConfiguration-Tuple{String}'><span class="jlbinding">SindbadSetup.getConfiguration</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getConfiguration(sindbad_experiment::String; replace_info=Dict())
```


Loads the experiment configuration from a JSON or JLD2 file.

**Arguments:**
- `sindbad_experiment::String`: Path to the experiment configuration file.
  
- `replace_info::Dict`: A dictionary of fields to replace in the configuration.
  

**Returns:**
- A NamedTuple containing the experiment configuration.
  

**Notes:**
- Supports both JSON and JLD2 formats.
  
- If `replace_info` is provided, the specified fields are replaced in the configuration.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getConstraintNames-Tuple{NamedTuple}' href='#SindbadSetup.getConstraintNames-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.getConstraintNames</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getConstraintNames(optim::NamedTuple)
```


Extracts observation and model variable names for optimization constraints.

**Arguments:**
- `optim`: A NamedTuple containing optimization settings and observation constraints.
  

**Returns:**
- A tuple containing:
  - `obs_vars`: A list of observation variables used to calculate cost.
    
  - `optim_vars`: A lookup mapping observation variables to model variables.
    
  - `store_vars`: A lookup of model variables for which time series will be stored.
    
  - `model_vars`: A list of model variable names.
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getCostOptions-Tuple{NamedTuple, Vararg{Any, 4}}' href='#SindbadSetup.getCostOptions-Tuple{NamedTuple, Vararg{Any, 4}}'><span class="jlbinding">SindbadSetup.getCostOptions</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getCostOptions(optim_info::NamedTuple, vars_info, tem_variables, number_helpers, dates_helpers)
```


Sets up cost optimization options based on the provided parameters.

**Arguments:**
- `optim_info`: A NamedTuple containing optimization parameters and settings.
  
- `vars_info`: Information about variables used in optimization.
  
- `tem_variables`: Template variables for optimization setup.
  
- `number_helpers`: Helper functions or values for numerical operations.
  
- `dates_helpers`: Helper functions or values for date-related operations.
  

**Returns:**
- A NamedTuple containing cost optimization configuration options.
  

**Notes:**
- Configures temporal and spatial aggregation, cost metrics, and other optimization-related settings.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getDepthDimensionSizeName-Tuple{Any, NamedTuple}' href='#SindbadSetup.getDepthDimensionSizeName-Tuple{Any, NamedTuple}'><span class="jlbinding">SindbadSetup.getDepthDimensionSizeName</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getDepthDimensionSizeName(vname::Symbol, info::NamedTuple)
```


Retrieves the name and size of the depth dimension for a given variable.

**Arguments:**
- `vname`: The variable name.
  
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  

**Returns:**
- A tuple containing the size and name of the depth dimension.
  

**Notes:**
- Validates the depth dimension against the `depth_dimensions` field in the experiment configuration.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getDepthInfoAndVariables-Tuple{Any, Any}' href='#SindbadSetup.getDepthInfoAndVariables-Tuple{Any, Any}'><span class="jlbinding">SindbadSetup.getDepthInfoAndVariables</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getDepthInfoAndVariables(info, output_vars)
```


Generates depth information and variable pairs for the output variables.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing experiment configuration.
  
- `output_vars`: A list of output variables.
  

**Returns:**
- A NamedTuple containing depth information and variable pairs.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getExperimentConfiguration-Tuple{String}' href='#SindbadSetup.getExperimentConfiguration-Tuple{String}'><span class="jlbinding">SindbadSetup.getExperimentConfiguration</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getExperimentConfiguration(experiment_json::String; replace_info=Dict())
```


Loads the basic configuration from an experiment JSON file.

**Arguments:**
- `experiment_json::String`: Path to the experiment JSON file.
  
- `replace_info::Dict`: A dictionary of fields to replace in the configuration.
  

**Returns:**
- A dictionary containing the experiment configuration.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getExperimentInfo-Tuple{String}' href='#SindbadSetup.getExperimentInfo-Tuple{String}'><span class="jlbinding">SindbadSetup.getExperimentInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getExperimentInfo(sindbad_experiment::String; replace_info=Dict())
```


Loads and sets up the experiment configuration, saving the information and enabling debugging options if specified.

**Arguments:**
- `sindbad_experiment::String`: Path to the experiment configuration file.
  
- `replace_info::Dict`: (Optional) A dictionary of fields to replace in the configuration.
  

**Returns:**
- A NamedTuple `info` containing the fully loaded and configured experiment information.
  

**Notes:**
- The function performs the following steps:
  1. Loads the experiment configuration using `getConfiguration`.
    
  2. Sets up the experiment `info` using `setupInfo`.
    
  3. Saves the experiment `info` if `save_info` is enabled.
    
  4. Sets up a debug error catcher if `catch_model_errors` is enabled.
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getGlobalAttributesForOutCubes-Tuple{Any}' href='#SindbadSetup.getGlobalAttributesForOutCubes-Tuple{Any}'><span class="jlbinding">SindbadSetup.getGlobalAttributesForOutCubes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getGlobalAttributesForOutCubes(info)
```


Generates global attributes for output cubes, including system and experiment metadata.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- A dictionary `global_attr` containing global attributes such as:
  - `simulation_by`: The user running the simulation.
    
  - `experiment`: The name of the experiment.
    
  - `domain`: The domain of the experiment.
    
  - `date`: The current date.
    
  - `machine`: The machine architecture.
    
  - `os`: The operating system.
    
  - `host`: The hostname of the machine.
    
  - `julia`: The Julia version.
    
  

**Notes:**
- The function collects system information using Julia&#39;s `Sys` module and `versioninfo`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getNumberType' href='#SindbadSetup.getNumberType'><span class="jlbinding">SindbadSetup.getNumberType</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getNumberType(t)
```


Retrieves the numerical type based on the input, which can be a string or a data type.

**Arguments:**
- `t`: The input specifying the numerical type. Can be:
  - A `String` representing the type (e.g., `"Float64"`, `"Int"`).
    
  - A `DataType` directly specifying the type (e.g., `Float64`, `Int`).
    
  

**Returns:**
- The corresponding numerical type as a `DataType`.
  

**Notes:**
- If the input is a string, it is parsed and evaluated to return the corresponding type.
  
- If the input is already a `DataType`, it is returned as-is.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getOptimizationParametersTable-Tuple{Table, Any, Any}' href='#SindbadSetup.getOptimizationParametersTable-Tuple{Table, Any, Any}'><span class="jlbinding">SindbadSetup.getOptimizationParametersTable</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getOptimizationParametersTable(parameter_table_all::Table, model_parameter_default, optimization_parameters)
```


Creates a filtered and enhanced parameter table for optimization by combining input parameters with default model parameters with the table of all parameters in the selected model structure.

**Arguments**
- `parameter_table_all::Table`: A table containing all model parameters
  
- `model_parameter_default`: Default parameter settings including distribution and a flag differentiating if the parameter is to be ML-parameter-learnt
  
- `optimization_parameters`: Parameters to be optimized, specified either as:
  - `::NamedTuple`: Named tuple with parameter configurations
    
  - `::Vector`: Vector of parameter names to use with default settings
    
  

**Returns**

A filtered `Table` containing only the optimization parameters, enhanced with:
- `is_ml`: Boolean flag indicating if parameter uses machine learning
  
- `dist`: Distribution type for each parameter
  
- `p_dist`: Distribution parameters as an array of numeric values
  

**Notes**
- Parameters can be specified using comma-separated strings for model.parameter pairs
  
- For NamedTuple inputs, individual parameter configurations override model_parameter_default
  
- The output table preserves the numeric type of the input parameters
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getParameters' href='#SindbadSetup.getParameters'><span class="jlbinding">SindbadSetup.getParameters</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getParameters(selected_models::Tuple, num_type, model_timestep; return_table=true)
getParameters(selected_models::LongTuple, num_type, model_timestep; return_table=true)
```


Retrieves parameters for the specified models with given numerical type and timestep settings. 

**Arguments**
- `selected_models`: A collection of selected models
  - `::Tuple`: as a tuple 
    
  - `::LongTuple`: as a long tuple
    
  
- `num_type`: The numerical type to be used for parameters
  
- `model_timestep`: The timestep setting for the model simulation
  
- `return_table::Bool=true`: Whether to return results in table format
  

**Returns**

Parameters information for the selected models based on the specified settings.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getSpinupSequenceWithTypes-Tuple{Any, Any}' href='#SindbadSetup.getSpinupSequenceWithTypes-Tuple{Any, Any}'><span class="jlbinding">SindbadSetup.getSpinupSequenceWithTypes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupSequenceWithTypes(seqq, helpers_dates)
```


Processes the spinup sequence and assigns types for temporal aggregators for spinup forcing.

**Arguments:**
- `seqq`: The spinup sequence from the experiment configuration.
  
- `helpers_dates`: A NamedTuple containing date-related helpers.
  

**Returns:**
- A processed spinup sequence with forcing types for temporal aggregators.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getTypeInstanceForCostMetric-Tuple{String}' href='#SindbadSetup.getTypeInstanceForCostMetric-Tuple{String}'><span class="jlbinding">SindbadSetup.getTypeInstanceForCostMetric</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTypeInstanceForCostMetric(mode_name::String)
```


Retrieves the type instance for a given cost metric based on its name.

**Arguments:**
- `mode_name::String`: The name of the cost metric (e.g., `"RMSE"`, `"MAE"`).
  

**Returns:**
- An instance of the corresponding cost metric type.
  

**Notes:**
- The function converts the cost metric name to a type by capitalizing the first letter of each word and removing underscores.
  
- The type is retrieved from the `SindbadMetrics` module and instantiated.
  
- Used for dispatching cost metric calculations in SINDBAD.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getTypeInstanceForFlags' href='#SindbadSetup.getTypeInstanceForFlags'><span class="jlbinding">SindbadSetup.getTypeInstanceForFlags</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getTypeInstanceForFlags(option_name::Symbol, option_value, opt_pref="Do")
```


Generates a type instance for boolean flags based on the flag name and value.

**Arguments:**
- `option_name::Symbol`: The name of the flag (e.g., `:run_optimization`, `:save_info`).
  
- `option_value`: A boolean value (`true` or `false`) indicating the state of the flag.
  
- `opt_pref::String`: (Optional) A prefix for the type name. Defaults to `"Do"`.
  

**Returns:**
- An instance of the corresponding type:
  - If `option_value` is `true`, the type name is prefixed with `opt_pref` (e.g., `DoRunOptimization`).
    
  - If `option_value` is `false`, the type name is prefixed with `opt_pref * "Not"` (e.g., `DoNotRunOptimization`).
    
  

**Notes:**
- The function converts the flag name to a string, capitalizes the first letter of each word, and appends the appropriate prefix (`Do` or `DoNot`).
  
- The resulting type is retrieved from the `SindbadSetup` module and instantiated.
  
- This is used for type-based dispatch in SINDBAD&#39;s model execution.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getTypeInstanceForNamedOptions' href='#SindbadSetup.getTypeInstanceForNamedOptions'><span class="jlbinding">SindbadSetup.getTypeInstanceForNamedOptions</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getTypeInstanceForNamedOptions(option_name)
```


Retrieves a type instance for a named option based on its string or symbol representation. These options are mainly within the optimization and temporal aggregation.

**Arguments:**
- `option_name`: The name of the option, provided as either a `String` or a `Symbol`.
  

**Returns:**
- An instance of the corresponding type from the `SindbadSetup` module.
  

**Notes:**
- If the input is a `Symbol`, it is converted to a `String` before processing.
  
- The function capitalizes the first letter of each word in the option name and removes underscores to match the type naming convention.
  
- This is used for type-based dispatch in SINDBAD&#39;s configuration and execution.
  
- The type for temporal aggregation is set using `getTimeAggregatorTypeInstance` in `SindbadUtils`. It uses a similar approach and prefixes `Time` to type.
  

**Example:**
- A named option for 
  - &quot;cost_metric&quot;: &quot;NSE_inv&quot; would be converted to NSEInv type
    
  - &quot;temporal_data_aggr&quot;: &quot;month_anomaly&quot; would be converted to MonthAnomaly
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.perturbParameters-Tuple{AbstractVector, AbstractVector, AbstractVector}' href='#SindbadSetup.perturbParameters-Tuple{AbstractVector, AbstractVector, AbstractVector}'><span class="jlbinding">SindbadSetup.perturbParameters</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
perturbParameters(x::AbstractVector, lower::AbstractVector, upper::AbstractVector, percent_range::Tuple{Float64,Float64}=(0.0, 0.1))
```


Modify each element of vector `x` by a random percentage within `percent_range`, while ensuring the result stays within the bounds defined by `lower` and `upper` vectors.

**Arguments**
- `x`: Vector to modify
  
- `lower`: Vector of lower bounds
  
- `upper`: Vector of upper bounds
  
- `percent_range`: Tuple of (min_percent, max_percent) for random modification (default: (0.0, 0.1))
  

**Returns**
- Modified vector `x` (modified in-place)
  

**Example**

```julia
x = [1.0, 2.0, 3.0]
lower = [0.5, 1.5, 2.5]
upper = [1.5, 2.5, 3.5]
modify_within_bounds!(x, lower, upper, (0.0, 0.1))  # Modify by 0-10%
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.readConfiguration-Tuple{AbstractDict, String}' href='#SindbadSetup.readConfiguration-Tuple{AbstractDict, String}'><span class="jlbinding">SindbadSetup.readConfiguration</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
readConfiguration(info_exp::AbstractDict, base_path::String)
```


Reads the experiment configuration files (JSON or CSV) and returns a dictionary.

**Arguments:**
- `info_exp::AbstractDict`: The experiment configuration dictionary.
  
- `base_path::String`: The base path for resolving relative file paths.
  

**Returns:**
- A dictionary containing the parsed configuration files.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.scaleParameters' href='#SindbadSetup.scaleParameters'><span class="jlbinding">SindbadSetup.scaleParameters</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
scaleParameters(parameter_table, <: ParameterScaling)
```


Scale parameters from the input table using default scaling factors.

**Arguments**
- `parameter_table`: Table containing parameters to be scaled
  
- `ParameterScaling`: Type indicating the scaling strategy to be used
  - `::ScaleDefault`: Type indicating scaling by default values
    
  - `::ScaleBounds`: Type parameter indicating scaling by parameter bounds 
    
  - `::ScaleNone`: Type parameter indicating no scaling should be applied
    
  

**Returns**

Scaled parameters and their bounds according to default scaling factors

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setModelOutput-Tuple{NamedTuple}' href='#SindbadSetup.setModelOutput-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setModelOutput</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setModelOutput(info::NamedTuple)
```


Sets the output variables to be written and stored based on the experiment configuration.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with output variables and depth information added.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setModelOutputLandAll-Tuple{Any, Any}' href='#SindbadSetup.setModelOutputLandAll-Tuple{Any, Any}'><span class="jlbinding">SindbadSetup.setModelOutputLandAll</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setModelOutputLandAll(info, land)
```


Retrieves all model variables from `land` and overwrites the output information in `info`.

**Arguments:**
- `info`: A NamedTuple containing experiment configuration and helper information.
  
- `land`: A core SINDBAD NamedTuple containing variables for a given time step.
  

**Returns:**
- The updated `info` NamedTuple with output variables and depth information updated.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setOptimization-Tuple{NamedTuple}' href='#SindbadSetup.setOptimization-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setOptimization</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setOptimization(info::NamedTuple)
```


Sets up optimization-related fields in the experiment configuration.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with optimization-related fields added.
  

**Notes:**
- Configures cost metrics, optimization parameters, algorithms, and variables to store during optimization.
  
- Validates the parameters to be optimized against the model structure.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setOrderedSelectedModels-Tuple{NamedTuple}' href='#SindbadSetup.setOrderedSelectedModels-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setOrderedSelectedModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setOrderedSelectedModels(info::NamedTuple)
```


Retrieves and orders the list of selected models based on the configuration in `model_structure.json`.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with the ordered list of selected models added to `info.temp.models`.
  

**Notes:**
- Ensures consistency by validating the selected models using `checkSelectedModels`.
  
- Orders the models as specified in `standard_sindbad_models`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setPoolsInfo-Tuple{NamedTuple}' href='#SindbadSetup.setPoolsInfo-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setPoolsInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setPoolsInfo(info::NamedTuple)
```


Generates `info.temp.helpers.pools` and `info.pools`. 

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with pool-related fields added.
  

**Notes:**
- `info.temp.helpers.pools` is used in the models.
  
- `info.pools` is used for instantiating the pools for the initial output tuple.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setSpinupAndForwardModels-Tuple{NamedTuple}' href='#SindbadSetup.setSpinupAndForwardModels-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setSpinupAndForwardModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setSpinupAndForwardModels(info::NamedTuple)
```


Configures the spinup and forward models for the experiment.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with the spinup and forward models added to `info.temp.models`.
  

**Notes:**
- Allows for faster spinup by turning off certain models using the `use_in_spinup` flag in `model_structure.json`.
  
- Ensures that spinup models are a subset of forward models.
  
- Updates model parameters if additional parameter values are provided in the experiment configuration.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setupInfo-Tuple{NamedTuple}' href='#SindbadSetup.setupInfo-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setupInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setupInfo(info::NamedTuple)
```


Processes the experiment configuration and sets up all necessary fields for model simulation.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with all necessary fields for model simulation.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.sindbadDefaultOptions' href='#SindbadSetup.sindbadDefaultOptions'><span class="jlbinding">SindbadSetup.sindbadDefaultOptions</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
sindbadDefaultOptions(::MethodType)
```


Retrieves the default configuration options for a given optimization or sensitivity analysis method in SINDBAD.

**Arguments:**
- `::MethodType`: The method type for which the default options are requested. Supported types include:
  - `OptimizationMethod`: General optimization methods.
    
  - `GSAMethod`: General global sensitivity analysis methods.
    
  - `GSAMorris`: Morris method for global sensitivity analysis.
    
  - `GSASobol`: Sobol method for global sensitivity analysis.
    
  - `GSASobolDM`: Sobol method with derivative-based measures.
    
  

**Returns:**
- A `NamedTuple` containing the default options for the specified method.
  

**Notes:**
- Each method type has its own set of default options, such as the number of trajectories, samples, or design matrix length.
  
- For `GSASobolDM`, the defaults are inherited from `GSASobol`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.updateModelParameters' href='#SindbadSetup.updateModelParameters'><span class="jlbinding">SindbadSetup.updateModelParameters</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
updateModelParameters(parameter_table::Table, selected_models::Tuple, parameter_vector::AbstractArray)
updateModelParameters(parameter_table::Table, selected_models::LongTuple, parameter_vector::AbstractArray)
updateModelParameters(parameter_to_index::NamedTuple, selected_models::Tuple, parameter_vector::AbstractArray)
```


Updates the parameters of SINDBAD models based on the provided parameter vector without mutating the original table of parameters.

**Arguments:**
- `parameter_table::Table`: A table of SINDBAD model parameters selected for optimization. Contains parameter names, bounds, and scaling information.
  
- `selected_models::Tuple`: A tuple of all models selected in the given model structure.
  
- `selected_models::LongTuple`: A long tuple of models, which is converted into a standard tuple for processing.
  
- `parameter_vector::AbstractArray`: A vector of parameter values to update the models.
  
- `parameter_to_index::NamedTuple`: A mapping of parameter indices to model names, used for updating specific parameters in the models.
  

**Returns:**
- A tuple of updated models with their parameters modified according to the provided `parameter_vector`.
  

**Notes:**
- The function supports multiple input formats for `selected_models` (e.g., `LongTuple`, `NamedTuple`) and adapts accordingly.
  
- If `parameter_table` is provided, the function uses it to find and update the relevant parameters for each model.
  
- The `parameter_to_index` variant allows for a more direct mapping of parameters to models, bypassing the need for a parameter table.
  
- The generated function variant (`::Val{p_vals}`) is used for compile-time optimization of parameter updates.
  

**Examples:**
1. **Using `parameter_table` and `selected_models`:**
  

```julia
updated_models = updateModelParameters(parameter_table, selected_models, parameter_vector)
```

1. **Using `parameter_to_index` for direct mapping:**
  

```julia
updated_models = updateModelParameters(parameter_to_index, selected_models, parameter_vector)
```


**Implementation Details:**
- The function iterates over the models in `selected_models` and updates their parameters based on the provided `parameter_vector`.
  
- For each model, it checks if the parameter belongs to the model&#39;s approach (using `parameter_table.model_approach`) and updates the corresponding value.
  
- The `parameter_to_index` variant uses a mapping to directly replace parameter values in the models.
  
- The generated (with @generated) function variant (`::Val{p_vals}`) creates a compile-time optimized update process for specific parameters and models.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.updateModels-NTuple{4, Any}' href='#SindbadSetup.updateModels-NTuple{4, Any}'><span class="jlbinding">SindbadSetup.updateModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
updateModels(parameter_vector, parameter_updater, parameter_scaling_type, selected_models)
```


Updates the parameters of selected models using the provided parameter vector.

**Arguments**
- `parameter_vector`: Vector containing the new parameter values
  
- `parameter_updater`: Function or object that defines how parameters should be updated
  
- `parameter_scaling_type`: Specifies the type of scaling to be applied to parameters
  
- `selected_models`: Collection of models whose parameters need to be updated
  

**Returns**

Updated models with new parameter values

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.updateVariablesToStore-Tuple{NamedTuple}' href='#SindbadSetup.updateVariablesToStore-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.updateVariablesToStore</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
updateVariablesToStore(info::NamedTuple)
```


Updates the output variables to store based on optimization or cost run settings.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with updated output variables.
  

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.AllForwardModels' href='#Sindbad.Types.AllForwardModels'><span class="jlbinding">Sindbad.Types.AllForwardModels</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**AllForwardModels**

Use all forward models for spinup

**Type Hierarchy**

`AllForwardModels <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ArrayTypes' href='#Sindbad.Types.ArrayTypes'><span class="jlbinding">Sindbad.Types.ArrayTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ArrayTypes**

Abstract type for all array types in SINDBAD

**Type Hierarchy**

`ArrayTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `ModelArrayType`: Abstract type for internal model array types in SINDBAD 
  - `ModelArrayArray`: Use standard Julia arrays for model variables 
    
  - `ModelArrayStaticArray`: Use StaticArrays for model variables 
    
  - `ModelArrayView`: Use array views for model variables 
    
  
- `OutputArrayType`: Abstract type for output array types in SINDBAD 
  - `OutputArray`: Use standard Julia arrays for output 
    
  - `OutputMArray`: Use MArray for output 
    
  - `OutputSizedArray`: Use SizedArray for output 
    
  - `OutputYAXArray`: Use YAXArray for output 
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.BackendNetcdf' href='#Sindbad.Types.BackendNetcdf'><span class="jlbinding">Sindbad.Types.BackendNetcdf</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**BackendNetcdf**

Use NetCDF format for input data

**Type Hierarchy**

`BackendNetcdf <: DataFormatBackend <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.BackendZarr' href='#Sindbad.Types.BackendZarr'><span class="jlbinding">Sindbad.Types.BackendZarr</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**BackendZarr**

Use Zarr format for input data

**Type Hierarchy**

`BackendZarr <: DataFormatBackend <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.BayesOptKMaternARD5' href='#Sindbad.Types.BayesOptKMaternARD5'><span class="jlbinding">Sindbad.Types.BayesOptKMaternARD5</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**BayesOptKMaternARD5**

Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl

**Type Hierarchy**

`BayesOptKMaternARD5 <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.CMAEvolutionStrategyCMAES' href='#Sindbad.Types.CMAEvolutionStrategyCMAES'><span class="jlbinding">Sindbad.Types.CMAEvolutionStrategyCMAES</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**CMAEvolutionStrategyCMAES**

Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl

**Type Hierarchy**

`CMAEvolutionStrategyCMAES <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.CostMethod' href='#Sindbad.Types.CostMethod'><span class="jlbinding">Sindbad.Types.CostMethod</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**CostMethod**

Abstract type for cost calculation methods in SINDBAD

**Type Hierarchy**

`CostMethod <: OptimizationTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `CostModelObs`: cost calculation between model output and observations 
  
- `CostModelObsLandTS`: cost calculation between land model output and time series observations 
  
- `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
  
- `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.CostModelObs' href='#Sindbad.Types.CostModelObs'><span class="jlbinding">Sindbad.Types.CostModelObs</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**CostModelObs**

cost calculation between model output and observations

**Type Hierarchy**

`CostModelObs <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.CostModelObsLandTS' href='#Sindbad.Types.CostModelObsLandTS'><span class="jlbinding">Sindbad.Types.CostModelObsLandTS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**CostModelObsLandTS**

cost calculation between land model output and time series observations

**Type Hierarchy**

`CostModelObsLandTS <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.CostModelObsMT' href='#Sindbad.Types.CostModelObsMT'><span class="jlbinding">Sindbad.Types.CostModelObsMT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**CostModelObsMT**

multi-threaded cost calculation between model output and observations

**Type Hierarchy**

`CostModelObsMT <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.CostModelObsPriors' href='#Sindbad.Types.CostModelObsPriors'><span class="jlbinding">Sindbad.Types.CostModelObsPriors</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**CostModelObsPriors**

cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET

**Type Hierarchy**

`CostModelObsPriors <: CostMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DataAggrOrder' href='#Sindbad.Types.DataAggrOrder'><span class="jlbinding">Sindbad.Types.DataAggrOrder</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DataAggrOrder**

Abstract type for data aggregation order in SINDBAD

**Type Hierarchy**

`DataAggrOrder <: MetricTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `SpaceTime`: Aggregate data first over space, then over time 
  
- `TimeSpace`: Aggregate data first over time, then over space 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DataFormatBackend' href='#Sindbad.Types.DataFormatBackend'><span class="jlbinding">Sindbad.Types.DataFormatBackend</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DataFormatBackend**

Abstract type for input data backends in SINDBAD

**Type Hierarchy**

`DataFormatBackend <: InputTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `BackendNetcdf`: Use NetCDF format for input data 
  
- `BackendZarr`: Use Zarr format for input data 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoCalcCost' href='#Sindbad.Types.DoCalcCost'><span class="jlbinding">Sindbad.Types.DoCalcCost</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoCalcCost**

Enable cost calculation between model output and observations

**Type Hierarchy**

`DoCalcCost <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoCatchModelErrors' href='#Sindbad.Types.DoCatchModelErrors'><span class="jlbinding">Sindbad.Types.DoCatchModelErrors</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoCatchModelErrors**

Enable error catching during model execution

**Type Hierarchy**

`DoCatchModelErrors <: ModelTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoDebugModel' href='#Sindbad.Types.DoDebugModel'><span class="jlbinding">Sindbad.Types.DoDebugModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoDebugModel**

Enable model debugging mode

**Type Hierarchy**

`DoDebugModel <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoFilterNanPixels' href='#Sindbad.Types.DoFilterNanPixels'><span class="jlbinding">Sindbad.Types.DoFilterNanPixels</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoFilterNanPixels**

Enable filtering of NaN values in spatial data

**Type Hierarchy**

`DoFilterNanPixels <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoInlineUpdate' href='#Sindbad.Types.DoInlineUpdate'><span class="jlbinding">Sindbad.Types.DoInlineUpdate</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoInlineUpdate**

Enable inline updates of model state

**Type Hierarchy**

`DoInlineUpdate <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotCalcCost' href='#Sindbad.Types.DoNotCalcCost'><span class="jlbinding">Sindbad.Types.DoNotCalcCost</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotCalcCost**

Disable cost calculation between model output and observations

**Type Hierarchy**

`DoNotCalcCost <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotCatchModelErrors' href='#Sindbad.Types.DoNotCatchModelErrors'><span class="jlbinding">Sindbad.Types.DoNotCatchModelErrors</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotCatchModelErrors**

Disable error catching during model execution

**Type Hierarchy**

`DoNotCatchModelErrors <: ModelTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotDebugModel' href='#Sindbad.Types.DoNotDebugModel'><span class="jlbinding">Sindbad.Types.DoNotDebugModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotDebugModel**

Disable model debugging mode

**Type Hierarchy**

`DoNotDebugModel <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotFilterNanPixels' href='#Sindbad.Types.DoNotFilterNanPixels'><span class="jlbinding">Sindbad.Types.DoNotFilterNanPixels</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotFilterNanPixels**

Disable filtering of NaN values in spatial data

**Type Hierarchy**

`DoNotFilterNanPixels <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotInlineUpdate' href='#Sindbad.Types.DoNotInlineUpdate'><span class="jlbinding">Sindbad.Types.DoNotInlineUpdate</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotInlineUpdate**

Disable inline updates of model state

**Type Hierarchy**

`DoNotInlineUpdate <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotOutputAll' href='#Sindbad.Types.DoNotOutputAll'><span class="jlbinding">Sindbad.Types.DoNotOutputAll</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotOutputAll**

Disable output of all model variables

**Type Hierarchy**

`DoNotOutputAll <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotRunForward' href='#Sindbad.Types.DoNotRunForward'><span class="jlbinding">Sindbad.Types.DoNotRunForward</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotRunForward**

Disable forward model run

**Type Hierarchy**

`DoNotRunForward <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotRunOptimization' href='#Sindbad.Types.DoNotRunOptimization'><span class="jlbinding">Sindbad.Types.DoNotRunOptimization</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotRunOptimization**

Disable model parameter optimization

**Type Hierarchy**

`DoNotRunOptimization <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotSaveInfo' href='#Sindbad.Types.DoNotSaveInfo'><span class="jlbinding">Sindbad.Types.DoNotSaveInfo</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotSaveInfo**

Disable saving of model information

**Type Hierarchy**

`DoNotSaveInfo <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotSaveSingleFile' href='#Sindbad.Types.DoNotSaveSingleFile'><span class="jlbinding">Sindbad.Types.DoNotSaveSingleFile</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotSaveSingleFile**

Save output variables in separate files

**Type Hierarchy**

`DoNotSaveSingleFile <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotSpinupTEM' href='#Sindbad.Types.DoNotSpinupTEM'><span class="jlbinding">Sindbad.Types.DoNotSpinupTEM</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotSpinupTEM**

Disable terrestrial ecosystem model spinup

**Type Hierarchy**

`DoNotSpinupTEM <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotStoreSpinup' href='#Sindbad.Types.DoNotStoreSpinup'><span class="jlbinding">Sindbad.Types.DoNotStoreSpinup</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotStoreSpinup**

Disable storing of spinup results

**Type Hierarchy**

`DoNotStoreSpinup <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoNotUseForwardDiff' href='#Sindbad.Types.DoNotUseForwardDiff'><span class="jlbinding">Sindbad.Types.DoNotUseForwardDiff</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoNotUseForwardDiff**

Disable forward mode automatic differentiation

**Type Hierarchy**

`DoNotUseForwardDiff <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoOutputAll' href='#Sindbad.Types.DoOutputAll'><span class="jlbinding">Sindbad.Types.DoOutputAll</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoOutputAll**

Enable output of all model variables

**Type Hierarchy**

`DoOutputAll <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoRunForward' href='#Sindbad.Types.DoRunForward'><span class="jlbinding">Sindbad.Types.DoRunForward</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoRunForward**

Enable forward model run

**Type Hierarchy**

`DoRunForward <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoRunOptimization' href='#Sindbad.Types.DoRunOptimization'><span class="jlbinding">Sindbad.Types.DoRunOptimization</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoRunOptimization**

Enable model parameter optimization

**Type Hierarchy**

`DoRunOptimization <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoSaveInfo' href='#Sindbad.Types.DoSaveInfo'><span class="jlbinding">Sindbad.Types.DoSaveInfo</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoSaveInfo**

Enable saving of model information

**Type Hierarchy**

`DoSaveInfo <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoSaveSingleFile' href='#Sindbad.Types.DoSaveSingleFile'><span class="jlbinding">Sindbad.Types.DoSaveSingleFile</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoSaveSingleFile**

Save all output variables in a single file

**Type Hierarchy**

`DoSaveSingleFile <: OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoSpinupTEM' href='#Sindbad.Types.DoSpinupTEM'><span class="jlbinding">Sindbad.Types.DoSpinupTEM</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoSpinupTEM**

Enable terrestrial ecosystem model spinup

**Type Hierarchy**

`DoSpinupTEM <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoStoreSpinup' href='#Sindbad.Types.DoStoreSpinup'><span class="jlbinding">Sindbad.Types.DoStoreSpinup</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoStoreSpinup**

Enable storing of spinup results

**Type Hierarchy**

`DoStoreSpinup <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.DoUseForwardDiff' href='#Sindbad.Types.DoUseForwardDiff'><span class="jlbinding">Sindbad.Types.DoUseForwardDiff</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**DoUseForwardDiff**

Enable forward mode automatic differentiation

**Type Hierarchy**

`DoUseForwardDiff <: RunFlag <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.EnzymeGrad' href='#Sindbad.Types.EnzymeGrad'><span class="jlbinding">Sindbad.Types.EnzymeGrad</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**EnzymeGrad**

Use Enzyme.jl for automatic differentiation

**Type Hierarchy**

`EnzymeGrad <: GradType <: MLTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.EtaScaleA0H' href='#Sindbad.Types.EtaScaleA0H'><span class="jlbinding">Sindbad.Types.EtaScaleA0H</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**EtaScaleA0H**

scale carbon pools using diagnostic scalars for ηH and c_remain

**Type Hierarchy**

`EtaScaleA0H <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.EtaScaleA0HCWD' href='#Sindbad.Types.EtaScaleA0HCWD'><span class="jlbinding">Sindbad.Types.EtaScaleA0HCWD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**EtaScaleA0HCWD**

scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain

**Type Hierarchy**

`EtaScaleA0HCWD <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.EtaScaleAH' href='#Sindbad.Types.EtaScaleAH'><span class="jlbinding">Sindbad.Types.EtaScaleAH</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**EtaScaleAH**

scale carbon pools using diagnostic scalars for ηH and ηA

**Type Hierarchy**

`EtaScaleAH <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.EtaScaleAHCWD' href='#Sindbad.Types.EtaScaleAHCWD'><span class="jlbinding">Sindbad.Types.EtaScaleAHCWD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**EtaScaleAHCWD**

scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA

**Type Hierarchy**

`EtaScaleAHCWD <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.EvolutionaryCMAES' href='#Sindbad.Types.EvolutionaryCMAES'><span class="jlbinding">Sindbad.Types.EvolutionaryCMAES</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**EvolutionaryCMAES**

Evolutionary version of CMA-ES optimization from Evolutionary.jl

**Type Hierarchy**

`EvolutionaryCMAES <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ExperimentTypes' href='#Sindbad.Types.ExperimentTypes'><span class="jlbinding">Sindbad.Types.ExperimentTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ExperimentTypes**

Abstract type for model run flags and experimental setup and simulations in SINDBAD

**Type Hierarchy**

`ExperimentTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.FiniteDiffGrad' href='#Sindbad.Types.FiniteDiffGrad'><span class="jlbinding">Sindbad.Types.FiniteDiffGrad</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**FiniteDiffGrad**

Use FiniteDiff.jl for finite difference calculations

**Type Hierarchy**

`FiniteDiffGrad <: GradType <: MLTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.FiniteDifferencesGrad' href='#Sindbad.Types.FiniteDifferencesGrad'><span class="jlbinding">Sindbad.Types.FiniteDifferencesGrad</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**FiniteDifferencesGrad**

Use FiniteDifferences.jl for finite difference calculations

**Type Hierarchy**

`FiniteDifferencesGrad <: GradType <: MLTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ForcingWithTime' href='#Sindbad.Types.ForcingWithTime'><span class="jlbinding">Sindbad.Types.ForcingWithTime</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ForcingWithTime**

Forcing variable with time dimension

**Type Hierarchy**

`ForcingWithTime <: ForcingTime <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ForcingWithoutTime' href='#Sindbad.Types.ForcingWithoutTime'><span class="jlbinding">Sindbad.Types.ForcingWithoutTime</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ForcingWithoutTime**

Forcing variable without time dimension

**Type Hierarchy**

`ForcingWithoutTime <: ForcingTime <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ForwardDiffGrad' href='#Sindbad.Types.ForwardDiffGrad'><span class="jlbinding">Sindbad.Types.ForwardDiffGrad</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ForwardDiffGrad**

Use ForwardDiff.jl for automatic differentiation

**Type Hierarchy**

`ForwardDiffGrad <: GradType <: MLTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.GSAMethod' href='#Sindbad.Types.GSAMethod'><span class="jlbinding">Sindbad.Types.GSAMethod</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**GSAMethod**

Abstract type for global sensitivity analysis methods in SINDBAD

**Type Hierarchy**

`GSAMethod <: OptimizationTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `GSAMorris`: Morris method for global sensitivity analysis 
  
- `GSASobol`: Sobol method for global sensitivity analysis 
  
- `GSASobolDM`: Sobol method with derivative-based measures for global sensitivity analysis 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.GSAMorris' href='#Sindbad.Types.GSAMorris'><span class="jlbinding">Sindbad.Types.GSAMorris</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**GSAMorris**

Morris method for global sensitivity analysis

**Type Hierarchy**

`GSAMorris <: GSAMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.GSASobol' href='#Sindbad.Types.GSASobol'><span class="jlbinding">Sindbad.Types.GSASobol</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**GSASobol**

Sobol method for global sensitivity analysis

**Type Hierarchy**

`GSASobol <: GSAMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.GSASobolDM' href='#Sindbad.Types.GSASobolDM'><span class="jlbinding">Sindbad.Types.GSASobolDM</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**GSASobolDM**

Sobol method with derivative-based measures for global sensitivity analysis

**Type Hierarchy**

`GSASobolDM <: GSAMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.GradType' href='#Sindbad.Types.GradType'><span class="jlbinding">Sindbad.Types.GradType</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**GradType**

Abstract type for automatic differentiation or finite differences for gradient calculations

**Type Hierarchy**

`GradType <: MLTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
  
- `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
  
- `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
  
- `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
  
- `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
  
- `ZygoteGrad`: Use Zygote.jl for automatic differentiation 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.InputArray' href='#Sindbad.Types.InputArray'><span class="jlbinding">Sindbad.Types.InputArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**InputArray**

Use standard Julia arrays for input data

**Type Hierarchy**

`InputArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.InputArrayBackend' href='#Sindbad.Types.InputArrayBackend'><span class="jlbinding">Sindbad.Types.InputArrayBackend</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**InputArrayBackend**

Abstract type for input data array types in SINDBAD

**Type Hierarchy**

`InputArrayBackend <: InputTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `InputArray`: Use standard Julia arrays for input data 
  
- `InputKeyedArray`: Use keyed arrays for input data 
  
- `InputNamedDimsArray`: Use named dimension arrays for input data 
  
- `InputYaxArray`: Use YAXArray for input data 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.InputKeyedArray' href='#Sindbad.Types.InputKeyedArray'><span class="jlbinding">Sindbad.Types.InputKeyedArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**InputKeyedArray**

Use keyed arrays for input data

**Type Hierarchy**

`InputKeyedArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.InputNamedDimsArray' href='#Sindbad.Types.InputNamedDimsArray'><span class="jlbinding">Sindbad.Types.InputNamedDimsArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**InputNamedDimsArray**

Use named dimension arrays for input data

**Type Hierarchy**

`InputNamedDimsArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.InputTypes' href='#Sindbad.Types.InputTypes'><span class="jlbinding">Sindbad.Types.InputTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**InputTypes**

Abstract type for input data and processing related options in SINDBAD

**Type Hierarchy**

`InputTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.InputYaxArray' href='#Sindbad.Types.InputYaxArray'><span class="jlbinding">Sindbad.Types.InputYaxArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**InputYaxArray**

Use YAXArray for input data

**Type Hierarchy**

`InputYaxArray <: InputArrayBackend <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.LandTypes' href='#Sindbad.Types.LandTypes'><span class="jlbinding">Sindbad.Types.LandTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**LandTypes**

Abstract type for land related types that are typically used in preparing objects for model runs in SINDBAD

**Type Hierarchy**

`LandTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MLTypes' href='#Sindbad.Types.MLTypes'><span class="jlbinding">Sindbad.Types.MLTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MLTypes**

Abstract type for types in machine learning related methods in SINDBAD

**Type Hierarchy**

`MLTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `GradType`: Abstract type for automatic differentiation or finite differences for gradient calculations 
  - `EnzymeGrad`: Use Enzyme.jl for automatic differentiation 
    
  - `FiniteDiffGrad`: Use FiniteDiff.jl for finite difference calculations 
    
  - `FiniteDifferencesGrad`: Use FiniteDifferences.jl for finite difference calculations 
    
  - `ForwardDiffGrad`: Use ForwardDiff.jl for automatic differentiation 
    
  - `PolyesterForwardDiffGrad`: Use PolyesterForwardDiff.jl for automatic differentiation 
    
  - `ZygoteGrad`: Use Zygote.jl for automatic differentiation 
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MSE' href='#Sindbad.Types.MSE'><span class="jlbinding">Sindbad.Types.MSE</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MSE**

Mean Squared Error: Measures the average squared difference between predicted and observed values

**Type Hierarchy**

`MSE <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MetricMaximum' href='#Sindbad.Types.MetricMaximum'><span class="jlbinding">Sindbad.Types.MetricMaximum</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MetricMaximum**

Take maximum value across spatial dimensions

**Type Hierarchy**

`MetricMaximum <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MetricMinimum' href='#Sindbad.Types.MetricMinimum'><span class="jlbinding">Sindbad.Types.MetricMinimum</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MetricMinimum**

Take minimum value across spatial dimensions

**Type Hierarchy**

`MetricMinimum <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MetricSpatial' href='#Sindbad.Types.MetricSpatial'><span class="jlbinding">Sindbad.Types.MetricSpatial</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MetricSpatial**

Apply spatial aggregation to metrics

**Type Hierarchy**

`MetricSpatial <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MetricSum' href='#Sindbad.Types.MetricSum'><span class="jlbinding">Sindbad.Types.MetricSum</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MetricSum**

Sum values across spatial dimensions

**Type Hierarchy**

`MetricSum <: SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.MetricTypes' href='#Sindbad.Types.MetricTypes'><span class="jlbinding">Sindbad.Types.MetricTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**MetricTypes**

Abstract type for performance metrics and cost calculation methods in SINDBAD

**Type Hierarchy**

`MetricTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ModelArrayArray' href='#Sindbad.Types.ModelArrayArray'><span class="jlbinding">Sindbad.Types.ModelArrayArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ModelArrayArray**

Use standard Julia arrays for model variables

**Type Hierarchy**

`ModelArrayArray <: ModelArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ModelArrayStaticArray' href='#Sindbad.Types.ModelArrayStaticArray'><span class="jlbinding">Sindbad.Types.ModelArrayStaticArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ModelArrayStaticArray**

Use StaticArrays for model variables

**Type Hierarchy**

`ModelArrayStaticArray <: ModelArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ModelArrayType' href='#Sindbad.Types.ModelArrayType'><span class="jlbinding">Sindbad.Types.ModelArrayType</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ModelArrayType**

Abstract type for internal model array types in SINDBAD

**Type Hierarchy**

`ModelArrayType <: ArrayTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `ModelArrayArray`: Use standard Julia arrays for model variables 
  
- `ModelArrayStaticArray`: Use StaticArrays for model variables 
  
- `ModelArrayView`: Use array views for model variables 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ModelArrayView' href='#Sindbad.Types.ModelArrayView'><span class="jlbinding">Sindbad.Types.ModelArrayView</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ModelArrayView**

Use array views for model variables

**Type Hierarchy**

`ModelArrayView <: ModelArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ModelTypes' href='#Sindbad.Types.ModelTypes'><span class="jlbinding">Sindbad.Types.ModelTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ModelTypes**

Abstract type for model types in SINDBAD

**Type Hierarchy**

`ModelTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `DoCatchModelErrors`: Enable error catching during model execution 
  
- `DoNotCatchModelErrors`: Disable error catching during model execution 
  
- `LandEcosystem`: Abstract type for all SINDBAD land ecosystem models/approaches 
  - `EVI`: Enhanced vegetation index 
    - `EVI_constant`: sets EVI as a constant 
      
    - `EVI_forcing`: sets land.states.EVI from forcing 
      
    
  - `LAI`: Leaf area index 
    - `LAI_cVegLeaf`: sets land.states.LAI from the carbon in the leaves of the previous time step 
      
    - `LAI_constant`: sets LAI as a constant 
      
    - `LAI_forcing`: sets land.states.LAI from forcing 
      
    
  - `NDVI`: Normalized difference vegetation index 
    - `NDVI_constant`: sets NDVI as a constant 
      
    - `NDVI_forcing`: sets land.states.NDVI from forcing 
      
    
  - `NDWI`: Normalized difference water index 
    - `NDWI_constant`: sets NDWI as a constant 
      
    - `NDWI_forcing`: sets land.states.NDWI from forcing 
      
    
  - `NIRv`: Near-infrared reflectance of terrestrial vegetation 
    - `NIRv_constant`: sets NIRv as a constant 
      
    - `NIRv_forcing`: sets land.states.NIRv from forcing 
      
    
  - `PET`: Set/get potential evapotranspiration 
    - `PET_Lu2005`: Calculates land.fluxes.PET from the forcing variables 
      
    - `PET_PriestleyTaylor1972`: Calculates land.fluxes.PET from the forcing variables 
      
    - `PET_forcing`: sets land.fluxes.PET from the forcing 
      
    
  - `PFT`: Vegetation PFT 
    - `PFT_constant`: sets a uniform PFT class 
      
    
  - `WUE`: Estimate wue 
    - `WUE_Medlyn2011`: calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD &amp; ambient co2 
      
    - `WUE_VPDDay`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
      
    - `WUE_VPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
      
    - `WUE_constant`: calculates the WUE/AOE as a constant in space &amp; time 
      
    - `WUE_expVPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
      
    
  - `ambientCO2`: sets/gets ambient CO2 concentration 
    - `ambientCO2_constant`: sets ambient_CO2 to a constant value 
      
    - `ambientCO2_forcing`: sets ambient_CO2 from forcing 
      
    
  - `autoRespiration`: estimates autotrophic respiration for growth and maintenance 
    - `autoRespiration_Thornley2000A`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL A - maintenance respiration is given priority. 
      
    - `autoRespiration_Thornley2000B`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL B - growth respiration is given priority. 
      
    - `autoRespiration_Thornley2000C`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL C - growth, degradation &amp; resynthesis view of respiration. Computes the km [maintenance [respiration] coefficient]. 
      
    - `autoRespiration_none`: sets the autotrophic respiration flux from all vegetation pools to zero. 
      
    
  - `autoRespirationAirT`: temperature effect on autotrophic respiration 
    - `autoRespirationAirT_Q10`: temperature effect on autotrophic maintenance respiration following a Q10 response model 
      
    - `autoRespirationAirT_none`: sets the temperature effect on autotrophic respiration to one (i.e. no effect) 
      
    
  - `cAllocation`: Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step). 
    - `cAllocation_Friedlingstein1999`: Compute the fraction of fixed C that is allocated to the different plant organs following the scheme of Friedlingstein et al., 1999 (section `Allocation response to multiple stresses``). 
      
    - `cAllocation_GSI`: Compute the fraction of fixated C that is allocated to the different plant organs. The allocation is dynamic in time according to temperature, water &amp; radiation stressors estimated following the GSI approach. Inspired by the work of Friedlingstein et al., 1999, based on Sharpe and Rykiel 1991, but here following the growing season index (GSI) as stress diagnostics, following Forkel et al 2014 and 2015, based on Jolly et al., 2005. 
      
    - `cAllocation_fixed`: Compute the fraction of net primary production (NPP) allocated to different plant organs with fixed allocation parameters. 
      
    
  

The allocation is adjusted based on the TreeFrac fraction (land.states.frac_tree).  Root allocation is further divided into fine (cf2Root) and coarse roots (cf2RootCoarse) according to the frac_fine_to_coarse parameter.

```
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
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NAME1R' href='#Sindbad.Types.NAME1R'><span class="jlbinding">Sindbad.Types.NAME1R</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NAME1R**

Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations

**Type Hierarchy**

`NAME1R <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NMAE1R' href='#Sindbad.Types.NMAE1R'><span class="jlbinding">Sindbad.Types.NMAE1R</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NMAE1R**

Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations

**Type Hierarchy**

`NMAE1R <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NNSE' href='#Sindbad.Types.NNSE'><span class="jlbinding">Sindbad.Types.NNSE</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NNSE**

Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range

**Type Hierarchy**

`NNSE <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NNSEInv' href='#Sindbad.Types.NNSEInv'><span class="jlbinding">Sindbad.Types.NNSEInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NNSEInv**

Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range

**Type Hierarchy**

`NNSEInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NNSEσ' href='#Sindbad.Types.NNSEσ'><span class="jlbinding">Sindbad.Types.NNSEσ</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NNSEσ**

Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure

**Type Hierarchy**

`NNSEσ <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NNSEσInv' href='#Sindbad.Types.NNSEσInv'><span class="jlbinding">Sindbad.Types.NNSEσInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NNSEσInv**

Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems

**Type Hierarchy**

`NNSEσInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NPcor' href='#Sindbad.Types.NPcor'><span class="jlbinding">Sindbad.Types.NPcor</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NPcor**

Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range

**Type Hierarchy**

`NPcor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NPcorInv' href='#Sindbad.Types.NPcorInv'><span class="jlbinding">Sindbad.Types.NPcorInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NPcorInv**

Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems

**Type Hierarchy**

`NPcorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NSE' href='#Sindbad.Types.NSE'><span class="jlbinding">Sindbad.Types.NSE</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NSE**

Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations

**Type Hierarchy**

`NSE <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NSEInv' href='#Sindbad.Types.NSEInv'><span class="jlbinding">Sindbad.Types.NSEInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NSEInv**

Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems

**Type Hierarchy**

`NSEInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NSEσ' href='#Sindbad.Types.NSEσ'><span class="jlbinding">Sindbad.Types.NSEσ</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NSEσ**

Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure

**Type Hierarchy**

`NSEσ <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NSEσInv' href='#Sindbad.Types.NSEσInv'><span class="jlbinding">Sindbad.Types.NSEσInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NSEσInv**

Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems

**Type Hierarchy**

`NSEσInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NScor' href='#Sindbad.Types.NScor'><span class="jlbinding">Sindbad.Types.NScor</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NScor**

Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range

**Type Hierarchy**

`NScor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NScorInv' href='#Sindbad.Types.NScorInv'><span class="jlbinding">Sindbad.Types.NScorInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NScorInv**

Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems

**Type Hierarchy**

`NScorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NlsolveFixedpointTrustregionCEco' href='#Sindbad.Types.NlsolveFixedpointTrustregionCEco'><span class="jlbinding">Sindbad.Types.NlsolveFixedpointTrustregionCEco</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NlsolveFixedpointTrustregionCEco**

use a fixed-point nonlinear solver with trust region for carbon pools (cEco)

**Type Hierarchy**

`NlsolveFixedpointTrustregionCEco <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NlsolveFixedpointTrustregionCEcoTWS' href='#Sindbad.Types.NlsolveFixedpointTrustregionCEcoTWS'><span class="jlbinding">Sindbad.Types.NlsolveFixedpointTrustregionCEcoTWS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NlsolveFixedpointTrustregionCEcoTWS**

use a fixed-point nonlinear solver with trust region for both cEco and TWS

**Type Hierarchy**

`NlsolveFixedpointTrustregionCEcoTWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.NlsolveFixedpointTrustregionTWS' href='#Sindbad.Types.NlsolveFixedpointTrustregionTWS'><span class="jlbinding">Sindbad.Types.NlsolveFixedpointTrustregionTWS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**NlsolveFixedpointTrustregionTWS**

use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS)

**Type Hierarchy**

`NlsolveFixedpointTrustregionTWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ODEAutoTsit5Rodas5' href='#Sindbad.Types.ODEAutoTsit5Rodas5'><span class="jlbinding">Sindbad.Types.ODEAutoTsit5Rodas5</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ODEAutoTsit5Rodas5**

use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs

**Type Hierarchy**

`ODEAutoTsit5Rodas5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ODEDP5' href='#Sindbad.Types.ODEDP5'><span class="jlbinding">Sindbad.Types.ODEDP5</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ODEDP5**

use the DP5 method from DifferentialEquations.jl for solving ODEs

**Type Hierarchy**

`ODEDP5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ODETsit5' href='#Sindbad.Types.ODETsit5'><span class="jlbinding">Sindbad.Types.ODETsit5</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ODETsit5**

use the Tsit5 method from DifferentialEquations.jl for solving ODEs

**Type Hierarchy**

`ODETsit5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimBFGS' href='#Sindbad.Types.OptimBFGS'><span class="jlbinding">Sindbad.Types.OptimBFGS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimBFGS**

Broyden-Fletcher-Goldfarb-Shanno (BFGS) from Optim.jl

**Type Hierarchy**

`OptimBFGS <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimLBFGS' href='#Sindbad.Types.OptimLBFGS'><span class="jlbinding">Sindbad.Types.OptimLBFGS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimLBFGS**

Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) from Optim.jl

**Type Hierarchy**

`OptimLBFGS <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationBBOadaptive' href='#Sindbad.Types.OptimizationBBOadaptive'><span class="jlbinding">Sindbad.Types.OptimizationBBOadaptive</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationBBOadaptive**

Black Box Optimization with adaptive parameters from Optimization.jl

**Type Hierarchy**

`OptimizationBBOadaptive <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationBBOxnes' href='#Sindbad.Types.OptimizationBBOxnes'><span class="jlbinding">Sindbad.Types.OptimizationBBOxnes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationBBOxnes**

Black Box Optimization using Natural Evolution Strategy (xNES) from Optimization.jl

**Type Hierarchy**

`OptimizationBBOxnes <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationBFGS' href='#Sindbad.Types.OptimizationBFGS'><span class="jlbinding">Sindbad.Types.OptimizationBFGS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationBFGS**

BFGS optimization with box constraints from Optimization.jl

**Type Hierarchy**

`OptimizationBFGS <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationFminboxGradientDescent' href='#Sindbad.Types.OptimizationFminboxGradientDescent'><span class="jlbinding">Sindbad.Types.OptimizationFminboxGradientDescent</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationFminboxGradientDescent**

Gradient descent optimization with box constraints from Optimization.jl

**Type Hierarchy**

`OptimizationFminboxGradientDescent <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationFminboxGradientDescentFD' href='#Sindbad.Types.OptimizationFminboxGradientDescentFD'><span class="jlbinding">Sindbad.Types.OptimizationFminboxGradientDescentFD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationFminboxGradientDescentFD**

Gradient descent optimization with box constraints using forward differentiation from Optimization.jl

**Type Hierarchy**

`OptimizationFminboxGradientDescentFD <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationGCMAESDef' href='#Sindbad.Types.OptimizationGCMAESDef'><span class="jlbinding">Sindbad.Types.OptimizationGCMAESDef</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationGCMAESDef**

Global CMA-ES optimization with default settings from Optimization.jl

**Type Hierarchy**

`OptimizationGCMAESDef <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationGCMAESFD' href='#Sindbad.Types.OptimizationGCMAESFD'><span class="jlbinding">Sindbad.Types.OptimizationGCMAESFD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationGCMAESFD**

Global CMA-ES optimization using forward differentiation from Optimization.jl

**Type Hierarchy**

`OptimizationGCMAESFD <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationMethod' href='#Sindbad.Types.OptimizationMethod'><span class="jlbinding">Sindbad.Types.OptimizationMethod</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationMethod**

Abstract type for optimization methods in SINDBAD

**Type Hierarchy**

`OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationMultistartOptimization' href='#Sindbad.Types.OptimizationMultistartOptimization'><span class="jlbinding">Sindbad.Types.OptimizationMultistartOptimization</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationMultistartOptimization**

Multi-start optimization to find global optimum from Optimization.jl

**Type Hierarchy**

`OptimizationMultistartOptimization <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationNelderMead' href='#Sindbad.Types.OptimizationNelderMead'><span class="jlbinding">Sindbad.Types.OptimizationNelderMead</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationNelderMead**

Nelder-Mead simplex optimization method from Optimization.jl

**Type Hierarchy**

`OptimizationNelderMead <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationQuadDirect' href='#Sindbad.Types.OptimizationQuadDirect'><span class="jlbinding">Sindbad.Types.OptimizationQuadDirect</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationQuadDirect**

Quadratic Direct optimization method from Optimization.jl

**Type Hierarchy**

`OptimizationQuadDirect <: OptimizationMethod <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OptimizationTypes' href='#Sindbad.Types.OptimizationTypes'><span class="jlbinding">Sindbad.Types.OptimizationTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OptimizationTypes**

Abstract type for optimization related functions and methods in SINDBAD

**Type Hierarchy**

`OptimizationTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OutputArray' href='#Sindbad.Types.OutputArray'><span class="jlbinding">Sindbad.Types.OutputArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OutputArray**

Use standard Julia arrays for output

**Type Hierarchy**

`OutputArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OutputArrayType' href='#Sindbad.Types.OutputArrayType'><span class="jlbinding">Sindbad.Types.OutputArrayType</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OutputArrayType**

Abstract type for output array types in SINDBAD

**Type Hierarchy**

`OutputArrayType <: ArrayTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `OutputArray`: Use standard Julia arrays for output 
  
- `OutputMArray`: Use MArray for output 
  
- `OutputSizedArray`: Use SizedArray for output 
  
- `OutputYAXArray`: Use YAXArray for output 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OutputMArray' href='#Sindbad.Types.OutputMArray'><span class="jlbinding">Sindbad.Types.OutputMArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OutputMArray**

Use MArray for output

**Type Hierarchy**

`OutputMArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OutputSizedArray' href='#Sindbad.Types.OutputSizedArray'><span class="jlbinding">Sindbad.Types.OutputSizedArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OutputSizedArray**

Use SizedArray for output

**Type Hierarchy**

`OutputSizedArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OutputStrategy' href='#Sindbad.Types.OutputStrategy'><span class="jlbinding">Sindbad.Types.OutputStrategy</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OutputStrategy**

Abstract type for model output strategies in SINDBAD

**Type Hierarchy**

`OutputStrategy <: ExperimentTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `DoNotOutputAll`: Disable output of all model variables 
  
- `DoNotSaveSingleFile`: Save output variables in separate files 
  
- `DoOutputAll`: Enable output of all model variables 
  
- `DoSaveSingleFile`: Save all output variables in a single file 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.OutputYAXArray' href='#Sindbad.Types.OutputYAXArray'><span class="jlbinding">Sindbad.Types.OutputYAXArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**OutputYAXArray**

Use YAXArray for output

**Type Hierarchy**

`OutputYAXArray <: OutputArrayType <: ArrayTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ParallelizationPackage' href='#Sindbad.Types.ParallelizationPackage'><span class="jlbinding">Sindbad.Types.ParallelizationPackage</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ParallelizationPackage**

Abstract type for using different parallelization packages in SINDBAD

**Type Hierarchy**

`ParallelizationPackage <: ExperimentTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `QbmapParallelization`: Use Qbmap for parallelization 
  
- `ThreadsParallelization`: Use Julia threads for parallelization 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ParameterScaling' href='#Sindbad.Types.ParameterScaling'><span class="jlbinding">Sindbad.Types.ParameterScaling</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ParameterScaling**

Abstract type for parameter scaling methods in SINDBAD

**Type Hierarchy**

`ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `ScaleBounds`: Scale parameters relative to their bounds 
  
- `ScaleDefault`: Scale parameters relative to default values 
  
- `ScaleNone`: No parameter scaling applied 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Pcor' href='#Sindbad.Types.Pcor'><span class="jlbinding">Sindbad.Types.Pcor</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Pcor**

Pearson Correlation: Measures linear correlation between predictions and observations

**Type Hierarchy**

`Pcor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Pcor2' href='#Sindbad.Types.Pcor2'><span class="jlbinding">Sindbad.Types.Pcor2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Pcor2**

Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations

**Type Hierarchy**

`Pcor2 <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Pcor2Inv' href='#Sindbad.Types.Pcor2Inv'><span class="jlbinding">Sindbad.Types.Pcor2Inv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Pcor2Inv**

Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems

**Type Hierarchy**

`Pcor2Inv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PcorInv' href='#Sindbad.Types.PcorInv'><span class="jlbinding">Sindbad.Types.PcorInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PcorInv**

Inverse Pearson Correlation: Inverse of Pcor for minimization problems

**Type Hierarchy**

`PcorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PerfMetric' href='#Sindbad.Types.PerfMetric'><span class="jlbinding">Sindbad.Types.PerfMetric</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PerfMetric**

Abstract type for performance metrics in SINDBAD

**Type Hierarchy**

`PerfMetric <: MetricTypes <: SindbadTypes <: Any`


---


**Extended help**

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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PolyesterForwardDiffGrad' href='#Sindbad.Types.PolyesterForwardDiffGrad'><span class="jlbinding">Sindbad.Types.PolyesterForwardDiffGrad</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PolyesterForwardDiffGrad**

Use PolyesterForwardDiff.jl for automatic differentiation

**Type Hierarchy**

`PolyesterForwardDiffGrad <: GradType <: MLTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAlloc' href='#Sindbad.Types.PreAlloc'><span class="jlbinding">Sindbad.Types.PreAlloc</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAlloc**

Abstract type for preallocated land helpers types in prepTEM of SINDBAD

**Type Hierarchy**

`PreAlloc <: LandTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `PreAllocArray`: use a preallocated array for model output 
  
- `PreAllocArrayAll`: use a preallocated array to output all land variables 
  
- `PreAllocArrayFD`: use a preallocated array for finite difference (FD) hybrid experiments 
  
- `PreAllocArrayMT`: use arrays of nThreads size for land model output for replicates of multiple threads 
  
- `PreAllocStacked`: save output as a stacked vector of land using map over temporal dimension 
  
- `PreAllocTimeseries`: save land output as a preallocated vector for time series of land 
  
- `PreAllocYAXArray`: use YAX arrays for model output 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocArray' href='#Sindbad.Types.PreAllocArray'><span class="jlbinding">Sindbad.Types.PreAllocArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocArray**

use a preallocated array for model output

**Type Hierarchy**

`PreAllocArray <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocArrayAll' href='#Sindbad.Types.PreAllocArrayAll'><span class="jlbinding">Sindbad.Types.PreAllocArrayAll</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocArrayAll**

use a preallocated array to output all land variables

**Type Hierarchy**

`PreAllocArrayAll <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocArrayFD' href='#Sindbad.Types.PreAllocArrayFD'><span class="jlbinding">Sindbad.Types.PreAllocArrayFD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocArrayFD**

use a preallocated array for finite difference (FD) hybrid experiments

**Type Hierarchy**

`PreAllocArrayFD <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocArrayMT' href='#Sindbad.Types.PreAllocArrayMT'><span class="jlbinding">Sindbad.Types.PreAllocArrayMT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocArrayMT**

use arrays of nThreads size for land model output for replicates of multiple threads

**Type Hierarchy**

`PreAllocArrayMT <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocStacked' href='#Sindbad.Types.PreAllocStacked'><span class="jlbinding">Sindbad.Types.PreAllocStacked</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocStacked**

save output as a stacked vector of land using map over temporal dimension

**Type Hierarchy**

`PreAllocStacked <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocTimeseries' href='#Sindbad.Types.PreAllocTimeseries'><span class="jlbinding">Sindbad.Types.PreAllocTimeseries</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocTimeseries**

save land output as a preallocated vector for time series of land

**Type Hierarchy**

`PreAllocTimeseries <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.PreAllocYAXArray' href='#Sindbad.Types.PreAllocYAXArray'><span class="jlbinding">Sindbad.Types.PreAllocYAXArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**PreAllocYAXArray**

use YAX arrays for model output

**Type Hierarchy**

`PreAllocYAXArray <: PreAlloc <: LandTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.QbmapParallelization' href='#Sindbad.Types.QbmapParallelization'><span class="jlbinding">Sindbad.Types.QbmapParallelization</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**QbmapParallelization**

Use Qbmap for parallelization

**Type Hierarchy**

`QbmapParallelization <: ParallelizationPackage <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.RunFlag' href='#Sindbad.Types.RunFlag'><span class="jlbinding">Sindbad.Types.RunFlag</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**RunFlag**

Abstract type for model run configuration flags in SINDBAD

**Type Hierarchy**

`RunFlag <: ExperimentTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SSPDynamicSSTsit5' href='#Sindbad.Types.SSPDynamicSSTsit5'><span class="jlbinding">Sindbad.Types.SSPDynamicSSTsit5</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SSPDynamicSSTsit5**

use the SteadyState solver with DynamicSS and Tsit5 methods

**Type Hierarchy**

`SSPDynamicSSTsit5 <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SSPSSRootfind' href='#Sindbad.Types.SSPSSRootfind'><span class="jlbinding">Sindbad.Types.SSPSSRootfind</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SSPSSRootfind**

use the SteadyState solver with SSRootfind method

**Type Hierarchy**

`SSPSSRootfind <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ScaleBounds' href='#Sindbad.Types.ScaleBounds'><span class="jlbinding">Sindbad.Types.ScaleBounds</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ScaleBounds**

Scale parameters relative to their bounds

**Type Hierarchy**

`ScaleBounds <: ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ScaleDefault' href='#Sindbad.Types.ScaleDefault'><span class="jlbinding">Sindbad.Types.ScaleDefault</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ScaleDefault**

Scale parameters relative to default values

**Type Hierarchy**

`ScaleDefault <: ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ScaleNone' href='#Sindbad.Types.ScaleNone'><span class="jlbinding">Sindbad.Types.ScaleNone</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ScaleNone**

No parameter scaling applied

**Type Hierarchy**

`ScaleNone <: ParameterScaling <: OptimizationTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Scor' href='#Sindbad.Types.Scor'><span class="jlbinding">Sindbad.Types.Scor</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Scor**

Spearman Correlation: Measures monotonic relationship between predictions and observations

**Type Hierarchy**

`Scor <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Scor2' href='#Sindbad.Types.Scor2'><span class="jlbinding">Sindbad.Types.Scor2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Scor2**

Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations

**Type Hierarchy**

`Scor2 <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Scor2Inv' href='#Sindbad.Types.Scor2Inv'><span class="jlbinding">Sindbad.Types.Scor2Inv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Scor2Inv**

Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems

**Type Hierarchy**

`Scor2Inv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ScorInv' href='#Sindbad.Types.ScorInv'><span class="jlbinding">Sindbad.Types.ScorInv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ScorInv**

Inverse Spearman Correlation: Inverse of Scor for minimization problems

**Type Hierarchy**

`ScorInv <: PerfMetric <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SelSpinupModels' href='#Sindbad.Types.SelSpinupModels'><span class="jlbinding">Sindbad.Types.SelSpinupModels</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SelSpinupModels**

run only the models selected for spinup in the model structure

**Type Hierarchy**

`SelSpinupModels <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpaceID' href='#Sindbad.Types.SpaceID'><span class="jlbinding">Sindbad.Types.SpaceID</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpaceID**

Use site ID (all caps) for spatial subsetting

**Type Hierarchy**

`SpaceID <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpaceId' href='#Sindbad.Types.SpaceId'><span class="jlbinding">Sindbad.Types.SpaceId</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpaceId**

Use site ID (capitalized) for spatial subsetting

**Type Hierarchy**

`SpaceId <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpaceTime' href='#Sindbad.Types.SpaceTime'><span class="jlbinding">Sindbad.Types.SpaceTime</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpaceTime**

Aggregate data first over space, then over time

**Type Hierarchy**

`SpaceTime <: DataAggrOrder <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spaceid' href='#Sindbad.Types.Spaceid'><span class="jlbinding">Sindbad.Types.Spaceid</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spaceid**

Use site ID for spatial subsetting

**Type Hierarchy**

`Spaceid <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spacelat' href='#Sindbad.Types.Spacelat'><span class="jlbinding">Sindbad.Types.Spacelat</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spacelat**

Use latitude for spatial subsetting

**Type Hierarchy**

`Spacelat <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spacelatitude' href='#Sindbad.Types.Spacelatitude'><span class="jlbinding">Sindbad.Types.Spacelatitude</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spacelatitude**

Use full latitude for spatial subsetting

**Type Hierarchy**

`Spacelatitude <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spacelon' href='#Sindbad.Types.Spacelon'><span class="jlbinding">Sindbad.Types.Spacelon</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spacelon**

Use longitude for spatial subsetting

**Type Hierarchy**

`Spacelon <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spacelongitude' href='#Sindbad.Types.Spacelongitude'><span class="jlbinding">Sindbad.Types.Spacelongitude</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spacelongitude**

Use full longitude for spatial subsetting

**Type Hierarchy**

`Spacelongitude <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spacesite' href='#Sindbad.Types.Spacesite'><span class="jlbinding">Sindbad.Types.Spacesite</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spacesite**

Use site location for spatial subsetting

**Type Hierarchy**

`Spacesite <: SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpatialDataAggr' href='#Sindbad.Types.SpatialDataAggr'><span class="jlbinding">Sindbad.Types.SpatialDataAggr</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpatialDataAggr**

Abstract type for spatial data aggregation methods in SINDBAD

**Type Hierarchy**

`SpatialDataAggr <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpatialMetricAggr' href='#Sindbad.Types.SpatialMetricAggr'><span class="jlbinding">Sindbad.Types.SpatialMetricAggr</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpatialMetricAggr**

Abstract type for spatial metric aggregation methods in SINDBAD

**Type Hierarchy**

`SpatialMetricAggr <: MetricTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `MetricMaximum`: Take maximum value across spatial dimensions 
  
- `MetricMinimum`: Take minimum value across spatial dimensions 
  
- `MetricSpatial`: Apply spatial aggregation to metrics 
  
- `MetricSum`: Sum values across spatial dimensions 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpatialSubsetter' href='#Sindbad.Types.SpatialSubsetter'><span class="jlbinding">Sindbad.Types.SpatialSubsetter</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpatialSubsetter**

Abstract type for spatial subsetting methods in SINDBAD

**Type Hierarchy**

`SpatialSubsetter <: InputTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
- `SpaceID`: Use site ID (all caps) for spatial subsetting 
  
- `SpaceId`: Use site ID (capitalized) for spatial subsetting 
  
- `Spaceid`: Use site ID for spatial subsetting 
  
- `Spacelat`: Use latitude for spatial subsetting 
  
- `Spacelatitude`: Use full latitude for spatial subsetting 
  
- `Spacelon`: Use longitude for spatial subsetting 
  
- `Spacelongitude`: Use full longitude for spatial subsetting 
  
- `Spacesite`: Use site location for spatial subsetting 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpinupMode' href='#Sindbad.Types.SpinupMode'><span class="jlbinding">Sindbad.Types.SpinupMode</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpinupMode**

Abstract type for model spinup modes in SINDBAD

**Type Hierarchy**

`SpinupMode <: SpinupTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpinupSequence' href='#Sindbad.Types.SpinupSequence'><span class="jlbinding">Sindbad.Types.SpinupSequence</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpinupSequence**

Basic Spinup sequence without time aggregation

**Type Hierarchy**

`SpinupSequence <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpinupSequenceWithAggregator' href='#Sindbad.Types.SpinupSequenceWithAggregator'><span class="jlbinding">Sindbad.Types.SpinupSequenceWithAggregator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpinupSequenceWithAggregator**

Spinup sequence with time aggregation for corresponding forcingtime series

**Type Hierarchy**

`SpinupSequenceWithAggregator <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.SpinupTypes' href='#Sindbad.Types.SpinupTypes'><span class="jlbinding">Sindbad.Types.SpinupTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**SpinupTypes**

Abstract type for model spinup related functions and methods in SINDBAD

**Type Hierarchy**

`SpinupTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spinup_TWS' href='#Sindbad.Types.Spinup_TWS'><span class="jlbinding">Sindbad.Types.Spinup_TWS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spinup_TWS**

Spinup spinup_mode for Total Water Storage (TWS)

**Type Hierarchy**

`Spinup_TWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spinup_cEco' href='#Sindbad.Types.Spinup_cEco'><span class="jlbinding">Sindbad.Types.Spinup_cEco</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spinup_cEco**

Spinup spinup_mode for cEco

**Type Hierarchy**

`Spinup_cEco <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spinup_cEco_TWS' href='#Sindbad.Types.Spinup_cEco_TWS'><span class="jlbinding">Sindbad.Types.Spinup_cEco_TWS</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**Spinup_cEco_TWS**

Spinup spinup_mode for cEco and TWS

**Type Hierarchy**

`Spinup_cEco_TWS <: SpinupMode <: SpinupTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ThreadsParallelization' href='#Sindbad.Types.ThreadsParallelization'><span class="jlbinding">Sindbad.Types.ThreadsParallelization</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ThreadsParallelization**

Use Julia threads for parallelization

**Type Hierarchy**

`ThreadsParallelization <: ParallelizationPackage <: ExperimentTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeAggregation' href='#Sindbad.Types.TimeAggregation'><span class="jlbinding">Sindbad.Types.TimeAggregation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeAggregation**

Abstract type for time aggregation methods in SINDBAD

**Type Hierarchy**

`TimeAggregation <: TimeTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeAllYears' href='#Sindbad.Types.TimeAllYears'><span class="jlbinding">Sindbad.Types.TimeAllYears</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeAllYears**

aggregation/slicing to include all years

**Type Hierarchy**

`TimeAllYears <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeArray' href='#Sindbad.Types.TimeArray'><span class="jlbinding">Sindbad.Types.TimeArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeArray**

use array-based time aggregation

**Type Hierarchy**

`TimeArray <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeDay' href='#Sindbad.Types.TimeDay'><span class="jlbinding">Sindbad.Types.TimeDay</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeDay**

aggregation to daily time steps

**Type Hierarchy**

`TimeDay <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeDayAnomaly' href='#Sindbad.Types.TimeDayAnomaly'><span class="jlbinding">Sindbad.Types.TimeDayAnomaly</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeDayAnomaly**

aggregation to daily anomalies

**Type Hierarchy**

`TimeDayAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeDayIAV' href='#Sindbad.Types.TimeDayIAV'><span class="jlbinding">Sindbad.Types.TimeDayIAV</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeDayIAV**

aggregation to daily IAV

**Type Hierarchy**

`TimeDayIAV <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeDayMSC' href='#Sindbad.Types.TimeDayMSC'><span class="jlbinding">Sindbad.Types.TimeDayMSC</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeDayMSC**

aggregation to daily MSC

**Type Hierarchy**

`TimeDayMSC <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeDayMSCAnomaly' href='#Sindbad.Types.TimeDayMSCAnomaly'><span class="jlbinding">Sindbad.Types.TimeDayMSCAnomaly</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeDayMSCAnomaly**

aggregation to daily MSC anomalies

**Type Hierarchy**

`TimeDayMSCAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeDiff' href='#Sindbad.Types.TimeDiff'><span class="jlbinding">Sindbad.Types.TimeDiff</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeDiff**

aggregation to time differences, e.g. monthly anomalies

**Type Hierarchy**

`TimeDiff <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeFirstYear' href='#Sindbad.Types.TimeFirstYear'><span class="jlbinding">Sindbad.Types.TimeFirstYear</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeFirstYear**

aggregation/slicing of the first year

**Type Hierarchy**

`TimeFirstYear <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeHour' href='#Sindbad.Types.TimeHour'><span class="jlbinding">Sindbad.Types.TimeHour</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeHour**

aggregation to hourly time steps

**Type Hierarchy**

`TimeHour <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeHourAnomaly' href='#Sindbad.Types.TimeHourAnomaly'><span class="jlbinding">Sindbad.Types.TimeHourAnomaly</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeHourAnomaly**

aggregation to hourly anomalies

**Type Hierarchy**

`TimeHourAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeHourDayMean' href='#Sindbad.Types.TimeHourDayMean'><span class="jlbinding">Sindbad.Types.TimeHourDayMean</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeHourDayMean**

aggregation to mean of hourly data over days

**Type Hierarchy**

`TimeHourDayMean <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeIndexed' href='#Sindbad.Types.TimeIndexed'><span class="jlbinding">Sindbad.Types.TimeIndexed</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeIndexed**

aggregation using time indices, e.g., TimeFirstYear

**Type Hierarchy**

`TimeIndexed <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeMean' href='#Sindbad.Types.TimeMean'><span class="jlbinding">Sindbad.Types.TimeMean</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeMean**

aggregation to mean over all time steps

**Type Hierarchy**

`TimeMean <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeMonth' href='#Sindbad.Types.TimeMonth'><span class="jlbinding">Sindbad.Types.TimeMonth</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeMonth**

aggregation to monthly time steps

**Type Hierarchy**

`TimeMonth <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeMonthAnomaly' href='#Sindbad.Types.TimeMonthAnomaly'><span class="jlbinding">Sindbad.Types.TimeMonthAnomaly</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeMonthAnomaly**

aggregation to monthly anomalies

**Type Hierarchy**

`TimeMonthAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeMonthIAV' href='#Sindbad.Types.TimeMonthIAV'><span class="jlbinding">Sindbad.Types.TimeMonthIAV</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeMonthIAV**

aggregation to monthly IAV

**Type Hierarchy**

`TimeMonthIAV <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeMonthMSC' href='#Sindbad.Types.TimeMonthMSC'><span class="jlbinding">Sindbad.Types.TimeMonthMSC</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeMonthMSC**

aggregation to monthly MSC

**Type Hierarchy**

`TimeMonthMSC <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeMonthMSCAnomaly' href='#Sindbad.Types.TimeMonthMSCAnomaly'><span class="jlbinding">Sindbad.Types.TimeMonthMSCAnomaly</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeMonthMSCAnomaly**

aggregation to monthly MSC anomalies

**Type Hierarchy**

`TimeMonthMSCAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeNoDiff' href='#Sindbad.Types.TimeNoDiff'><span class="jlbinding">Sindbad.Types.TimeNoDiff</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeNoDiff**

aggregation without time differences

**Type Hierarchy**

`TimeNoDiff <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeRandomYear' href='#Sindbad.Types.TimeRandomYear'><span class="jlbinding">Sindbad.Types.TimeRandomYear</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeRandomYear**

aggregation/slicing of a random year

**Type Hierarchy**

`TimeRandomYear <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeShuffleYears' href='#Sindbad.Types.TimeShuffleYears'><span class="jlbinding">Sindbad.Types.TimeShuffleYears</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeShuffleYears**

aggregation/slicing/selection of shuffled years

**Type Hierarchy**

`TimeShuffleYears <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeSizedArray' href='#Sindbad.Types.TimeSizedArray'><span class="jlbinding">Sindbad.Types.TimeSizedArray</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeSizedArray**

aggregation to a sized array

**Type Hierarchy**

`TimeSizedArray <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeSpace' href='#Sindbad.Types.TimeSpace'><span class="jlbinding">Sindbad.Types.TimeSpace</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeSpace**

Aggregate data first over time, then over space

**Type Hierarchy**

`TimeSpace <: DataAggrOrder <: MetricTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeTypes' href='#Sindbad.Types.TimeTypes'><span class="jlbinding">Sindbad.Types.TimeTypes</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeTypes**

Abstract type for implementing time subset and aggregation types in SINDBAD

**Type Hierarchy**

`TimeTypes <: SindbadTypes <: Any`


---


**Extended help**

**Available methods/subtypes:**
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
<summary><a id='Sindbad.Types.TimeYear' href='#Sindbad.Types.TimeYear'><span class="jlbinding">Sindbad.Types.TimeYear</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeYear**

aggregation to yearly time steps

**Type Hierarchy**

`TimeYear <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.TimeYearAnomaly' href='#Sindbad.Types.TimeYearAnomaly'><span class="jlbinding">Sindbad.Types.TimeYearAnomaly</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**TimeYearAnomaly**

aggregation to yearly anomalies

**Type Hierarchy**

`TimeYearAnomaly <: TimeAggregation <: TimeTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.ZygoteGrad' href='#Sindbad.Types.ZygoteGrad'><span class="jlbinding">Sindbad.Types.ZygoteGrad</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**ZygoteGrad**

Use Zygote.jl for automatic differentiation

**Type Hierarchy**

`ZygoteGrad <: GradType <: MLTypes <: SindbadTypes <: Any`

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.checkInRange' href='#SindbadSetup.checkInRange'><span class="jlbinding">SindbadSetup.checkInRange</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
checkInRange(name, value, lower_bound, upper_bound, show_info)
```


Checks whether a given value or array is within specified bounds.

**Arguments:**
- `name`: A string or symbol representing the name or identifier of the parameter being checked.
  
- `value`: The value or array to be checked against the bounds.
  - Can be a scalar (`Real`) or an array (`AbstractArray`).
    
  
- `lower_bound`: The lower bound for the value or array.
  
- `upper_bound`: The upper bound for the value or array.
  
- `show_info`: A boolean flag indicating whether to display detailed information about the check.
  

**Returns:**
- `true`: If the value or all elements of the array are within the specified bounds.
  
- `false`: If the value or any element of the array violates the bounds.
  

**Notes:**
- If `value` is an array and `show_info` is `true`, the function logs a message indicating that the check is skipped for arrays, as bounds are typically defined for scalar parameters.
  
- For scalar values, the function performs a direct comparison to ensure the value lies within `[lower_bound, upper_bound]`.
  
- If the bounds are violated, the function logs detailed information (if `show_info` is `true`) and returns `false`.
  

**Examples:**
1. **Checking a scalar value**:
  

```julia
is_in_range = checkInRange("parameter1", 5.0, 0.0, 10.0, true)
# Output: true
```

1. **Checking an array (skipping bounds check)**:
  

```julia
is_in_range = checkInRange("parameter2", [1.0, 2.0, 3.0], 0.0, 10.0, true)
# Output: true (logs a message indicating the check is skipped)
```

1. **Checking a scalar value outside bounds**:
  

```julia
is_in_range = checkInRange("parameter3", -1.0, 0.0, 10.0, true)
# Output: false (logs a message indicating the violation)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.checkOptimizedParametersInModels-Tuple{NamedTuple, Any}' href='#SindbadSetup.checkOptimizedParametersInModels-Tuple{NamedTuple, Any}'><span class="jlbinding">SindbadSetup.checkOptimizedParametersInModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
checkOptimizedParametersInModels(info::NamedTuple, parameter_table)
```


Checks if the parameters listed in `model_parameters_to_optimize` from `optimization.json` exist in the selected model structure from `model_structure.json`.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  
- `parameter_table`: A table of parameters extracted from the model structure.
  

**Notes:**
- Issues a warning and throws an error if any parameter in `model_parameters_to_optimize` does not exist in the model structure.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.checkSelectedModels-Tuple{Any, AbstractArray}' href='#SindbadSetup.checkSelectedModels-Tuple{Any, AbstractArray}'><span class="jlbinding">SindbadSetup.checkSelectedModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
checkSelectedModels(sindbad_models::AbstractArray, selected_models::AbstractArray)
```


Validates that the selected models in `model_structure.json` exist in the full list of `standard_sindbad_models`.

**Arguments:**
- `sindbad_models`: An array of all available SINDBAD models.
  
- `selected_models`: An array of selected models to validate.
  

**Returns:**
- `true` if all selected models are valid; otherwise, throws an error.
  

**Notes:**
- Ensures that the selected models are consistent with the available SINDBAD models.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.convertToAbsolutePath-Tuple{}' href='#SindbadSetup.convertToAbsolutePath-Tuple{}'><span class="jlbinding">SindbadSetup.convertToAbsolutePath</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
convertToAbsolutePath(; inputDict=inputDict)
```


Converts all relative paths in the input dictionary to absolute paths, assuming all non-absolute paths are relative to the SINDBAD root directory.

**Arguments:**
- `inputDict`: A dictionary containing paths as values.
  

**Returns:**
- A new dictionary with all paths converted to absolute paths.
  

**Notes:**
- This function is currently incomplete and does not perform the conversion yet.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getAggrFunc-Tuple{String}' href='#SindbadSetup.getAggrFunc-Tuple{String}'><span class="jlbinding">SindbadSetup.getAggrFunc</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAggrFunc(func_name::String)
```


Returns an aggregation function corresponding to the given function name.

**Arguments:**
- `func_name`: A string specifying the name of the aggregation function (e.g., &quot;mean&quot;, &quot;sum&quot;).
  

**Returns:**
- The corresponding aggregation function (e.g., `mean`, `sum`).
  

**Notes:**
- Supports common aggregation functions such as `mean`, `sum`, `nanmean`, and `nansum`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getAllLandVars-Tuple{Any}' href='#SindbadSetup.getAllLandVars-Tuple{Any}'><span class="jlbinding">SindbadSetup.getAllLandVars</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAllLandVars(land)
```


Collects model variable fields and subfields from the `land` NamedTuple.

**Arguments:**
- `land`: A core SINDBAD NamedTuple containing all variables for a given time step, overwritten at every timestep.
  

**Returns:**
- A tuple of variable field and subfield pairs.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getAllSindbadModels-Tuple{Any}' href='#SindbadSetup.getAllSindbadModels-Tuple{Any}'><span class="jlbinding">SindbadSetup.getAllSindbadModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAllSindbadModels(info; all_models_default=standard_sindbad_models)
```


Retrieves the list of all SINDBAD models, either from the provided `info` object or a default list.

**Arguments:**
- `info`: A NamedTuple or object containing experiment configuration and metadata.
  
- `all_models_default`: (Optional) The default list of SINDBAD models to use if `info` does not specify a custom list. Defaults to `standard_sindbad_models`.
  

**Returns:**
- A list of all SINDBAD models, either from `info.sindbad_models` (if available) or `all_models_default`.
  

**Notes:**
- If the `info` object has a property `sindbad_models`, it overrides the default list.
  
- This function ensures flexibility by allowing custom model lists to be specified in the experiment configuration.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getModelImplicitTRepeat-Tuple{NamedTuple, Any}' href='#SindbadSetup.getModelImplicitTRepeat-Tuple{NamedTuple, Any}'><span class="jlbinding">SindbadSetup.getModelImplicitTRepeat</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getModelImplicitTRepeat(info::NamedTuple, selected_models)
```


Retrieves the `implicit_t_repeat` values for the specified models from the experiment configuration.

**Arguments:**
- `info::NamedTuple`: A SINDBAD NamedTuple containing the experiment configuration, including model structure details.
  
- `selected_models`: A list of model names (symbols) for which the `implicit_t_repeat` values are to be retrieved.
  

**Returns:**
- A vector of `implicit_t_repeat` values corresponding to the `selected_models`.
  

**Notes:**
- If a model has an `implicit_t_repeat` property defined in its configuration, that value is used.
  
- If the property is not defined for a model, the default value from `info.settings.model_structure.default_model.implicit_t_repeat` is used.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getModelParameterIndices' href='#SindbadSetup.getModelParameterIndices'><span class="jlbinding">SindbadSetup.getModelParameterIndices</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getParameterIndices(selected_models::LongTuple, parameter_table::Table)
getParameterIndices(selected_models::Tuple, parameter_table::Table)
```


Retrieves indices for model parameters from a parameter table.

**Arguments**
- `selected_models`
  - `::LongTuple`: A long tuple of selected models
    
  - `::Tuple`: A tuple of selected models
    
  
- `parameter_table::Table`: Table containing parameter information
  

**Returns**

A Tuple of Pair of Name and Indices corresponding to the model parameters in the parameter table for  selected models.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getModelParameterIndices-Tuple{Any, Table, Any}' href='#SindbadSetup.getModelParameterIndices-Tuple{Any, Table, Any}'><span class="jlbinding">SindbadSetup.getModelParameterIndices</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getModelParameterIndices(model, parameter_table::Table, r)
```


Retrieves indices for model parameters from a parameter table.

**Arguments**
- `model`: A model object for which parameters are being indexed
  
- `parameter_table::Table`: Table containing parameter information
  
- `r`: Row index or identifier for the specific parameter set
  

**Returns**

Indices corresponding to the model parameters in the parameter table for a model.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getOrderedOutputList-Tuple{Any, Symbol}' href='#SindbadSetup.getOrderedOutputList-Tuple{Any, Symbol}'><span class="jlbinding">SindbadSetup.getOrderedOutputList</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getOrderedOutputList(varlist, var_o::Symbol)
```


Finds and returns the corresponding variable from the full list of variables.

**Arguments:**
- `varlist`: The full list of variables.
  
- `var_o`: The variable to find.
  

**Returns:**
- The corresponding variable from the list.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getParamModelIDVal-Tuple{Any}' href='#SindbadSetup.getParamModelIDVal-Tuple{Any}'><span class="jlbinding">SindbadSetup.getParamModelIDVal</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getParamModelIDVal(parameter_table)
```


Generates a `Val` object containing tuples of parameter names and their corresponding model IDs.

**Arguments:**
- `parameter_table`: A table of parameters with their names and model IDs.
  

**Returns:**
- A `Val` object containing tuples of parameter names and model IDs.
  

**Notes:**
- Parameter names are transformed to a unique format by replacing dots with underscores.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getPoolInformation-NTuple{8, Any}' href='#SindbadSetup.getPoolInformation-NTuple{8, Any}'><span class="jlbinding">SindbadSetup.getPoolInformation</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getPoolInformation(main_pools, pool_info, layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name; prename="")
```


A helper function to get the information of each pools from info.settings.model_structure.pools and puts them into arrays of information needed to instantiate pool variables.

**Arguments:**
- `main_pools`: A list of main pool configurations.
  
- `pool_info`: A NamedTuple containing pool information details.
  
- `layer_thicknesses`: An array of layer thicknesses in the pools.
  
- `nlayers`: An array representing the number of layers per pool in the model.
  
- `layer`: An array representing the current layer number being processed.
  
- `inits`: An array of initial values to be set in the pool.
  
- `sub_pool_name`: An array of sub-pool component names for a given pool.
  
- `main_pool_name`: An array of main pool names containing the sub-pool components.
  
- `prename`: (Optional) A prefix for naming conventions (default: `""`).
  

**Returns:**
- Updated list of information specific to the requested pool configuration.
  

**Notes:**
- Processes hierarchical pool structures and extracts relevant details for initialization.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getPoolSize-Tuple{NamedTuple, Symbol}' href='#SindbadSetup.getPoolSize-Tuple{NamedTuple, Symbol}'><span class="jlbinding">SindbadSetup.getPoolSize</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getPoolSize(info_pools::NamedTuple, pool_name::Symbol)
```


Retrieves the size of a pool variable from the model structure settings.

**Arguments:**
- `info_pools`: A NamedTuple containing information about the pools in the selected model structure.
  
- `pool_name`: The name of the pool.
  

**Returns:**
- The size of the specified pool.
  

**Notes:**
- Throws an error if the pool does not exist in the model structure.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getRootDirs-Tuple{Any, Any}' href='#SindbadSetup.getRootDirs-Tuple{Any, Any}'><span class="jlbinding">SindbadSetup.getRootDirs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getRootDirs(local_root, sindbad_experiment)
```


Determines the root directories for the SINDBAD framework and the experiment.

**Arguments:**
- `local_root`: The local root directory of the SINDBAD project.
  
- `sindbad_experiment`: The path to the experiment configuration file.
  

**Returns:**
- A NamedTuple containing the root directories for the experiment, SINDBAD, and settings.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getVariableGroups-Tuple{AbstractArray}' href='#SindbadSetup.getVariableGroups-Tuple{AbstractArray}'><span class="jlbinding">SindbadSetup.getVariableGroups</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getVariableGroups(var_list::AbstractArray)
```


Groups variables into a NamedTuple based on their field and subfield structure.

**Arguments:**
- `var_list`: A list of variables in the `field.subfield` format.
  

**Returns:**
- A NamedTuple containing grouped variables by field.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getVariablePair' href='#SindbadSetup.getVariablePair'><span class="jlbinding">SindbadSetup.getVariablePair</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getVariablePair(out_var)
```


Splits a variable name into a pair of field and subfield.

**Arguments:**
- `out_var`: The variable name, provided as either a `String` or a `Symbol`, in the format `field.subfield`.
  

**Returns:**
- A tuple containing the field and subfield as `Symbol` values.
  

**Notes:**
- If the variable name contains a comma (`,`), it is used as the separator instead of a dot (`.`).
  
- This function is used to parse variable names into their hierarchical components for further processing.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.getVariableString' href='#SindbadSetup.getVariableString'><span class="jlbinding">SindbadSetup.getVariableString</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getVariableString(var_pair)
```


Converts a variable pair into a string representation.

**Arguments:**
- `var_pair`: A tuple containing the field and subfield.
  
- `sep`: The separator to use between the field and subfield (default: &quot;.&quot;).
  

**Returns:**
- A string representation of the variable pair.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.parseSaveCode-Tuple{Any}' href='#SindbadSetup.parseSaveCode-Tuple{Any}'><span class="jlbinding">SindbadSetup.parseSaveCode</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
parseSaveCode(info)
```


Parses and saves the code and structs of the selected model structure for the given experiment.

**Arguments:**
- `info`: The experiment configuration NamedTuple containing model and output information.
  

**Notes:**
- Writes the `define`, `precompute`, and `compute` functions for the selected models to separate files.
  
- Also writes the parameter structs for the models.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.removeComments-Tuple{AbstractDict}' href='#SindbadSetup.removeComments-Tuple{AbstractDict}'><span class="jlbinding">SindbadSetup.removeComments</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
removeComments(inputDict::AbstractDict)
```


Removes unnecessary comment fields from a dictionary.

**Arguments:**
- `inputDict`: The input dictionary.
  

**Returns:**
- A new dictionary with comment fields removed.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.replaceCommaSeparatedParams-Tuple{Any}' href='#SindbadSetup.replaceCommaSeparatedParams-Tuple{Any}'><span class="jlbinding">SindbadSetup.replaceCommaSeparatedParams</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
replaceCommaSeparatedParams(p_names_list)
```


get a list/vector of parameters in which each parameter string is split with comma to separate model name and parameter name

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.replaceInfoFields-Tuple{AbstractDict, AbstractDict}' href='#SindbadSetup.replaceInfoFields-Tuple{AbstractDict, AbstractDict}'><span class="jlbinding">SindbadSetup.replaceInfoFields</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)
```


Replaces fields in the `info` dictionary with values from the `replace_dict`.

**Arguments:**
- `info::AbstractDict`: The original dictionary.
  
- `replace_dict::AbstractDict`: The dictionary containing replacement values.
  

**Returns:**
- A new dictionary with the replaced fields.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.saveExperimentSettings-Tuple{Any}' href='#SindbadSetup.saveExperimentSettings-Tuple{Any}'><span class="jlbinding">SindbadSetup.saveExperimentSettings</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
saveExperimentSettings(info)
```


Saves a copy of the experiment settings to the output folder.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Notes:**
- Copies the JSON settings and configuration files to the output directory.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.saveInfo' href='#SindbadSetup.saveInfo'><span class="jlbinding">SindbadSetup.saveInfo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
saveInfo(info, to_save::DoSaveInfo | ::DoNotSaveInfo)
```


Saves or skips saving the experiment configuration to a file.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  
- `::DoSaveInfo`: A type dispatch indicating that the information should be saved.
  
- `::DoNotSaveInfo`: A type dispatch indicating that the information should not be saved.
  

**Returns:**
- `nothing`.
  

**Notes:**
- When saving, the experiment configuration is saved as a `.jld2` file in the `settings` directory.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setDatesInfo-Tuple{NamedTuple}' href='#SindbadSetup.setDatesInfo-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setDatesInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setDatesInfo(info::NamedTuple)
```


Fills `info.temp.helpers.dates` with date and time-related fields needed in the models.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with date-related fields added.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setDebugErrorCatcher' href='#SindbadSetup.setDebugErrorCatcher'><span class="jlbinding">SindbadSetup.setDebugErrorCatcher</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
setDebugErrorCatcher(::DoCatchModelErrors | ::DoNotCatchModelErrors)
```


Enables/Disables a debug error catcher for the SINDBAD framework. When enabled, a variable `error_catcher` is enabled and can be written to from within SINDBAD models and functions. This can then be accessed from any scope with `Sindbad.error_catcher`

**Arguments:**
- `::DoCatchModelErrors`: A type dispatch indicating that model errors should be caught.
  
- `::DoNotCatchModelErrors`: A type dispatch indicating that model errors should not be caught.
  

**Returns:**
- `nothing`.
  

**Notes:**
- When enabled, sets up an empty error catcher using `Sindbad.eval`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setExperimentBasics-Tuple{Any}' href='#SindbadSetup.setExperimentBasics-Tuple{Any}'><span class="jlbinding">SindbadSetup.setExperimentBasics</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setExperimentBasics(info::NamedTuple)
```


Copies basic experiment information into the temporary experiment configuration.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with basic experiment information added.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setExperimentOutput-Tuple{Any}' href='#SindbadSetup.setExperimentOutput-Tuple{Any}'><span class="jlbinding">SindbadSetup.setExperimentOutput</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setExperimentOutput(info)
```


Sets up and creates the output directory for the experiment.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with output directory information added.
  

**Notes:**
- Creates subdirectories for code, data, figures, and settings.
  
- Validates the output path and ensures it is not within the SINDBAD root directory.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setInputParameters-Tuple{Table, Table, Any}' href='#SindbadSetup.setInputParameters-Tuple{Table, Table, Any}'><span class="jlbinding">SindbadSetup.setInputParameters</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setInputParameters(original_table::Table, input_table::Table)
```


Updates input parameters by comparing an original table with an updated table from params.json.

**Arguments**
- `original_table::Table`: The reference table containing original parameters
  
- `input_table::Table`: The table containing updated parameters to be compared with original
  

**Returns**

a merged table with updated parameters

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setModelRunInfo-Tuple{NamedTuple}' href='#SindbadSetup.setModelRunInfo-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setModelRunInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setModelRunInfo(info::NamedTuple)
```


Sets up model run flags and output array types for the experiment.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with model run flags and output array types added.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setNumericHelpers' href='#SindbadSetup.setNumericHelpers'><span class="jlbinding">SindbadSetup.setNumericHelpers</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
setNumericHelpers(info::NamedTuple, ttype)
```


Prepares numeric helpers for maintaining consistent data types across models.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  
- `ttype`: The numeric type to use (default: `info.settings.experiment.exe_rules.model_number_type`).
  

**Returns:**
- The updated `info` NamedTuple with numeric helpers added.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setRestartFilePath-Tuple{NamedTuple}' href='#SindbadSetup.setRestartFilePath-Tuple{NamedTuple}'><span class="jlbinding">SindbadSetup.setRestartFilePath</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setRestartFilePath(info::NamedTuple)
```


Validates and sets the absolute path for the restart file used in spinup.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with the absolute restart file path set.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.setSpinupInfo-Tuple{Any}' href='#SindbadSetup.setSpinupInfo-Tuple{Any}'><span class="jlbinding">SindbadSetup.setSpinupInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setSpinupInfo(info::NamedTuple)
```


Processes the spinup configuration and prepares the spinup sequence.

**Arguments:**
- `info`: A NamedTuple containing the experiment configuration.
  

**Returns:**
- The updated `info` NamedTuple with spinup-related fields added.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadSetup.splitRenameParam' href='#SindbadSetup.splitRenameParam'><span class="jlbinding">SindbadSetup.splitRenameParam</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
splitRenameParam(p_string::String, _splitter)
splitRenameParam(_p::Symbol, _splitter)
```


Splits and renames a parameter based on a specified splitter.

**Arguments**
- `p_string`: The input parameter to be split and renamed
  - `::String`: The parameter string to be split
    
  - `::Symbol`: The parameter symbol to be split
    
  
- `_splitter`: The delimiter used to split the parameter string
  

**Returns**

A tuple containing the split and renamed parameter components.

</details>

