<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment' href='#SindbadExperiment'><span class="jlbinding">SindbadExperiment</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadExperiment
```


The `SindbadExperiment` package provides tools for designing, running, and analyzing experiments in the SINDBAD MDI framework. It integrates SINDBAD packages and utilities to streamline the experimental workflow, from data preparation to model execution and output analysis.

**Purpose:**

This package acts as a high-level interface for conducting experiments using the SINDBAD framework. It leverages the functionality of core SINDBAD packages and provides additional utilities for running experiments and managing outputs.

**Dependencies:**
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `SindbadUtils`: Provides utility functions for handling data, spatial operations, and other helper tasks.
  
- `SindbadSetup`: Manages setup configurations, parameter handling, and shared types for SINDBAD experiments.
  
- `SindbadData`: Handles data ingestion, preprocessing, and management for SINDBAD experiments.
  
- `SindbadTEM`: Implements the SINDBAD Terrestrial Ecosystem Model (TEM), enabling simulations for single locations, spatial grids, and cubes.
  
- `SindbadOptimization`: Provides optimization algorithms for parameter estimation and model calibration.
  
- `SindbadMetrics`: Supplies metrics for evaluating model performance and comparing simulations with observations.
  

**Included Files:**
1. **`runExperiment.jl`**:
  - Contains functions for executing experiments, including setting up models, running simulations, and managing workflows.
    
  
2. **`saveOutput.jl`**:
  - Provides utilities for saving experiment outputs in various formats, ensuring compatibility with downstream analysis tools.
    
  

**Notes:**
- The package re-exports core SINDBAD packages (`Sindbad`, `SindbadUtils`, `SindbadSetup`, `SindbadData`, `SindbadTEM`, `SindbadOptimization`, `SindbadMetrics`) for convenience, allowing users to access their functionality directly through `SindbadExperiment`.
  
- Designed to be extensible, enabling users to customize and expand the experimental workflow as needed.
  
- Future extensions may include support for additional data formats (e.g., NetCDF, Zarr) and advanced output handling.
  

**Examples:**
1. **Running an experiment**:
  

```julia
using SindbadExperiment
# Set up experiment parameters
experiment_config = ...

# Run the experiment
runExperimentForward(experiment_config)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/SindbadExperiment.jl#L1-L40" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.prepExperiment-Tuple{String}' href='#SindbadExperiment.prepExperiment-Tuple{String}'><span class="jlbinding">SindbadExperiment.prepExperiment</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
prepExperiment(sindbad_experiment::String; replace_info::Dict=Dict())
```


Prepare experiment configuration, forcing data, and output settings.

**Arguments**
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  

**Returns**
- `info::NamedTuple`: A NamedTuple containing the experiment configuration
  
- `forcing::NamedTuple`: A NamedTuple containing the forcing data
  

**Description**

This function initializes an experiment by:
1. Reading and processing the experiment configuration
  
2. Setting up forcing data based on the configuration
  
3. Preparing output settings
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L10-L28" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperiment' href='#SindbadExperiment.runExperiment'><span class="jlbinding">SindbadExperiment.runExperiment</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
runExperiment(info::NamedTuple, forcing::NamedTuple, mode::RunFlag)
```


Run a SINDBAD experiment in different modes.

**Arguments**
- `info::NamedTuple`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment
  
- `forcing::NamedTuple`: A forcing NamedTuple containing the forcing time series set for ALL locations
  
- `mode::RunFlag`: Type dispatch parameter determining the mode of experiment:
  - `DoCalcCost`: Calculate cost between model output and observations
    
  - `DoRunForward`: Run forward simulation without optimization
    
  - `DoNotRunOptimization`: Run without optimization
    
  - `DoRunOptimization`: Run with optimization enabled
    
  

**Returns**
- For `DoCalcCost` mode:
  - `(; forcing, info, loss=loss_vector, observation=obs_array, output=forward_output)`
    
  
- For `DoRunForward` or `DoNotRunOptimization` mode:
  - `(; forcing, info, output=run_output)`
    
  
- For `DoRunOptimization` mode:
  - `(; forcing, info, observation=obs_array, params=run_output)`
    
  

**Description**

This function is the main entry point for running SINDBAD experiments. It supports different modes of simulation:
- Cost calculation: Compares model output with observations
  
- Forward run: Executes the model without optimization
  
- Optimization: Runs the model with parameter optimization
  

The function handles different spatial configurations and can operate on both single-pixel and spatial domains.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L49-L78" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperimentCost-Tuple{String}' href='#SindbadExperiment.runExperimentCost-Tuple{String}'><span class="jlbinding">SindbadExperiment.runExperimentCost</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runExperimentCost(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)
```


Calculate cost for a given experiment through the `runExperiment` function in `DoCalcCost` mode.

**Arguments**
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  
- `log_level::Symbol`: Logging level (default: :info)
  

**Returns**
- A NamedTuple containing the experiment results including cost calculations
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L137-L149" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperimentForward-Tuple{String}' href='#SindbadExperiment.runExperimentForward-Tuple{String}'><span class="jlbinding">SindbadExperiment.runExperimentForward</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runExperimentForward(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)
```


Run forward simulation for a given experiment through the `runExperiment` function in `DoRunForward` mode.

**Arguments**
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  
- `log_level::Symbol`: Logging level (default: :info)
  

