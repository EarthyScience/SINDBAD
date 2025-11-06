<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals' href='#SindbadVisuals'><span class="jlbinding">SindbadVisuals</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



**SindbadVisuals Module**

The `SindbadVisuals` module provides visualization tools and helpers for the SINDBAD output analysis. While still under development, the aim is to provide comprehensive tools for visualizing and understanding the behavior of models within the SINDBAD framework.

**Features**
- **Output Data Visualization**: Tools for plotting model outputs and diagnostics of hybrid experimetn.
  
- **Input-Output Relationships**: Functions for visualizing input-output structures of models.
  
- **Interactive Plots**: Support for interactive visualizations using `GLMakie`.
  
- **Static Plots**: Support for static visualizations using `Plots`.
  

**Dependencies**
- `Sindbad`: Core SINDBAD framework.
  
- `SindbadUtils`: Utility functions for SINDBAD.
  
- `Plots`: For static plotting.
  

**Expected but not currently installed due to compatilibity in BGC cluster**
- `GLMakie`: For interactive plotting.
  
- `Colors`: For color management in plots.
  

**Included Files**
- `plotOutputData.jl`: Contains functions for visualizing model output data.
  
- `plotFromSindbadInfo.jl`: Contains functions for visualizing input-output relationships and other metadata from `SINDBAD info`.
  

**Usage**

To use the module, simply import it:

```julia
using SindbadVisuals
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/SindbadVisuals.jl#L1-L30" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.namedTupleToFlareJSON-Tuple{NamedTuple}' href='#SindbadVisuals.namedTupleToFlareJSON-Tuple{NamedTuple}'><span class="jlbinding">SindbadVisuals.namedTupleToFlareJSON</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
namedTupleToFlareJSON(info::NamedTuple)
```


Convert a nested NamedTuple into a flare.json format suitable for d3.js visualization.

**Arguments**
- `info::NamedTuple`: The input NamedTuple to convert
  

**Returns**
- A dictionary in flare.json format with the following structure:
  
  ```json
  {
    "name": "root",
    "children": [
      {
        "name": "field1",
        "children": [...]
      },
      {
        "name": "field2",
        "value": 42
      }
    ]
  }
  ```
  
  

**Notes**
- The function recursively traverses the NamedTuple structure
  
- Fields with no children are treated as leaf nodes with a value of 1
  
- The structure is flattened to show the full path to each field
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotFromSindbadInfo.jl#L37-L67" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.plotIOModelStructure' href='#SindbadVisuals.plotIOModelStructure'><span class="jlbinding">SindbadVisuals.plotIOModelStructure</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
plotIOModelStructure(info, which_function=:compute, which_field=[:input, :output])
```


Generates a visualization of the input-output (IO) structure of the selected models in the SINDBAD framework.

This function creates a grid-based visualization of the input-output relationships for the specified models. It identifies unique variables across the specified fields (`which_field`) and maps them to the corresponding models. The visualization highlights:

**Arguments**
- `info`: A `NamedTuple` containing experiment information, including model configurations and metadata.
  
- `which_function`: A `Symbol` specifying the function to analyze (default: `:compute`).
  
- `which_field`: A `Symbol` or an array of `Symbol`s specifying the fields to visualize (e.g., `:input`, `:output`; default: `[:input, :output]`).
  

**Returns**
- A plot object visualizing the IO structure of the selected models.
  

**Description**
- Input variables (`:input`) with &quot;□&quot; marker.
  
- Output variables (`:output`) with &quot;x&quot; marker style.
  

**Example**

```julia
info = prepExperiment("path/to/experiment/config")
plotIOModelStructure(info, :compute, [:input, :output])
```


**Notes**
- The function assumes that the info object contains a valid model structure and experiment metadata.
  
- The plot includes annotations, grid lines, and legends for clarity.
  
- The generated plot is saved as a PDF file in the experiment&#39;s output directory.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotFromSindbadInfo.jl#L88-L120" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.plotPerformanceHistograms-Tuple{Any}' href='#SindbadVisuals.plotPerformanceHistograms-Tuple{Any}'><span class="jlbinding">SindbadVisuals.plotPerformanceHistograms</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
plotPerformanceHistograms(out_opti)
```


