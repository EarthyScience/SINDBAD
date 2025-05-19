<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM' href='#SindbadTEM'><span class="jlbinding">SindbadTEM</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadTEM
```


The `SindbadTEM` package provides the core functionality for running the SINDBAD Terrestrial Ecosystem Model (TEM). It includes utilities for preparing model-ready objects, managing spinup processes and running models.

**Purpose:**

This package integrates various components and utilities required to execute the SINDBAD TEM, including precomputations, spinup, and time loop simulations. It supports parallel execution and efficient handling of large datasets.

**Dependencies:**
- `ComponentArrays`: Used for managing complex, hierarchical data structures like land variables and model states.
  
- `NLsolve`: Used for solving nonlinear equations, particularly in spinup processes (e.g., fixed-point solvers).
  
- `ProgressMeter`: Displays progress bars for long-running simulations, improving user feedback.
  
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `SindbadData`: Provides the SINDBAD data handling functions.
  
- `SindbadUtils`: Provides utility functions for handling NamedTuple, spatial operations, and other helper tasks for spatial and temporal operations.
  
- `SindbadSetup`: Provides the SINDBAD setup functions.
  
- `ThreadPools`: Enables efficient thread-based parallelization for running simulations across multiple locations.
  

**Included Files:**
1. **`utilsTEM.jl`**:
  - Contains utility functions for handling extraction of forcing data, managing/filling outputs, and other helper operations required during TEM execution.
    
  
2. **`deriveSpinupForcing.jl`**:
  - Provides functionality for deriving spinup forcing data, which is used to force the model during initialization to a steady state.
    
  
3. **`prepTEMOut.jl`**:
  - Handles the preparation of output structures, ensuring that results are stored efficiently during simulations.
    
  
4. **`runModels.jl`**:
  - Contains functions for executing individual models within the SINDBAD framework.
    
  
5. **`prepTEM.jl`**:
  - Prepares the necessary inputs and configurations for running the TEM, including spatial and temporal data preparation.
    
  
6. **`runTEMLoc.jl`**:
  - Implements the logic for running the TEM for a single location, including optional spinup and the main simulation loop.
    
  
7. **`runTEMSpace.jl`**:
  - Extends the functionality to handle spatial grids, enabling simulations across multiple locations with parallel execution.
    
  
8. **`runTEMCube.jl`**:
  - Adds support for running the TEM on 3D data YAXArrayscubes, useful for large-scale simulations with spatial dimensions.
    
  
9. **`spinupTEM.jl`**:
  - Manages the spinup process, initializing the model to a steady state using various methods (e.g., ODE solvers, fixed-point solvers).
    
  
10. **`spinupSequence.jl`**:
  - Handles sequential spinup loops, allowing for iterative refinement of model states during the spinup process.
    
  

**Notes:**
- The package is designed to be modular and extensible, allowing users to customize and extend its functionality for specific use cases.
  
- It integrates tightly with the SINDBAD framework, leveraging shared types and utilities from `SindbadSetup`.
  

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.TEMYax-Tuple' href='#SindbadTEM.TEMYax-Tuple'><span class="jlbinding">SindbadTEM.TEMYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
TEMYax(map_cubes; loc_land::NamedTuple, tem::NamedTuple, selected_models::Tuple, forcing_vars::AbstractArray)
```


**Arguments:**
- `map_cubes`: collection/tuple of all input and output cubes from mapCube
  
- `loc_land`: initial SINDBAD land with all fields and subfields
  
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
  
- `selected_models`: a tuple of all models selected in the given model structure
  
- `forcing_vars`: forcing variables
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.computeTEM-Tuple{LongTuple, Any, Any, Any}' href='#SindbadTEM.computeTEM-Tuple{LongTuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.computeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
computeTEM(models, forcing, land, model_helpers)
```


run the compute function of SINDBAD models

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.computeTEM-Tuple{Tuple, Any, Any, Any, DoDebugModel}' href='#SindbadTEM.computeTEM-Tuple{Tuple, Any, Any, Any, DoDebugModel}'><span class="jlbinding">SindbadTEM.computeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
computeTEM(models, forcing, land, model_helpers, ::DoDebugModel)
```


debug the compute function of SINDBAD models

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::DoDebugModel`: a type dispatch to debug the compute functions of model
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.computeTEM-Tuple{Tuple, Any, Any, Any, DoNotDebugModel}' href='#SindbadTEM.computeTEM-Tuple{Tuple, Any, Any, Any, DoNotDebugModel}'><span class="jlbinding">SindbadTEM.computeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
computeTEM(models, forcing, land, model_helpers, ::DoNotDebugModel)
```


run the compute function of SINDBAD models

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::DoNotDebugModel`: a type dispatch to not debug but run the compute functions of model
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.computeTEM-Tuple{Tuple, Any, Any, Any}' href='#SindbadTEM.computeTEM-Tuple{Tuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.computeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
computeTEM(models, forcing, land, model_helpers)
```


run the compute function of SINDBAD models

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.coreTEM' href='#SindbadTEM.coreTEM'><span class="jlbinding">SindbadTEM.coreTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
coreTEM(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_land, tem_info, spinup_mode)
```


Runs the SINDBAD Terrestrial Ecosystem Model (TEM) for a single location, with or without spinup, based on the specified `spinup_mode`.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `loc_forcing`: A forcing NamedTuple containing the time series of environmental drivers for a single location.
  
- `loc_spinup_forcing`: A forcing NamedTuple for spinup, used to initialize the model to a steady state (only used if spinup is enabled).
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `loc_land`: Initial SINDBAD land NamedTuple with all fields and subfields.
  
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
  
- `spinup_mode`: A type that determines whether spinup is included or excluded
  

**Returns:**
- `land_time_series`: A vector of SINDBAD land states for each time step after the model simulation.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.coreTEM!-NTuple{7, Any}' href='#SindbadTEM.coreTEM!-NTuple{7, Any}'><span class="jlbinding">SindbadTEM.coreTEM!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
coreTEM!(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, loc_land, tem_info)
```


Executes the core SINDBAD Terrestrial Ecosystem Model (TEM) for a single location, including precomputations, spinup, and the main time loop.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `loc_forcing`: A forcing NamedTuple containing the time series of environmental drivers for a single location.
  
- `loc_spinup_forcing`: A forcing NamedTuple for spinup, used to initialize the model to a steady state (only used if spinup is enabled).
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `loc_output`: An output array or view for storing the model outputs for a single location.
  
- `loc_land`: Initial SINDBAD land NamedTuple with all fields and subfields.
  
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
  

**Details**

Executes the main TEM simulation logic with the provided parameters and data. Handles both regular simulation and spinup modes based on the spinup_mode flag.

**Extended help**
- **Precomputations**:
  - The function runs `precomputeTEM` to prepare the land state for the simulation.
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.definePrecomputeTEM-Tuple{LongTuple, Any, Any, Any}' href='#SindbadTEM.definePrecomputeTEM-Tuple{LongTuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.definePrecomputeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
definePrecomputeTEM(models::LongTuple, forcing, land, model_helpers)
```


run the precompute function of SINDBAD models to instantiate all fields of land

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.definePrecomputeTEM-Tuple{Tuple, Any, Any, Any}' href='#SindbadTEM.definePrecomputeTEM-Tuple{Tuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.definePrecomputeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
definePrecomputeTEM(models, forcing, land, model_helpers)
```


run the define and precompute functions of SINDBAD models to instantiate all fields of land

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getAllSpinupForcing-Tuple{Any, Vector{SpinupSequenceWithAggregator}, Any}' href='#SindbadTEM.getAllSpinupForcing-Tuple{Any, Vector{SpinupSequenceWithAggregator}, Any}'><span class="jlbinding">SindbadTEM.getAllSpinupForcing</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAllSpinupForcing(forcing, spin_seq, tem_helpers)
```


prepare the spinup forcing all forcing setups in the spinup sequence

**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `spin_seq`: a sequence of information to carry out spinup at different steps with information on models to use, forcing, stopping critera, etc.
  
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getDeltaPool-Tuple{AbstractArray, Any, Any}' href='#SindbadTEM.getDeltaPool-Tuple{AbstractArray, Any, Any}'><span class="jlbinding">SindbadTEM.getDeltaPool</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getDeltaPool(pool_dat::AbstractArray, spinup_info, t)
```


helper function to run the spinup models and return the delta in a given pool over the simulation. Used in solvers from DifferentialEquations.jl.

