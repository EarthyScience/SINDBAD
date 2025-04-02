```@raw html
# SINDBAD TEM 
```
In SINDBAD, the Terrestrial Ecosystem Model (TEM) is a core component of the MDI framework. It encompasses ecosystem processes, approaches to model these processes, and the orchestration of their execution, including spinup, time loops, and other components.

## Ecosystem Processes

### SINDBAD Model

A Model represents an ecosystem process that can be modeled using various methods. Each model focuses on a specific process that cannot be further divided. For example, instead of modeling the broad process of `photosynthesis`, it can be broken into smaller components like `radiation use` or `transpiration`, which are modeled individually and combined to represent the larger process.

### SINDBAD Approach
An Approach is a method to calculate or emulate a process defined by a SINDBAD Model. For instance, the process of `baseflow` generation can be modeled using a `linear` approach, where baseflow is calculated as a linear function of groundwater storage.

### Approach Methods
The following core methods are defined for every SINDBAD approach:

- `define`: Initializes memory-allocating variables and arrays required for the approach.
- `precompute`: Updates defined variables and arrays with new realizations based on model parameters or forcing data, preparing the model for time-dependent computations.
- `compute`: Advances the model state in time by applying dynamic updates using precomputed variables and forcing data for the current time step.
- `update`: Optionally modifies pools and variables within a single time step.

## Parameters and Inversion
In SINDBAD, `Model parameters` are critical components that control the response of a modeled process. These parameters are often uncertain and can be estimated using `model/parameter inversion methods`. Inversion broadly includes techniques such as:

- Parameter calibration (modeling principles),
- Optimization (mathematical methods),
- Parameter learning (machine learning).

## Ecosystem Model

An Ecosystem Model is the core of SINDBAD's modeling framework. It includes:

- A combination of ecosystem processes.
- Methods to execute these processes, such as spinup, time-stepping, or one-time initialization.

### Model Structure

A Model Structure is a collection of ecosystem processes designed for a specific scientific goal. It includes a set of SINDBAD models, each with a defined approach for the experiment. SINDBAD allows full flexibility to *lego-build* model structures through settings.

::: warning

Models may have dependencies. For example, if ```fAPAR``` depends on ```LAI```, the *model structure must include LAI*.

:::

The default model structure is stored in the standard_sindbad_models variable, which can be overridden during experimental setup.

Example:

To override the default model structure, pass it through the `replace_info` in experimental setup. For example, a *hypothetical ecosystem model* that can simulate vegetation growth while considering water limitations can be used to replace the standard models as,


```julia
    hypothetical_models = (
        :radiation,      # Handles radiation use
        :transpiration,  # Manages water use
        :soilwater,     # Controls soil moisture
        :allocation,    # Distributes resources
        :turnover       # Handles biomass changes
    )
    hypothetical_replace_info = (;"model_structure.sindbad_models" => hypothetical_models)
    info = getExperimentInfo(experiment_json; replace_info=hypothetical_replace_info);
```

::: tip

To view standard and all available SINDBAD models:

```julia
using Sindbad
standard_sindbad_models
all_available_sindbad_models
```

:::

### Model Selection

From the list of standard models or user-defined variant of it, which can be a subset of all available sindbad models, an experiment can select a set of models suited for the goal. This is so called ```selected_models``` of an experiment which are [set through model structure settings](../settings/model_structure.md). 

## runTEM

The runTEM component/function orchestrates the execution of the SINDBAD TEM. It includes initialization, spinup, and time-stepping processes for the selected model structure.

- `coreTEM`: Handles the core execution of the SINDBAD TEM, including precomputation, spinup, and time-stepping.
- `timeLoopTEM`: Executes the time loop for the SINDBAD TEM, updating the land state for each time step.
- `computeTEM`: Executes the compute function for all selected models, updating the land state for a given time step.
- `defineTEM`: Executes the define function for all selected models, initializing variables and arrays.
`precomputeTEM`: Executes the precompute function for all selected models, updating variables and arrays based on new realizations.

# Spinup
In SINDBAD, Spinup is a sequence of steps within a larger model simulation. Its purpose is to bring ecosystem states and pools to equilibrium for a given set of climate conditions, model parameters, and land characteristics. Spinup ensures that the model starts from a stable state before proceeding with time-dependent calculations.