**Returns**
- A NamedTuple containing the experiment results including model outputs
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L162-L174" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperimentForwardParams-Tuple{Vector, String}' href='#SindbadExperiment.runExperimentForwardParams-Tuple{Vector, String}'><span class="jlbinding">SindbadExperiment.runExperimentForwardParams</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runExperimentForwardParams(params_vector::Vector, sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)
```


Run forward simulation of the model with default as well as modified settings with input/optimized parameters through call of the `runTEM!` function.

**Arguments**
- `params_vector::Vector`: Vector of parameters to use for the simulation
  
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  
- `log_level::Symbol`: Logging level (default: :info)
  

**Returns**
- A NamedTuple containing both default and optimized model outputs
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L191-L204" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperimentFullOutput-Tuple{String}' href='#SindbadExperiment.runExperimentFullOutput-Tuple{String}'><span class="jlbinding">SindbadExperiment.runExperimentFullOutput</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runExperimentFullOutput(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)
```


Run forward simulation of the model through `runExperiment` function in `DoRunForward` mode but with all output variables saved.

**Arguments**
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  
- `log_level::Symbol`: Logging level (default: :info)
  

**Returns**
- A NamedTuple containing the complete model outputs
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L232-L244" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperimentOpti-Tuple{String}' href='#SindbadExperiment.runExperimentOpti-Tuple{String}'><span class="jlbinding">SindbadExperiment.runExperimentOpti</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runExperimentOpti(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:warn)
```


Run optimization experiment through `runExperiment` function in `DoRunOptimization` mode, followed by forward run with optimized parameters.

**Arguments**
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  
- `log_level::Symbol`: Logging level (default: :warn)
  

**Returns**
- A NamedTuple containing optimization results, model outputs, and cost metrics
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L265-L277" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.runExperimentSensitivity-Tuple{String}' href='#SindbadExperiment.runExperimentSensitivity-Tuple{String}'><span class="jlbinding">SindbadExperiment.runExperimentSensitivity</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runExperimentSensitivity(sindbad_experiment::String; replace_info::Dict=Dict(), batch::Bool=true, log_level::Symbol=:warn)
```


Run sensitivity analysis for a given experiment.

**Arguments**
- `sindbad_experiment::String`: Path to the experiment configuration file
  
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
  
- `batch::Bool`: Whether to run sensitivity analysis in batch mode (default: true)
  
- `log_level::Symbol`: Logging level (default: :warn)
  

**Returns**
- A NamedTuple containing sensitivity analysis results and related data
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/runExperiment.jl#L299-L312" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.saveOutCubes' href='#SindbadExperiment.saveOutCubes'><span class="jlbinding">SindbadExperiment.saveOutCubes</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
saveOutCubes(data_path_base, global_metadata, var_pairs, data, data_dims, out_format, t_step, <: OutputStrategy)
saveOutCubes(info, out_cubes, output_dims, output_vars)
```


saves the output variables from the run as one file

**Arguments:**
- `data_path_base`: base path of the output file including the directory and file prefix
  
- `global_metadata`: a collection of  global metadata information to write to the output file
  
- `data`: data to be written to file
  
- `data_dims`: a vector of dimension of data for each variable to be written to a file
  
- `var_pairs`: a tuple of pairs of sindbad variables to write including the field and subfield of land as the first and last element
  
- `out_format`: format of the output file
  
- `t_step`: a string for time step of the model run to be used in the units attribute of variables
  
- `<: OutputStrategy`: Dispatch type indicating file output mode with the following options:
  - `::DoSaveSingleFile`: single file with all the variables
    
  - `::DoNotSaveSingleFile`: single file per variable
    
  

**note: this function is overloaded to handle different dispatch types and the version with fewer arguments is used as a shorthand for the single file output mode**


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/saveOutput.jl#L49-L68" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.getModelDataArray-Union{Tuple{AbstractArray{<:Any, N}}, Tuple{N}} where N' href='#SindbadExperiment.getModelDataArray-Union{Tuple{AbstractArray{<:Any, N}}, Tuple{N}} where N'><span class="jlbinding">SindbadExperiment.getModelDataArray</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



Converts an N-dimensional array of any size into a output-compatible data array without the unnecessary dimension.

**Arguments**
- `_dat::AbstractArray{<:Any,N}`: Input N-dimensional array of arbitrary type
  

**Returns**

Output-compatible data array


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/saveOutput.jl#L4-L12" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadExperiment.getYaxForVariable-NTuple{5, Any}' href='#SindbadExperiment.getYaxForVariable-NTuple{5, Any}'><span class="jlbinding">SindbadExperiment.getYaxForVariable</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getYaxForVariable(data_out, data_dim, variable_name, catalog_name, t_step)
```


Processes YAXArray for a specific variable from simulation output.

**Arguments**
- `data_out`: Output data from the simulation
  
- `data_dim`: Dimensions of the data output variable
  
- `variable_name`: Name of the variable to save as
  
- `catalog_name`: Name in the SINDBAD catalog of variables
  
- `t_step`: Time resolution for which to extract the data
  

**Returns**

YAXArray specified variable at the given time resolution.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadExperiment/src/saveOutput.jl#L24-L38" target="_blank" rel="noreferrer">source</a></Badge>

</details>