**Arguments:**
- `pool_dat`: new values of the storage pools
  
- `spinup_info`: NT with all the necessary information to run the spinup models
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getForcingForTimeStep-Union{Tuple{forc_with_type}, Tuple{Any, Any, Any, Val{forc_with_type}}} where forc_with_type' href='#SindbadTEM.getForcingForTimeStep-Union{Tuple{forc_with_type}, Tuple{Any, Any, Any, Val{forc_with_type}}} where forc_with_type'><span class="jlbinding">SindbadTEM.getForcingForTimeStep</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getForcingForTimeStep(forcing, loc_forcing_t, ts, Val{forc_with_type})
```


Get forcing values for a specific time step based on the forcing type.

**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `loc_forcing_t`: a forcing NT for a single timestep to be reused in every time step
  
- `ts`: time step to get the forcing for
  
- `forc_with_type`: Value type parameter specifying the forcing type
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getLocData-Tuple{AbstractArray, Any}' href='#SindbadTEM.getLocData-Tuple{AbstractArray, Any}'><span class="jlbinding">SindbadTEM.getLocData</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getLocData(forcing, output_array, loc_ind)
```


**Arguments:**
- `output_array`: an output array/view for ALL locations
  
- `loc_ind`: a tuple with the spatial indices of the data for a given location
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getLocData-Tuple{NamedTuple, AbstractArray, Any}' href='#SindbadTEM.getLocData-Tuple{NamedTuple, AbstractArray, Any}'><span class="jlbinding">SindbadTEM.getLocData</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getLocData(forcing, output_array, loc_ind)
```


**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `output_array`: an output array/view for ALL locations
  
- `loc_ind`: a tuple with the spatial indices of the data for a given location
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getLocData-Tuple{NamedTuple, Any}' href='#SindbadTEM.getLocData-Tuple{NamedTuple, Any}'><span class="jlbinding">SindbadTEM.getLocData</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getLocData(forcing, output_array, loc_ind)
```


**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `loc_ind`: a tuple with the spatial indices of the data for a given location
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getOutDims' href='#SindbadTEM.getOutDims'><span class="jlbinding">SindbadTEM.getOutDims</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getOutDims(info, forcing_helpers[, ::OutputArray | ::OutputMArray | ::OutputSizedArray | ::OutputYAXArray])
```


Retrieves the dimensions for SINDBAD output based on the specified array backend.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `forcing_helpers`: A NamedTuple with information on forcing sizes and dimensions.
  
- `::OutputArray`: (Optional) A type dispatch for using a base Array as the array backend.
  
- `::OutputMArray`: (Optional) A type dispatch for using MArray as the array backend.
  
- `::OutputSizedArray`: (Optional) A type dispatch for using SizedArray as the array backend.
  
- `::OutputYAXArray`: (Optional) A type dispatch for using YAXArray as the array backend.
  

**Returns:**
- A vector of output dimensions, where each dimension is represented as a tuple of `Dim` objects.
  

**Notes:**
- For `OutputArray`, `OutputMArray`, and `OutputSizedArray`, all dimensions are included.
  
- For `OutputYAXArray`, spatial dimensions are excluded, and metadata is added for each variable.
  

**Examples:**
1. **Using a base Array**:
  

```julia
outdims = getOutDims(info, forcing_helpers, OutputArray())
```

1. **Using YAXArray**:
  

```julia
outdims = getOutDims(info, forcing_helpers, OutputYAXArray())
```

1. **Default behavior**:
  

```julia
outdims = getOutDims(info, forcing_helpers)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getOutDimsArrays' href='#SindbadTEM.getOutDimsArrays'><span class="jlbinding">SindbadTEM.getOutDimsArrays</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getOutDimsArrays(info, forcing_helpers[, ::OutputArray | ::OutputMArray | ::OutputSizedArray | ::OutputYAXArray])
```


Retrieves the dimensions and corresponding data for SINDBAD output based on the specified array backend.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `forcing_helpers`: A NamedTuple with information on forcing sizes and dimensions.
  
- `::OutputArray`: (Optional) A type dispatch for using a base Array as the array backend.
  
- `::OutputMArray`: (Optional) A type dispatch for using MArray as the array backend.
  
- `::OutputSizedArray`: (Optional) A type dispatch for using SizedArray as the array backend.
  
- `::OutputYAXArray`: (Optional) A type dispatch for using YAXArray as the array backend.
  

**Returns:**
- A tuple `(outdims, outarray)`:
  - `outdims`: A vector of output dimensions, where each dimension is represented as a tuple of `Dim` objects.
    
  - `outarray`: The corresponding data array, initialized based on the specified array backend.
    
  

**Notes:**
- For `OutputArray`, `OutputMArray`, and `OutputSizedArray`, the data array is initialized with the appropriate backend type.
  
- For `OutputYAXArray`, the data array is set to `nothing`, as YAXArray handles data differently.
  

**Examples:**
1. **Using a base Array**:
  

```julia
outdims, outarray = getOutDimsArrays(info, forcing_helpers, OutputArray())
```

1. **Using MArray**:
  

```julia
outdims, outarray = getOutDimsArrays(info, forcing_helpers, OutputMArray())
```

1. **Using SizedArray**:
  

```julia
outdims, outarray = getOutDimsArrays(info, forcing_helpers, OutputSizedArray())
```

1. **Using YAXArray**:
  

```julia
outdims, outarray = getOutDimsArrays(info, forcing_helpers, OutputYAXArray())
```

1. **Default behavior**:
  

```julia
outdims, outarray = getOutDimsArrays(info, forcing_helpers)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSequence-Tuple{Any, Any}' href='#SindbadTEM.getSequence-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.getSequence</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSequence(year_disturbance, nrepeat_base=200, year_start = 1979)
```


**Arguments:**
- `year_disturbance`: a year date, as an string
  
- `nrepeat_base`=200 [default]
  
- `year_start`: 1979 [default] start year, as an interger
  

**Outputs**
- new spinup sequence object
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSpatialInfo' href='#SindbadTEM.getSpatialInfo'><span class="jlbinding">SindbadTEM.getSpatialInfo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getSpatialInfo(forcing_helpers)
getSpatialInfo(forcing, filterNanPixels)
```


get the information of the indices of the data to run the model for. The second variant additionally filter pixels with all nan data

**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSpinupInfo-NTuple{7, Any}' href='#SindbadTEM.getSpinupInfo-NTuple{7, Any}'><span class="jlbinding">SindbadTEM.getSpinupInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, spinup_pool_name, tem_info, tem_spinup)
```


helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.

**Arguments:**
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
  
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
  
- `loc_forcing_t`: a forcing NT for a single location and a single time step
  
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
  
- `spinup_pool_name`: name of the land.pool storage component intended for spinup
  
- `tem_info`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.precomputeTEM-Tuple{LongTuple, Any, Any, Any}' href='#SindbadTEM.precomputeTEM-Tuple{LongTuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.precomputeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
precomputeTEM(models, forcing, land, model_helpers)
```


run the precompute function of SINDBAD models to instantiate all fields of land

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.precomputeTEM-Tuple{Tuple, Any, Any, Any, DoDebugModel}' href='#SindbadTEM.precomputeTEM-Tuple{Tuple, Any, Any, Any, DoDebugModel}'><span class="jlbinding">SindbadTEM.precomputeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
precomputeTEM(models, forcing, land, model_helpers, ::DoDebugModel)
```


debug the precompute function of SINDBAD models

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::DoDebugModel`: a type dispatch to debug the compute functions of model
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.precomputeTEM-Tuple{Tuple, Any, Any, Any, DoNotDebugModel}' href='#SindbadTEM.precomputeTEM-Tuple{Tuple, Any, Any, Any, DoNotDebugModel}'><span class="jlbinding">SindbadTEM.precomputeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
precomputeTEM(models, forcing, land, model_helpers, ::DoNotDebugModel)
```


run the precompute function of SINDBAD models

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::DoNotDebugModel`: a type dispatch to not debug but run the compute functions of model
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.precomputeTEM-Tuple{Tuple, Any, Any, Any}' href='#SindbadTEM.precomputeTEM-Tuple{Tuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.precomputeTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
precomputeTEM(models, forcing, land, model_helpers)
```


run the precompute function of SINDBAD models to instantiate all fields of land

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.prepTEM' href='#SindbadTEM.prepTEM'><span class="jlbinding">SindbadTEM.prepTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
prepTEM(forcing::NamedTuple, info::NamedTuple)
prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)
prepTEM(selected_models, forcing::NamedTuple, observations::NamedTuple, info::NamedTuple)
```


