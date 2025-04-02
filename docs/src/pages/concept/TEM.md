```@raw html
# SINDBAD TEM 
```
In SINDBAD, TEM is broadly defined as the component of MDI framework that includes the ecosystem processes, ways to modeling these processes, building them together to form a Terrestrial Ecosystem Model (TEM), and running their components such as spinup, time loop etc.

## Model Processes

### SINDBAD Model

A **Model** is defined as an ecosystem process that can be modelled using different methods and ways. In principle, a model would represent a certain ecosystem process which could ideally not be broken into smaller processes. For example, ```photosynthesis``` is too broad to be a model when thinking about the processes involved during it such as radiation use, transpiration, etc. So, it could be divided into individual ```component models``` which could be put together to represent the process of ```photosynthesis```.

### SINDBAD Approach

A method to calculate/emulate a process defined by a ```SINDBAD Model``` is called an **approach**. Lets assume an example of the process of baseflow generation. ```Baseflow``` would be the model process (SINDBAD Model), and ```linear``` can be a method where baseflow is calculated as a linear function of groundwater storage.

### Approach methods:

The `update, compute, precompute, and define` functions are core methods that can defined for every SINDBAD approach.

- `define`: Initializes memory-allocating variables and arrays required for the approach.
- `precompute`: Updates defined variables and arrays with new realizations based on model parameters or forcing data, preparing the model for time-dependent computations.
- `compute`: Advances the model state in time by applying dynamic updates using precomputed variables and the forcing data of the time step.
- `update`: optionally, modifies pools and variables within a single time step.

## Parameters and Inversion

In SINDBAD, ```Parameters``` of an approach are defined as the critical component that control the response that the process is representing. In classical term, this is the aspect of an approach that are uncertain, meaning their true values are often unknown. In MDI perspective, these are open to be estimated using ```model/parameter inversion``` methods. By inversion, we broadly include *all methods including but not limited to parameter calibration (à la modeling principle), optimization (à la mathematical method), and parameter learning (à la ML)*. 

## Ecosystem Model

We envision an ecosystem as the core component of the modeling that includes
1. combination of ecosystem process
2. ways to run it, e.g., with a without spinup, once per model run, or in each timestep etc.

### Model Structure

A model structure represents a collection of ecosystem processes that are suited for a scientific goal and challenge. It includes a collection of SINDBAD models, for each of which an approach is defined for the given experiment.

SINBAD allows for full flexibility to ```lego-build``` the model structure through the settings. Note that the models has sub-dependency that means not all the models can be combined and used independently. For example, in a model structure where ```fAPAR``` is calculated as a function of ```LAI``` should include the ```LAI``` in the model structure. 

### Model orders and list, selected models

By default, a standard collection of models and their orders of calls are stored in ```standard_sindbad_models``` variable which is available when SINDBAD is imported.

::: info

This can be over-riden by passing the sindbad_models field during experimental setup through ```replace_info```

```julia
"model_structure.sindbad_models" => (:model1, :model2, :model3)
```

Note that this list can be a subset of all models defined in SINDBAD. To check that

```julia
using Sindbad
all_available_sindbad_models
```

:::

From the list of standard models or user-defined variant of it, which can be a subset of all available sindbad models, an experiment can select a set of models suited for the goal. This is so called ```selected_models``` of an experiment which are [set through model structure settings](../settings/model_structure.md). 


## runTEM

```runTEM``` by name  encompasses the steps and ways to orchestrate the execution of the SINDBAD Terrestrial Ecosystem Model (TEM). 
It includes initialization, spinup, and time-stepping processes for the model structure

- `coreTEM`: Core execution of the SINDBAD TEM. It handles the precomputation, spinup, and time-stepping processes.

- `timeLoopTEM`: Time loop for the SINDBAD TEM. It updates the land state for each time step.

    - `computeTEM`: Executes the `compute` function for all selected models, updating the land state for a given time step.

- `defineTEM`: Executes the `define` function for all selected models

- `precomputeTEM`: Executes the precompute function for all selected models


## Spinup

In SINDBAD, the **Spinup** is envisioned as a (collection of) step(s)/sequences within a bigger model simulation after which the ecosystem states and pools reach equilibrium for a given set of climate, model parameters, and land characteristics.