Generate performance histograms based on optimization output data.

**Arguments**
- `out_opti`: Optimization output data structure containing model outputs and information
  

**Description**

Creates histogram plots to visualize the distribution of  performance metrics from optimization results.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotOutputUsingPlots.jl#L5-L15" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.plotTimeSeriesDebug-Tuple{Any, Any, Any}' href='#SindbadVisuals.plotTimeSeriesDebug-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadVisuals.plotTimeSeriesDebug</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
plotTimeSeriesDebug(info, opt_dat, def_dat)
```


Plot debugging figures for model outputs.

**Arguments**
- `info`: Information structure containing experiment details
  
- `opt_dat`: Optimized model output data
  
- `def_dat`: Default model output data
  

**Description**

This function generates debugging figures by plotting the optimized and default model outputs for each variable specified in the experiment&#39;s output variables list. It calculates the mean of the model outputs across layers and then plots them against time using Plots.jl. Debugging figures are saved in a directory specified by `info.output.dirs.figure`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotOutputUsingPlots.jl#L134-L143" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.plotTimeSeriesWithObs-Tuple{Any, Any, Any}' href='#SindbadVisuals.plotTimeSeriesWithObs-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadVisuals.plotTimeSeriesWithObs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
plotTimeSeriesWithObs(out,obs_array,cost_options,info)
```


Generate time series plots comparing optimized and default model outputs with observations.

**Arguments**
- `out_opti`: Optimization output data structure containing model outputs and information
  

**Description**

Generates time series plots that compare the optimized and default model outputs with observations. The function iterates over each variable specified in the cost options and creates a separate plot for each one. Each plot displays the observed data as scatter points, along with the default and optimized model outputs as line graphs. Additionally, it includes vertical lines indicating the calculated loss metric values for both the default and optimized models.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotOutputUsingPlots.jl#L179-L186" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.plotTimeSeriesWithObs-Tuple{Any}' href='#SindbadVisuals.plotTimeSeriesWithObs-Tuple{Any}'><span class="jlbinding">SindbadVisuals.plotTimeSeriesWithObs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
plotTimeSeriesWithObs(out_opti)
```


Generate time series plots comparing optimized and default model outputs with observations.

**Arguments**
- `out_opti`: Optimization output data structure containing model outputs and information
  

**Description**

Generates time series plots that compare the optimized and default model outputs with observations. The function iterates over each variable specified in the cost options and creates a separate plot for each one. Each plot displays the observed data as scatter points, along with the default and optimized model outputs as line graphs. Additionally, it includes vertical lines indicating the calculated loss metric values for both the default and optimized models.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotOutputUsingPlots.jl#L68-L75" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadVisuals.getAllVariables-Tuple{Any, Any}' href='#SindbadVisuals.getAllVariables-Tuple{Any, Any}'><span class="jlbinding">SindbadVisuals.getAllVariables</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAllVariables(in_out_models, which_field)
```


Extracts all unique variables from the input-output of the models in selected model structure for the specified field(s).

**Arguments**
- `in_out_models`: A dictionary containing input-output of models, where keys are model names and values are dictionaries of fields (e.g., `:input`, `:output`).
  
- `which_field`: A `Symbol` or an array of `Symbol`s specifying the field(s) to extract variables from (e.g., `:input`, `:output`).
  

**Returns**
- A sorted array of unique variables across all specified fields.
  

**Example**

```julia
in_out_models = Dict(
    :model1 => Dict(:input => [:var1, :var2], :output => [:var3]),
    :model2 => Dict(:input => [:var2, :var4], :output => [:var5])
)
unique_vars = getAllVariables(in_out_models, [:input, :output])
println(unique_vars)  # Output: [:var1, :var2, :var3, :var4, :var5]
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadVisuals/src/plotFromSindbadInfo.jl#L4-L25" target="_blank" rel="noreferrer">source</a></Badge>

</details>