Prepares the SINDBAD Terrestrial Ecosystem Model (TEM) for execution by setting up the necessary inputs, outputs, and configurations with different variants for different experimental setups.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
  
- `observations::NamedTuple`: A NamedTuple containing observational data for model validation.
  
- `info::NamedTuple`: A nested NamedTuple containing necessary information, including:
  - Helpers for running the model.
    
  - Model configurations.
    
  - Spinup settings.
    
  

**Returns:**
- `run_helpers`: A NamedTuple containing preallocated data and configurations required to run the TEM, including:
  - Spatial forcing data.
    
  - Spinup forcing data.
    
  - Output arrays.
    
  - Land variables.
    
  - Temporal and spatial indices.
    
  - Model and helper configurations.
    
  

**Notes:**
- The function dynamically prepares the required data structures based on the specified `PreAllocputType` in `info.helpers.run.land_output_type`.
  
- It handles spatial and temporal data preparation, including filtering NaN pixels, initializing land variables, and setting up forcing and output arrays.
  
- This function is a key step in preparing the SINDBAD TEM for execution.
  

**Examples:**
1. **Preparing TEM with observations**:
  

```julia
selected_models = (model1, model2)
forcing = (data = ..., variables = ...)
observations = (data = ..., variables = ...)
info = (helpers = ..., models = ..., spinup = ...)
run_helpers = prepTEM(selected_models, forcing, observations, info)
```

1. **Preparing TEM without observations**:
  

```julia
selected_models = (model1, model2)
forcing = (data = ..., variables = ...)
info = (helpers = ..., models = ..., spinup = ...)
run_helpers = prepTEM(selected_models, forcing, info)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.prepTEMOut-Tuple{NamedTuple, NamedTuple}' href='#SindbadTEM.prepTEMOut-Tuple{NamedTuple, NamedTuple}'><span class="jlbinding">SindbadTEM.prepTEMOut</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
prepTEMOut(info::NamedTuple, forcing_helpers::NamedTuple)
```


Prepares the output NamedTuple required for running the Terrestrial Ecosystem Model (TEM) in SINDBAD.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `forcing_helpers`: A NamedTuple with information on forcing sizes and dimensions.
  

**Returns:**

A NamedTuple `output_tuple` containing:
- `land_init`: The initial land state from `info.land_init`.
  
- `dims`: A vector of output dimensions, where each dimension is represented as a tuple of `Dim` objects.
  
- `data`: A vector of numeric arrays initialized for output variables.
  
- `variables`: A list of output variable names.
  
- Additional fields for optimization output if optimization is enabled.
  

**Notes:**
- The function initializes the output dimensions and data arrays based on the specified array backend (`info.helpers.run.output_array_type`).
  
- If optimization is enabled (`info.helpers.run.run_optimization`), additional fields for optimized parameters are added to the output.
  
- The function uses helper functions like `getOutDimsArrays` and `setupOptiOutput` to prepare the output.
  

**Examples:**
1. **Basic usage**:
  

```julia
output_tuple = prepTEMOut(info, forcing_helpers)
```

1. **Accessing output fields**:
  

```julia
dims = output_tuple.dims
data = output_tuple.data
variables = output_tuple.variables
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.runTEM' href='#SindbadTEM.runTEM'><span class="jlbinding">SindbadTEM.runTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
runTEM(forcing::NamedTuple, info::NamedTuple)
runTEM(selected_models::Tuple, forcing::NamedTuple, loc_spinup_forcing, loc_forcing_t, loc_land::NamedTuple, tem_info::NamedTuple)
runTEM(selected_models::Tuple, loc_forcing::NamedTuple, loc_spinup_forcing, loc_forcing_t, land_time_series, loc_land::NamedTuple, tem_info::NamedTuple)
```


Runs the SINDBAD Terrestrial Ecosystem Model (TEM) for a single location, with or without spinup, based on the provided configurations. The two main variants are the ones with and without the preallocated land time series. The shorthand version with two input arguments calls the one without preallocated land time series.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
  
- `loc_spinup_forcing`: A forcing NamedTuple for spinup, used to initialize the model to a steady state.
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `loc_land::NamedTuple`: Initial SINDBAD land NamedTuple with all fields and subfields.
  
- `tem_info::NamedTuple`: A nested NamedTuple containing necessary information, including:
  - Model helpers.
    
  - Spinup configurations.
    
  - Debugging options.
    
  - Output configurations.
    
  

**Returns:**
- `LandWrapper`: A wrapper containing the time series of SINDBAD land states for each time step after the model simulation.
  

**Notes:**
- The function internally calls `coreTEM` to handle the main simulation logic.
  
- If spinup is enabled (`DoSpinupTEM`), the function runs the spinup process before the main simulation.
  
- If spinup is disabled (`DoNotSpinupTEM`), the function directly runs the main simulation.
  
- The function prepares the necessary inputs and configurations using `prepTEM` before executing the simulation.
  

**Examples:**
1. **Running TEM with spinup**:
  

```julia
land_time_series = runTEM(selected_models, forcing, loc_spinup_forcing, loc_forcing_t, loc_land, tem_info)
```

1. **Running TEM without spinup**:
  

```julia
land_time_series = runTEM(selected_models, forcing, nothing, loc_forcing_t, loc_land, tem_info)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.runTEM!' href='#SindbadTEM.runTEM!'><span class="jlbinding">SindbadTEM.runTEM!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
runTEM!(selected_models, forcing::NamedTuple, info::NamedTuple)
runTEM!(forcing::NamedTuple, info::NamedTuple)
runTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info::NamedTuple)
```


Runs the SINDBAD Terrestrial Ecosystem Model (TEM) for all locations and time steps using preallocated arrays as the model data backend. This function supports multiple configurations for efficient execution.

**Arguments:**
1. **For the first variant**:
  - `selected_models`: A tuple of all models selected in the given model structure.
    
  - `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
    
  - `info::NamedTuple`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
    
  
2. **For the second variant**:
  - `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
    
  - `info::NamedTuple`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
    
  
3. **For the third variant**:
  - `selected_models`: A tuple of all models selected in the given model structure.
    
  - `space_forcing`: A collection of forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
    
  - `space_spinup_forcing`: A collection of spinup forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
    
  - `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
    
  - `space_output`: A collection of output arrays/views for multiple locations, replicated to avoid data races during parallel execution.
    
  - `space_land`: A collection of initial SINDBAD land NamedTuples for multiple locations, ensuring that the model states for one location do not overwrite those of another.
    
  - `tem_info::NamedTuple`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
    
  

**Returns:**
- `output_array`: A preallocated array containing the simulation results for all locations and time steps.
  

**Notes:**
- **Precomputations**:
  - The function uses `prepTEM` to prepare the necessary inputs and configurations for the simulation.
    
  
- **Parallel Execution**:
  - The function uses `parallelizeTEM!` to distribute the simulation across multiple locations using the specified parallelization backend (`Threads.@threads` or `qbmap`).
    
  
- **Core Execution**:
  - For each location, the function calls `coreTEM!` to execute the TEM simulation, including spinup (if enabled) and the main time loop.
    
  
- **Data Safety**:
  - The function ensures data safety by replicating forcing, output, and land data for each location, avoiding data races during parallel execution.
    
  

**Examples:**
1. **Running TEM with preallocated arrays**:
  

```julia
output_array = runTEM!(selected_models, forcing, info)
```

1. **Running TEM with parallelization**:
  

```julia
output_array = runTEM!(forcing, info)
```

1. **Running TEM with precomputed helpers**:
  

```julia
runTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.runTEMYax-Tuple{Tuple, NamedTuple, NamedTuple}' href='#SindbadTEM.runTEMYax-Tuple{Tuple, NamedTuple, NamedTuple}'><span class="jlbinding">SindbadTEM.runTEMYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runTEMYax(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, selected_models::Tuple; max_cache = 1.0e9)
```


**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
  
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
  
- `selected_models`: a tuple of all models selected in the given model structure
  
- `max_cache`: cache size to use for mapCube
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.setOutputForTimeStep!-Union{Tuple{output_vars}, Tuple{Any, Any, Any, Val{output_vars}}} where output_vars' href='#SindbadTEM.setOutputForTimeStep!-Union{Tuple{output_vars}, Tuple{Any, Any, Any, Val{output_vars}}} where output_vars'><span class="jlbinding">SindbadTEM.setOutputForTimeStep!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setOutputForTimeStep!(outputs, land, ts, Val{output_vars})
```


**Arguments:**
- `outputs`: vector of model output vectors
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `ts`: time step
  
- `::Val{output_vars}`: a dispatch for vals of the output variables to generate the function
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.setSequence-Tuple{Any, Any}' href='#SindbadTEM.setSequence-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.setSequence</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setSequence(tem_info, new_sequence)
```


**Arguments:**
- `tem_info`: Tuple with the field `spinup_sequence`
  
- `new_sequence`
  

**Outputs**
- an updated tem_info object with new spinup sequence modes
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.setupOptiOutput' href='#SindbadTEM.setupOptiOutput'><span class="jlbinding">SindbadTEM.setupOptiOutput</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
setupOptiOutput(info::NamedTuple, output::NamedTuple[, ::DoRunOptimization | ::DoNotRunOptimization])
```


Creates the output fields needed for the optimization experiment.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `output`: A base output NamedTuple to which optimization-specific fields will be added.
  
- `::DoRunOptimization`: (Optional) A type dispatch indicating that optimization is enabled. Adds fields for optimized parameters.
  
- `::DoNotRunOptimization`: (Optional) A type dispatch indicating that optimization is not enabled. Returns the base output unchanged.
  

**Returns:**
- A NamedTuple containing the base output fields, with additional fields for optimization if enabled.
  

**Notes:**
- When optimization is enabled, the function:
  - Adds a `parameter_dim` field to the output, which includes the parameter dimension and metadata.
    
  - Creates an `OutDims` object for storing optimized parameters, with the appropriate backend and file path.
    
  
- When optimization is not enabled, the function simply returns the input `output` NamedTuple unchanged.
  

**Examples:**
1. **With optimization enabled**:
  

```julia
output = setupOptiOutput(info, output, DoRunOptimization())
```

1. **Without optimization**:
  

```julia
output = setupOptiOutput(info, output, DoNotRunOptimization())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.spinup' href='#SindbadTEM.spinup'><span class="jlbinding">SindbadTEM.spinup</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, spinup_mode::SpinupMode)
```


Runs the spinup process for the SINDBAD Terrestrial Ecosystem Model (TEM) to initialize the model to a steady state. The spinup process updates the state variables (e.g., pools) using various spinup methods.

**Arguments:**
- `spinup_models`: A tuple of a subset of all models in the given model structure that are selected for spinup.
  
- `spinup_forcing`: A forcing NamedTuple containing the time series of environmental drivers for the spinup process.
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every timestep.
  
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
  
- `n_timesteps`: The number of timesteps for the spinup process.
  
- `spinup_mode::SpinupMode`: A type dispatch that determines the spinup method to be used. 
  

**Returns:**
- `land`: The updated SINDBAD NamedTuple containing the final state of the model after the spinup process.
  

**SpinupMode**

Abstract type for model spinup modes in SINDBAD

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
  


---


**Extended help**

**Notes:**
- The spinup process can use different methods depending on the `spinup_mode`, including fixed-point solvers, ODE solvers, and steady-state solvers.
  
- The function dynamically selects the appropriate spinup method based on the `spinup_mode` dispatch type.
  
- For ODE-based methods, the function uses DifferentialEquations.jl to solve the spinup equations.
  
- For steady-state solvers, the function uses methods like `DynamicSS` or `SSRootfind` to find equilibrium states.
  

**Examples:**
1. **Running spinup with selected models**:
  

```julia
land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, SelSpinupModels())
```

1. **Running spinup with ODE solver (Tsit5)**:
  

```julia
land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ODETsit5())
```

1. **Running spinup with fixed-point solver for cEco and TWS**:
  

```julia
land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, NlsolveFixedpointTrustregionCEcoTWS())
```

1. **Running spinup with steady-state solver (SSRootfind)**:
  

```julia
land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, SSPSSRootfind())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.spinupTEM' href='#SindbadTEM.spinupTEM'><span class="jlbinding">SindbadTEM.spinupTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
spinupTEM(selected_models, forcing, loc_forcing_t, land, tem_info, spinup_mode)
```


The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using spinup functions for different spinup methods.

**Arguments:**
- `selected_models`: a tuple of all models selected in the given model structure
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `loc_forcing_t`: a forcing NT for a single location and a single time step
  
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
  
- `tem_info`: helper NT with necessary objects for model run and type consistencies
  
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
  
- `spinup_mode`: A type dispatch that determines whether spinup is included or excluded:
  - `::DoSpinupTEM`: Runs the spinup process before the main simulation. Set `spinup_TEM` to `true` in the flag section of experiment_json.
    
  - `::DoNotSpinupTEM`: Skips the spinup process and directly runs the main simulation. Set `spinup_TEM` to `false` in the flag section of experiment_json.
    
  

**Notes:**
- When `DoSpinupTEM` is used:
  - The function runs the spinup sequences
    
  
- When `DoNotSpinupTEM` is used:
  - The function skips the spinup process returns the land as is`
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.timeLoopTEMSpinup-NTuple{6, Any}' href='#SindbadTEM.timeLoopTEMSpinup-NTuple{6, Any}'><span class="jlbinding">SindbadTEM.timeLoopTEMSpinup</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
timeLoopTEMSpinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps)
```


do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the land/land is overwritten with every iteration. Only the state at the end is returned

**Arguments:**
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
  
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
  
- `loc_forcing_t`: a forcing NT for a single location and a single time step
  
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
  
- `tem_info`: helper NT with necessary objects for model run and type consistencies
  
- `n_timesteps`: number of time steps
  

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spinup_TWS-Tuple{Any, Any}' href='#Sindbad.Types.Spinup_TWS-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Types.Spinup_TWS</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
(TWS_spin::Spinup_TWS)(pout, p)
```


Custom callable type function for spinning up TWS pools.

**Arguments**
- `pout`: Output pools
  
- `p`: Input pools
  

**Note**

This method allows a `Spinup_TWS` object to be called as a function, implementing the specific spinup logic for the terrestrial water storage components.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spinup_cEco-Tuple{Any, Any}' href='#Sindbad.Types.Spinup_cEco-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Types.Spinup_cEco</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
(cEco_spin::Spinup_cEco)(pout, p)
```


Custom callable type function for spinning up cEco.

**Arguments**
- `pout`: Output pools
  
- `p`: Input pools
  

**Note**

This method allows a `Spinup_cEco` object to be called as a function, implementing the specific spinup logic for ecosystem carbon pools.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.Spinup_cEco_TWS-Tuple{Any, Any}' href='#Sindbad.Types.Spinup_cEco_TWS-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Types.Spinup_cEco_TWS</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
(cEco_TWS_spin::Spinup_cEco_TWS)(pout, p)
```


Custom callable type function for spinning up cEco and TWS pools.

**Arguments**
- `pout`: Output pools
  
- `p`: Input pools
  

**Note**

This method allows a `Spinup_cEco_TWS` object to be called as a function, implementing the specific spinup logic for ecosystem carbon pools and the terrestrial water storage components.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.addErrorCatcher' href='#SindbadTEM.addErrorCatcher'><span class="jlbinding">SindbadTEM.addErrorCatcher</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
addErrorCatcher(loc_land, debug_mode)
```


Adds an error catcher to monitor and debug the SINDBAD land variables during model execution.

**Arguments:**
- `loc_land`: A core SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every time step.
  
- `debug_mode`: A type dispatch to determine whether debugging is enabled:
  - `DoDebugModel`: Enables debugging and adds `loc_land` to the error catcher. Set `debug_model` to true in flag section of experiment_json.
    
  - `DoNotDebugModel`: Disables debugging and does nothing. Set `debug_model` to false in flag section of experiment_json.
    
  

**Returns:**
- `nothing`: The function modifies global state or performs debugging actions but does not return a value.
  

**Notes:**
- When `debug_mode` is `DoDebugModel`, the function:
  - Initializes an error catcher if it does not already exist. This error_catcher is a global variable where you can add any variable from within SINDBAD while debugging, and this variable will be available during an experiment run REPL session.
    
  - Pushes the current `loc_land` to the error catcher for debugging purposes.
    
  - Prints the `loc_land` for inspection using `tcPrint`.
    
  
- When `debug_mode` is `DoNotDebugModel`, the function performs no actions.
  

**Examples:**
1. **Enabling debugging**:
  

```julia
loc_land = (temperature = 15.0, precipitation = 100.0)
addErrorCatcher(loc_land, DoDebugModel())
```

1. **Disabling debugging**:
  

```julia
loc_land = (temperature = 15.0, precipitation = 100.0)
addErrorCatcher(loc_land, DoNotDebugModel())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.addSpinupLog' href='#SindbadTEM.addSpinupLog'><span class="jlbinding">SindbadTEM.addSpinupLog</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
addSpinupLog(loc_land, sequence, ::SpinupLogType)
```


Adds or skips the preallocated holder for storing the spinup log during model spinup, depending on the specified `SpinupLogType`.

**Arguments:**
- `loc_land`: A core SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every time step.
  
- `sequence`: The spinup sequence, which defines the number of repeats and timesteps for the spinup process.
  
- `::SpinupLogType`: A type dispatch that determines whether to store the spinup log:
  - `DoStoreSpinup`: Enables storing the spinup log for each repeat of the spinup process. Set `store_spinup` to true in flag section of experiment_json.
    
  - `DoNotStoreSpinup`: Skips storing the spinup log. Set `store_spinup` to false in flag section of experiment_json.
    
  

**Returns:**
- `loc_land`: The updated `loc_land` NamedTuple, potentially with the spinup log added.
  

**Notes:**
- When `DoStoreSpinup` is used:
  - The function calculates the total number of repeats in the spinup sequence.
    
  - Preallocates a vector to store the spinup log for each repeat.
    
  - Updates the `loc_land` NamedTuple with the spinup log.
    
  
- When `DoNotStoreSpinup` is used, the function simply returns `loc_land` without modifications.
  

**Examples:**
1. **Storing the spinup log**:
  

```julia
loc_land = (pools = rand(10), states = rand(10))
sequence = [(n_repeat = 3, n_timesteps = 10), (n_repeat = 2, n_timesteps = 5)]
loc_land = addSpinupLog(loc_land, sequence, DoStoreSpinup())
```

1. **Skipping the spinup log**:
  

```julia
loc_land = (pools = rand(10), states = rand(10))
sequence = [(n_repeat = 3, n_timesteps = 10), (n_repeat = 2, n_timesteps = 5)]
loc_land = addSpinupLog(loc_land, sequence, DoNotStoreSpinup())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.collectMetadata-Tuple{Any, Any}' href='#SindbadTEM.collectMetadata-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.collectMetadata</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
collectMetadata(info, vname)
```


Collects metadata for a specific output variable in the SINDBAD experiment.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `vname`: A tuple of symbols representing the variable name, e.g., `(:diagnostics, :water_balance)`.
  

**Returns:**
- A dictionary `Dict{String, Any}` containing metadata for the specified variable, including:
  - Metadata from the variable catalog (if available).
    
  - Global metadata about the platform from `info.output.file_info.global_metadata`.
    
  

**Notes:**
- If the variable is not found in the catalog, a warning is issued, and the metadata dictionary will not include catalog-specific information.
  
- The metadata includes platform information for every output variable. For datasets, this should ideally be added once, not for every variable.
  

**Examples:**
1. **Collecting metadata for a variable**:
  

```julia
metadata = collectMetadata(info, (:diagnostics, :water_balance))
```

1. **Accessing specific metadata fields**:
  

```julia
platform_info = metadata["platform_info"]
variable_units = metadata["units"]
```


**Warnings:**
- If the variable is not found in the catalog, a warning is logged.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.coreTEMYax-NTuple{4, Any}' href='#SindbadTEM.coreTEMYax-NTuple{4, Any}'><span class="jlbinding">SindbadTEM.coreTEMYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
coreTEMYax(selected_models, loc_forcing, loc_forcing_t, loc_land, tem_info, tem_spinup, ::DoSpinupTEM)
```


run the SINBAD CORETEM for a given location

**Arguments:**
- `selected_models`: a tuple of all models selected in the given model structure
  
- `loc_forcing`: a forcing NT that contains the forcing time series set for one location
  
- `loc_land`: initial SINDBAD land with all fields and subfields
  
- `tem_info`: helper NT with necessary objects for model run and type consistencies
  
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.defineTEM-Tuple{LongTuple, Any, Any, Any}' href='#SindbadTEM.defineTEM-Tuple{LongTuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.defineTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
defineTEM(models::LongTuple, forcing, land, model_helpers)
```


run the precompute function of SINDBAD models to instantiate all fields of land

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.defineTEM-Tuple{Tuple, Any, Any, Any}' href='#SindbadTEM.defineTEM-Tuple{Tuple, Any, Any, Any}'><span class="jlbinding">SindbadTEM.defineTEM</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
defineTEM(models, forcing, land, model_helpers)
```


run the define and precompute functions of SINDBAD models to instantiate all fields of land

**Arguments:**
- `models`: a list of SINDBAD models to run
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.fillLocOutput!-Union{Tuple{T2}, Tuple{T1}, Tuple{T}, Tuple{T, T1, T2}} where {T, T1, T2<:Int64}' href='#SindbadTEM.fillLocOutput!-Union{Tuple{T2}, Tuple{T1}, Tuple{T}, Tuple{T, T1, T2}} where {T, T1, T2<:Int64}'><span class="jlbinding">SindbadTEM.fillLocOutput!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
fillLocOutput!(ar::T, val::T1, ts::T2) where {T, T1, T2<:Int}
```


Fill an array `ar` with value `val` at specific time step `ts`. Generic function that works with different array and value types, where the time step must be an integer.

**Arguments**
- `ar::T`: Target array to be filled
  
- `val::T1`: Value to fill into the array
  
- `ts::T2<:Int`: Time step indicating position to fill
  

**Notes**
- Modifies the input array `ar` in-place
  
- Time step `ts` must be an integer type
  

**Returns**

Nothing, modifies input array in-place

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.fillOutputYax-Tuple{Any, Any}' href='#SindbadTEM.fillOutputYax-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.fillOutputYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
fillOutputYax(xout, xin)
```


fills the output array position with the input data/vector

**Arguments:**
- `xout`: output array location
  
- `xin`: input data/vector
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.filterNanPixels' href='#SindbadTEM.filterNanPixels'><span class="jlbinding">SindbadTEM.filterNanPixels</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
filterNanPixels(forcing, loc_space_maps, filter_nan_pixels_mode)
```


Filters out spatial pixels where all timesteps contain NaN values, based on the specified filtering mode.

**Arguments:**
- `forcing`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
  
- `loc_space_maps`: A collection of local spatial coordinates for all input points.
  
- `filter_nan_pixels_mode`: A type dispatch that determines whether to filter NaN-only pixels:
  - `DoFilterNanPixels`: Filters out pixels where all timesteps are NaN. Set `filter_nan_pixels` to true in flag section of experiment_json.
    
  - `DoNotFilterNanPixels`: Does not filter any pixels, returning the input `loc_space_maps` unchanged. Set `filter_nan_pixels` to false in flag section of experiment_json.
    
  

**Returns:**
- `loc_space_maps`: The filtered or unfiltered spatial coordinates, depending on the filtering mode.
  

**Notes:**
- When `DoFilterNanPixels` is used:
  - The function iterates through all spatial locations and checks if all timesteps for a given location are NaN. NOTE THAT THIS WILL BE SLOW FOR LARGE DATASETS AS ALL LAZILY-LOADED DATA ARE STORED IN MEMORY.
    
  - Locations with all NaN values are excluded from the returned `loc_space_maps`.
    
  
- When `DoNotFilterNanPixels` is used, the function simply returns the input `loc_space_maps` without any modifications.
  

**Examples:**
1. **Filtering NaN-only pixels**:
  

```julia
forcing = (data = ..., variables = ...)
loc_space_maps = [(1, 2), (3, 4), (5, 6)]
filtered_maps = filterNanPixels(forcing, loc_space_maps, DoFilterNanPixels())
```

1. **Skipping NaN filtering**:
  

```julia
forcing = (data = ..., variables = ...)
loc_space_maps = [(1, 2), (3, 4), (5, 6)]
filtered_maps = filterNanPixels(forcing, loc_space_maps, DoNotFilterNanPixels())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getForcingV' href='#SindbadTEM.getForcingV'><span class="jlbinding">SindbadTEM.getForcingV</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getForcingV(v, ts, <: ForcingTime)
```


Retrieves forcing values for a specific time step or returns constant forcing values, depending on the forcing type.

**Arguments:**
- `v`: The input forcing data. Can be time-dependent or constant.
  
- `ts`: The time step (integer) for which the forcing value is retrieved. Ignored for constant forcing types.
  
- `<: ForcingTime`: The type of forcing, which determines how the value is retrieved:
  - `ForcingWithTime`: Retrieves the forcing value for the specified time step `ts`.
    
  - `ForcingWithoutTime`: Returns the constant forcing value, ignoring `ts`.
    
  

**Returns:**
- The forcing value for the specified time step (if time-dependent) or the constant forcing value.
  

**Extended help**

**Examples:**
1. **Time-dependent forcing**:
  

```julia
forcing = [1.0, 2.0, 3.0]  # Forcing values for time steps
ts = 2                     # Time step
value = getForcingV(forcing, ts, ForcingWithTime())
# value = 2.0
```

1. **Constant forcing**:
  

```julia
forcing = 5.0              # Constant forcing value
ts = 3                     # Time step (ignored)
value = getForcingV(forcing, ts, ForcingWithoutTime())
# value = 5.0
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getLocArrayView' href='#SindbadTEM.getLocArrayView'><span class="jlbinding">SindbadTEM.getLocArrayView</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getLocArrayView(ar, val, ts)
```


Creates a view of the input array `ar` for a specific time step `ts`, based on the type of `val`.

**Arguments:**
- `ar`: The input array from which a view is created.
  
- `val`: The value or vector used to determine the size or structure of the view.
  - If `val` is an `AbstractVector`, the view spans the time step `ts` and the size of `val`.
    
  - If `val` is a `Real` value, the view spans only the time step `ts`.
    
  
- `ts`: The time step (integer) for which the view is created.
  

**Returns:**
- A view of the array `ar` corresponding to the specified time step `ts`.
  

**Notes:**
- The function dynamically adjusts the view based on whether `val` is a vector or a scalar.
  
- This is useful for efficiently accessing or modifying specific slices of the array without copying data.
  

**Examples:**
1. **Creating a view with a vector `val`**:
  

```julia
ar = rand(10, 5)  # A 10x5 array
val = rand(5)     # A vector of size 5
ts = 3            # Time step
view_ar = getLocArrayView(ar, val, ts)
```

1. **Creating a view with a scalar `val`**:
  

```julia
ar = rand(10)     # A 1D array
val = 42.0        # A scalar value
ts = 2            # Time step
view_ar = getLocArrayView(ar, val, ts)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getNumericArrays-Tuple{Any, Any}' href='#SindbadTEM.getNumericArrays-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.getNumericArrays</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getNumericArrays(info, forcing_sizes)
```


Defines and instantiates numeric arrays for SINDBAD output variables.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `forcing_sizes`: A NamedTuple with forcing dimensions and their sizes.
  

**Returns:**
- A vector of numeric arrays initialized with `NaN` values, where each array corresponds to an output variable.
  

**Notes:**
- The arrays are created with dimensions based on the forcing sizes and the depth information of the output variables.
  
- The numeric type of the arrays is determined by the model settings (`info.helpers.numbers.num_type`).
  
- If forward differentiation is enabled (`info.helpers.run.use_forward_diff`), the array type is adjusted accordingly.
  

**Examples:**
1. **Creating numeric arrays for output variables**:
  

```julia
forcing_sizes = (time=10, lat=5, lon=5)
numeric_arrays = getNumericArrays(info, forcing_sizes)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getOutArrayType' href='#SindbadTEM.getOutArrayType'><span class="jlbinding">SindbadTEM.getOutArrayType</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getOutArrayType(num_type, ::DoUseForwardDiff | ::DoNotUseForwardDiff)
```


Determines the type of elements to be used in the output array based on whether forward differentiation is enabled.

**Arguments:**
- `num_type`: The numeric type specified in the model settings (e.g., `Float64`).
  
- `::DoUseForwardDiff`: A type dispatch indicating that forward differentiation is enabled. Returns a generic type (`Real`) to support differentiation.
  
- `::DoNotUseForwardDiff`: A type dispatch indicating that forward differentiation is not enabled. Returns the specified numeric type (`num_type`).
  

**Returns:**
- The type of elements to be used in the output array:
  - `Real` if forward differentiation is enabled.
    
  - `num_type` if forward differentiation is not enabled.
    
  

**Examples:**
1. **Forward differentiation enabled**:
  

```julia
num_type = Float64
array_type = getOutArrayType(num_type, DoUseForwardDiff())
# array_type = Real
```

1. **Forward differentiation not enabled**:
  

```julia
num_type = Float64
array_type = getOutArrayType(num_type, DoNotUseForwardDiff())
# array_type = Float64
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getOutDimsPairs-Tuple{Any, Any}' href='#SindbadTEM.getOutDimsPairs-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.getOutDimsPairs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getOutDimsPairs(tem_output, forcing_helpers; dthres=1)
```


Creates dimension pairs for each output variable based on forcing dimensions and depth information.

**Arguments:**
- `tem_output`: A NamedTuple containing information about output variables and depth dimensions of output arrays.
  
- `forcing_helpers`: A NamedTuple with information on forcing sizes, dimensions, and optional permutations.
  
- `dthres`: (Optional) A threshold for the number of depth layers to define depth as a new dimension. Defaults to `1`.
  

**Returns:**
- A vector of tuples, where each tuple contains dimension pairs for an output variable. Each dimension pair is represented as a `Pair` of a dimension name and its corresponding range or size.
  

**Notes:**
- If `forcing_helpers.dimensions.permute` is provided, the function reorders dimensions based on the permutation.
  
- Depth dimensions are included if their size exceeds the threshold `dthres`. If the depth size is `1`, the depth dimension is labeled as `"idx"`.
  
- The function processes each output variable independently, combining forcing dimensions and depth information.
  

**Examples:**
1. **Basic usage**:
  

```julia
tem_output = (variables=[:var1, :var2], depth_info=[(3, "depth"), (1, "depth")])
forcing_helpers = (axes=[(:time, 10), (:lat, 5), (:lon, 5)], dimensions=(permute=nothing))
outdims_pairs = getOutDimsPairs(tem_output, forcing_helpers)
```

1. **With dimension permutation**:
  

```julia
forcing_helpers = (axes=[(:time, 10), (:lat, 5), (:lon, 5)], dimensions=(permute=["lon", "lat", "time"]))
outdims_pairs = getOutDimsPairs(tem_output, forcing_helpers)
```

1. **With depth threshold**:
  

```julia
outdims_pairs = getOutDimsPairs(tem_output, forcing_helpers; dthres=2)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getRunTEMInfo-Tuple{Any, Any}' href='#SindbadTEM.getRunTEMInfo-Tuple{Any, Any}'><span class="jlbinding">SindbadTEM.getRunTEMInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getRunTEMInfo(info, forcing)
```


a helper to condense the useful info only for the inner model runs

**Arguments:**
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
  
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSpinupForcing-Union{Tuple{forcing_types}, Tuple{Any, SpinupSequenceWithAggregator, Val{forcing_types}}} where forcing_types' href='#SindbadTEM.getSpinupForcing-Union{Tuple{forcing_types}, Tuple{Any, SpinupSequenceWithAggregator, Val{forcing_types}}} where forcing_types'><span class="jlbinding">SindbadTEM.getSpinupForcing</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupForcing(forcing, sequence, ::Val{forcing_types})
```


prepare the spinup forcing set for a given spinup sequence

**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for a location
  
- `sequence`: a with all information needed to run a spinup sequence
  
- `:Val{forcing_types}`: a type dispatch with the tuple of pairs of forcing name and time/no time types
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSpinupForcingVariable-Tuple{Any, Any, ForcingWithoutTime}' href='#SindbadTEM.getSpinupForcingVariable-Tuple{Any, Any, ForcingWithoutTime}'><span class="jlbinding">SindbadTEM.getSpinupForcingVariable</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupForcingVariable(v, _, ::ForcingWithoutTime)
```


get the spinup forcing variable without time axis

**Arguments:**
- `v`: a forcing variable
  
- `sequence`: a with all information needed to run a spinup sequence
  
- `::ForcingWithoutTime`: a type dispatch to indicate that the variable has NO time axis
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSpinupForcingVariable-Tuple{Any, SpinupSequenceWithAggregator, ForcingWithTime}' href='#SindbadTEM.getSpinupForcingVariable-Tuple{Any, SpinupSequenceWithAggregator, ForcingWithTime}'><span class="jlbinding">SindbadTEM.getSpinupForcingVariable</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupForcingVariable(v, sequence, ::ForcingWithTime)
```


get the aggregated spinup forcing variable

**Arguments:**
- `v`: a forcing variable
  
- `sequence`: a with all information needed to run a spinup sequence
  
- `::ForcingWithTime`: a type dispatch to indicate that the variable has a time axis
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.getSpinupTemLite-Tuple{Any}' href='#SindbadTEM.getSpinupTemLite-Tuple{Any}'><span class="jlbinding">SindbadTEM.getSpinupTemLite</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupTemLite(tem_spinup)
```


a helper to just get the spinup sequence to pass to inner functions

**Arguments:**
- `tem_spinup_sequence`: a NT with all spinup information
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.helpPrepTEM' href='#SindbadTEM.helpPrepTEM'><span class="jlbinding">SindbadTEM.helpPrepTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::PreAlloc)
```


Prepares the necessary information and objects needed to run the SINDBAD Terrestrial Ecosystem Model (TEM).

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `info`: A nested NamedTuple containing necessary information, including:
  - Helpers for running the model.
    
  - Model configurations.
    
  - Spinup settings.
    
  
- `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
  
- `output::NamedTuple`: An output NamedTuple containing data arrays, variable information, and dimensions.
  
- `::PreAllocputType`: A type dispatch that determines the output preparation strategy.
  

**Returns:**
- A NamedTuple (`run_helpers`) containing preallocated data and configurations required to run the TEM, including:
  - Spatial forcing data.
    
  - Spinup forcing data.
    
  - Output arrays.
    
  - Land variables.
    
  - Temporal and spatial indices.
    
  - Model and helper configurations.
    
  

**sindbad land output type:**

**PreAlloc**

Abstract type for preallocated land helpers types in prepTEM of SINDBAD

**Available methods/subtypes:**
- `PreAllocArray`: use a preallocated array for model output 
  
- `PreAllocArrayAll`: use a preallocated array to output all land variables 
  
- `PreAllocArrayFD`: use a preallocated array for finite difference (FD) hybrid experiments 
  
- `PreAllocArrayMT`: use arrays of nThreads size for land model output for replicates of multiple threads 
  
- `PreAllocStacked`: save output as a stacked vector of land using map over temporal dimension 
  
- `PreAllocTimeseries`: save land output as a preallocated vector for time series of land 
  
- `PreAllocYAXArray`: use YAX arrays for model output 
  


---


**Extended help**

**Notes:**
- The function dynamically prepares the required data structures based on the specified `PreAllocputType`.
  
- It handles spatial and temporal data preparation, including filtering NaN pixels, initializing land variables, and setting up forcing and output arrays.
  
- This function is a key step in preparing the SINDBAD TEM for execution.
  

**Examples:**
1. **Preparing TEM with `PreAllocArray`**:
  

```julia
run_helpers = helpPrepTEM(selected_models, info, forcing, output, PreAllocArray())
```

1. **Preparing TEM with `PreAllocTimeseries`**:
  

```julia
run_helpers = helpPrepTEM(selected_models, info, forcing, output, PreAllocTimeseries())
```

1. **Preparing TEM with `PreAllocArrayFD` for FD experiments**:
  

```julia
run_helpers = helpPrepTEM(selected_models, info, forcing, observations, output, PreAllocArrayFD())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.nrepeatYearsAge-Tuple{Any}' href='#SindbadTEM.nrepeatYearsAge-Tuple{Any}'><span class="jlbinding">SindbadTEM.nrepeatYearsAge</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
nrepeatYearsAge(year_disturbance; year_start = 1979)
```


**Arguments:**
- `year_disturbance`: a year date, as an string
  
- `year_start`: 1979 [default] start year, as an integer
  

**Outputs**
- year difference
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.nrepeat_age-Tuple{Any}' href='#SindbadTEM.nrepeat_age-Tuple{Any}'><span class="jlbinding">SindbadTEM.nrepeat_age</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
nrepeat_age(year_disturbance; year_start = 1979)
```


**Arguments:**
- `year_disturbance`: a year date, as an string
  
- `year_start`: 1979 [default] start year, as an integer
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.parallelizeTEM!' href='#SindbadTEM.parallelizeTEM!'><span class="jlbinding">SindbadTEM.parallelizeTEM!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, parallelization_mode::SindbadParallelizationMethod)
```


Parallelizes the SINDBAD Terrestrial Ecosystem Model (TEM) across multiple locations using the specified parallelization backend.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `space_forcing`: A collection of forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
  
- `space_spinup_forcing`: A collection of spinup forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `space_output`: A collection of output arrays/views for multiple locations, replicated to avoid data races during parallel execution.
  
- `space_land`: A collection of initial SINDBAD land NamedTuples for multiple locations, ensuring that the model states for one location do not overwrite those of another.
  
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
  
- `parallelization_mode`: A type dispatch that determines the parallelization backend to use:
  - `ThreadsParallelization`: Uses Julia&#39;s `Threads.@threads` for parallel execution.
    
  - `QbmapParallelization`: Uses `qbmap` for parallel execution.
    
  

**Returns:**
- `nothing`: The function modifies `space_output` and `space_land` in place to store the results for each location.
  

**Notes:**
- **Thread-based Parallelization**:
  - When `ThreadsParallelization` is used, the function distributes the locations across threads using `Threads.@threads`.
    
  
- **Qbmap-based Parallelization**:
  - When `QbmapParallelization` is used, the function distributes the locations using the `qbmap` backend.
    
  
- **Core Execution**:
  - For each location, the function calls `coreTEM!` to execute the TEM simulation, including spinup (if enabled) and the main time loop.
    
  
- **Data Safety**:
  - The function ensures data safety by replicating forcing, output, and land data for each location, avoiding data races during parallel execution.
    
  

**Examples:**
1. **Parallelizing TEM using threads**:
  

```julia
parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, ThreadsParallelization())
```

1. **Parallelizing TEM using qbmap**:
  

```julia
parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, QbmapParallelization())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.runTEMOne-NTuple{4, Any}' href='#SindbadTEM.runTEMOne-NTuple{4, Any}'><span class="jlbinding">SindbadTEM.runTEMOne</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
runTEMOne(selected_models, forcing, output_array::AbstractArray, land_init, loc_ind, tem)
```


run the SINDBAD TEM for one time step

**Arguments:**
- `selected_models`: a tuple of all models selected in the given model structure
  
- `loc_forcing`: a forcing NT for a single location
  
- `land_init`: initial SINDBAD land with all fields and subfields
  
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
  

**Returns:**
- `loc_forcing_t`: the forcing NT for the current time step
  
- `loc_land`: the SINDBAD land NT after a run of model for one time step. This contains all the variables from the selected models and their structure and type will remain the same across the experiment.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.sequenceForcing-Tuple{NamedTuple, Symbol}' href='#SindbadTEM.sequenceForcing-Tuple{NamedTuple, Symbol}'><span class="jlbinding">SindbadTEM.sequenceForcing</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
sequenceForcing(spinup_forcings::NamedTuple, forc_name::Symbol)
```


Processes and sequences forcing data for spinup simulations.

**Arguments**
- `spinup_forcings::NamedTuple`: A named tuple containing the forcing data for different spinup sequence
  
- `forc_name::Symbol`: Symbol indicating the name of the forcing data set to be extracted from the NT for the given sequence
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.setSpinupLog' href='#SindbadTEM.setSpinupLog'><span class="jlbinding">SindbadTEM.setSpinupLog</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
setSpinupLog(land, log_index, spinup_log_mode)
```


Stores or skips the spinup log during the spinup process, depending on the specified `spinup_log_mode`.

**Arguments:**
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every timestep.
  
- `log_index`: The index in the spinup log where the current state of `land.pools` will be stored.
  
- `spinup_log_mode`: A type dispatch that determines whether to store the spinup log:
  - `DoStoreSpinup`: Enables storing the spinup log at the specified `log_index`. Set the `store_spinup` flag to `true` in flag section of experiment_json.
    
  - `DoNotStoreSpinup`: Skips storing the spinup log. Set the `store_spinup` flag to `false` in flag section of experiment_json.
    
  

**Returns:**
- `land`: The updated SINDBAD NamedTuple, potentially with the spinup log stored.
  

**Notes:**
- When `DoStoreSpinup` is used:
  - The function stores the current state of `land.pools` in `land.states.spinuplog` at the specified `log_index`.
    
  
- When `DoNotStoreSpinup` is used:
  - The function does nothing and simply returns the input `land`.
    
  

**Examples:**
1. **Storing the spinup log**:
  

```julia
land = (pools = ..., states = (spinuplog = Vector{Any}(undef, 10)))
log_index = 1
land = setSpinupLog(land, log_index, DoStoreSpinup())
```

1. **Skipping the spinup log**:
  

```julia
land = (pools = ..., states = (spinuplog = Vector{Any}(undef, 10)))
log_index = 1
land = setSpinupLog(land, log_index, DoNotStoreSpinup())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.spinupSequence-NTuple{9, Any}' href='#SindbadTEM.spinupSequence-NTuple{9, Any}'><span class="jlbinding">SindbadTEM.spinupSequence</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
spinupSequence(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_index, n_repeat, spinup_mode)
```


Executes a sequence of model spinup iterations for the Terrestrial Ecosystem Model (TEM).

**Arguments**
- `spinup_models`: Collection of model configurations for spinup
  
- `sel_forcing`: Selected forcing data
  
- `loc_forcing_t`: Localized forcing data with temporal component
  
- `land`: Land surface parameters
  
- `tem_info`: TEM model information and parameters
  
- `n_timesteps`: Number of timesteps for the spinup
  
- `log_index`: Index for logging purposes
  
- `n_repeat`: Number of times to repeat the spinup sequence
  
- `spinup_mode`: Mode of spinup operation (e.g., &quot;normal&quot;, &quot;accelerated&quot;)
  

**Description**

Performs model spinup by running multiple iterations of the TEM model to achieve steady state conditions. The function handles different spinup modes and manages the sequence of model runs according to specified parameters.

**Returns**

land with the updated pools after the spinup sequence.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.spinupSequenceLoop-NTuple{9, Any}' href='#SindbadTEM.spinupSequenceLoop-NTuple{9, Any}'><span class="jlbinding">SindbadTEM.spinupSequenceLoop</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
spinupSequenceLoop(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_loop, n_repeat, spinup_mode)
```


Runs sequential loops for model spin-up simulations for each repeat of a spinup sequence.

**Arguments**
- `spinup_models`: Collection of spin-up model instances
  
- `sel_forcing`: Selected forcing data
  
- `loc_forcing_t`: Localized forcing data in temporal dimension
  
- `land`: Land surface parameters/conditions
  
- `tem_info`: Model configuration and parameters for TEM
  
- `n_timesteps`: Number of timesteps to simulate
  
- `log_loop`: Boolean flag for logging loop information
  
- `n_repeat`: Number of times to repeat the spin-up loop
  
- `spinup_mode`: Mode of spin-up simulation (e.g., &quot;normal&quot;, &quot;accelerated&quot;)
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.timeAggregateForcingV-Tuple{Any, Any, Any, TimeIndexed}' href='#SindbadTEM.timeAggregateForcingV-Tuple{Any, Any, Any, TimeIndexed}'><span class="jlbinding">SindbadTEM.timeAggregateForcingV</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupForcing(forcing, loc_forcing_t, time_aggregator, tem_helpers, ::TimeIndexed)
```


aggregate the forcing variable with time where an aggregation/collection is needed in time

**Arguments:**
- `v`: a forcing variable
  
- `aggregator`: a time aggregator object/index needed to slice data 
  
- `::TimeIndexed`: a type dispatch to just slice the variable time series using index
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.timeAggregateForcingV-Tuple{Any, Any, Any, TimeNoDiff}' href='#SindbadTEM.timeAggregateForcingV-Tuple{Any, Any, Any, TimeNoDiff}'><span class="jlbinding">SindbadTEM.timeAggregateForcingV</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpinupForcing(forcing, loc_forcing_t, time_aggregator, tem_helpers, ::TimeIndexed)
```


aggregate the forcing variable with time where an aggregation/collection is needed in time

**Arguments:**
- `v`: a forcing variable
  
- `aggregator`: a time aggregator object needed to time aggregate the data 
  
- `ag_type::TimeNoDiff`: a type dispatch to indicate that the variable has to be aggregated in time
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.timeLoopTEM' href='#SindbadTEM.timeLoopTEM'><span class="jlbinding">SindbadTEM.timeLoopTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land, tem_info, debug_mode)
timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, tem_info, debug_mode)
```


Executes the time loop for the SINDBAD Terrestrial Ecosystem Model (TEM), running the model for each time step using the provided forcing data and updating the land. There are two major variants with and without the preallocated land time series. In the debug mode only 1 time step is executed for debugging the allocations in each model.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `loc_forcing`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `land_time_series`: A preallocated vector (length = number of time steps) to store SINDBAD land states for each time step.
  
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every time step.
  
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
  
- `debug_mode`: A type dispatch that determines whether debugging is enabled or disabled:
  - `DoDebugModel`: Runs the model for a single time step and displays debugging information (e.g., allocations, execution time). Set`debug_model` to `true` in flag section of experiment_json.
    
  - `DoNotDebugModel`: Runs the model for all time steps without debugging. Set`debug_model` to `false` in flag section of experiment_json.
    
  

**Returns:**
- `nothing`: The function modifies `land_time_series` in place to store the results for each time step.
  

**Notes:**
- For each time step:
  - The function retrieves the forcing data for the current time step using `getForcingForTimeStep`.
    
  - The model is executed using `computeTEM`, which updates the land state.
    
  - The updated land state is stored in `land_time_series`.
    
  
- When `DoDebugModel` is used:
  - The function runs the model for a single time step and logs debugging information, such as execution time and memory allocations.
    
  
- When `DoNotDebugModel` is used:
  - The function runs the model for all time steps in a loop.
    
  

**Examples:**
1. **Running the time loop without debugging**:
  

```julia
timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land, tem_info, DoNotDebugModel())
```

1. **Running the time loop with debugging**:
  

```julia
timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land, tem_info, DoDebugModel())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.timeLoopTEM!' href='#SindbadTEM.timeLoopTEM!'><span class="jlbinding">SindbadTEM.timeLoopTEM!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, debug_mode)
```


Executes the time loop for the SINDBAD Terrestrial Ecosystem Model (TEM), running the model for each time step and storing the outputs in preallocated arrays.

**Arguments:**
- `selected_models`: A tuple of all models selected in the given model structure.
  
- `loc_forcing`: A forcing NamedTuple containing the time series of environmental drivers for a single location.
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `loc_output`: A preallocated output array or view for storing the model outputs for a single location.
  
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every time step.
  
- `forcing_types`: A NamedTuple specifying the types of forcing variables (e.g., time-dependent or constant).
  
- `model_helpers`: A NamedTuple containing helper functions and configurations for model execution.
  
- `output_vars`: A list of output variables to be stored for each time step.
  
- `n_timesteps`: The total number of time steps to run the simulation.
  
- `debug_mode`: A type dispatch that determines whether debugging is enabled or disabled:
  - `DoDebugModel`: Runs the model for a single time step and logs debugging information (e.g., allocations, execution time). Set`debug_model` to `true` in flag section of experiment_json.
    
  - `DoNotDebugModel`: Runs the model for all time steps without debugging. Set`debug_model` to `false` in flag section of experiment_json.
    
  

**Returns:**
- `nothing`: The function modifies `loc_output` in place to store the results for each time step.
  

**Notes:**
- **Forcing Retrieval**:
  - For each time step, the function retrieves the forcing data using `getForcingForTimeStep`.
    
  
- **Model Execution**:
  - The model is executed using `computeTEM`, which updates the land state.
    
  
- **Output Storage**:
  - The updated land state is stored in the preallocated `loc_output` array using `setOutputForTimeStep!`.
    
  
- **Debugging**:
  - When `DoDebugModel` is used, the function logs detailed debugging information for a single time step, including execution time and memory allocations.
    
  

**Examples:**
1. **Running the time loop without debugging**:
  

```julia
timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, DoNotDebugModel())
```

1. **Running the time loop with debugging**:
  

```julia
timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, DoDebugModel())
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadTEM.unpackYaxForward-Tuple{Any}' href='#SindbadTEM.unpackYaxForward-Tuple{Any}'><span class="jlbinding">SindbadTEM.unpackYaxForward</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
unpackYaxForward(args; tem::NamedTuple, forcing_vars::AbstractArray)
```


unpack the input and output cubes from all cubes thrown by mapCube

**Arguments:**
- `all_cubes`: collection/tuple of all input and output cubes
  
- `forcing_vars`: forcing variables
  
- `output_vars`: output variables
  

</details>

