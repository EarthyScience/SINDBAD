# SINDBAD Helper Functions

This document provides an overview of useful helper functions in the SINDBAD framework.

## Data Management Functions

### `getSindbadDataDepot`

```julia
getSindbadDataDepot(; env_data_depot_var="SINDBAD_DATA_DEPOT", local_data_depot="../data")
```

Retrieves the path to the SINDBAD data depot, which is used for storing and accessing data files.

**Arguments**
- `env_data_depot_var`: Environment variable name for the data depot (default: "SINDBAD_DATA_DEPOT")
- `local_data_depot`: Local path to the data depot (default: "../data")

**Returns**
The path to the SINDBAD data depot, determined by:
1. First checking the environment variable specified by `env_data_depot_var`
2. If not found, falling back to the `local_data_depot` path

**Usage**
```julia
# Get the data depot path
data_path = getSindbadDataDepot()

# Use custom environment variable
data_path = getSindbadDataDepot(env_data_depot_var="CUSTOM_DATA_DEPOT")

# Use custom local path
data_path = getSindbadDataDepot(local_data_depot="path/to/data")
```

::: tip

SINDBAD uses `getSindbadDataDepot` to convert relative data paths to absolute data path. In case of sharing data directory across experiments, set the environment variable `SINDBAD_DATA_DEPOT`. In UNIX-like systems, add the following in `.bashrc`/SHELL settings.

```bash
export SINDBAD_DATA_DEPOT="/Path/To/A/DIRECTORY"
```

:::

## Variable Information Functions

### `getVariableInfo`

```julia
getVariableInfo(vari_b::Symbol, t_step="day")
getVariableInfo(vari_b, t_step="day")
```

Retrieves detailed information about a SINDBAD variable from the variable catalog.

**Arguments**
- `vari_b`: The variable name (either as a Symbol or in the form of field__subfield)
- `t_step`: Time step of the variable (default: "day")

**Returns**
A dictionary containing the following information about the variable:
- `standard_name`: The standard name of the variable
- `long_name`: A longer description of the variable
- `units`: The units of the variable (with time step replaced if applicable)
- `land_field`: The field in the SINDBAD model where the variable is used
- `description`: A detailed description of the variable

**Usage**
```julia
# Get information about a variable
var_info = getVariableInfo(:fluxes__gpp)

# Get information with custom time step
var_info = getVariableInfo(:fluxes__gpp, "hour")
```

### `whatIs`

```julia
whatIs(var_name::String)
whatIs(var_field::String, var_sfield::String)
whatIs(var_field::Symbol, var_sfield::Symbol)
whatIs(var_name::Symbol)
```

A helper function to display information about a SINDBAD variable from the variable catalog.

**Arguments**
- `var_name`: The full variable name (e.g., "land.fluxes.gpp" or "fluxes__gpp")
- `var_field`: The field name of the variable (e.g., "fluxes")
- `var_sfield`: The subfield name of the variable (e.g., "gpp")

**Behavior**
- Checks if the variable exists in the SINDBAD variable catalog
- If the variable exists, displays its complete information
- If the variable doesn't exist, displays a template for adding it to the catalog
- Automatically handles different input formats (String or Symbol)

**Usage**
```julia
# Using full variable name
whatIs("land.fluxes.gpp")
whatIs(:fluxes__gpp)

# Using field and subfield separately
whatIs("fluxes", "gpp")
whatIs(:fluxes, :gpp)
```

::: tip

When Sindbad is imported, `sindbad_variables` with all the variables in the catalog is available automatically.

`whatIs` is particularly useful for:
- Quickly looking up variable information during development
- Checking if a variable is properly documented in the catalog
- Getting a template for adding new variables to the catalog
- Understanding the structure and naming conventions of SINDBAD variables

:::

## Model Parameter Functions

### `modelParameter`

```julia
modelParameter(models, model::Symbol)
modelParameter(model::LandEcosystem, show=true)
```

Returns and optionally displays the current parameters of a given SINDBAD model.

**Arguments**
- `models`: A list/collection of SINDBAD models (required when `model` is a Symbol)
- `model::Symbol`: A SINDBAD model name
- `model::LandEcosystem`: A SINDBAD model instance of type LandEcosystem
- `show::Bool`: Flag to print parameters to the screen (default: true)

**Returns**
- For `model::LandEcosystem`: A vector of parameter information pairs
- For `model::Symbol`: An OrderedDict containing parameter names and values

**Usage**
```julia
# get models from info
selected_models = info.models.forward
# Display parameters of a specific model
modelParameter(selected_models, :gpp)
```

### `modelParameters`

```julia
modelParameters(selected_models)
```

Displays the current parameters of all given SINDBAD models.

**Arguments**
- `models`: A list/collection of SINDBAD models

**Usage**
```julia
# Display parameters of all models
modelParameters(selected_models)
```

## Configuration Functions

### `sindbadDefaultOptions`

```julia
sindbadDefaultOptions(::MethodType)
```

Retrieves the default configuration options for optimization or sensitivity analysis methods in SINDBAD.

**Arguments**
- `::MethodType`: The method type for which default options are requested. Supported types:
  - `SindbadOptimizationMethod`: General optimization methods
  - `SindbadGlobalSensitivityMethod`: General global sensitivity analysis methods
  - `GlobalSensitivityMorris`: Morris method for global sensitivity analysis
  - `GlobalSensitivitySobol`: Sobol method for global sensitivity analysis
  - `GlobalSensitivitySobolDM`: Sobol method with derivative-based measures
  - `CMAEvolutionStrategyCMAES`: CMA-ES optimization method

**Returns**
A `NamedTuple` containing the default options for the specified method.

**Default Options by Method**
- `GlobalSensitivityMorris`: 
  - `total_num_trajectory = 200`
  - `num_trajectory = 15`
  - `len_design_mat = 10`
- `GlobalSensitivitySobol`:
  - `samples = 5`
  - `method_options = (order=[0, 1])`
  - `sampler = "Sobol"`
  - `sampler_options = ()`
- `CMAEvolutionStrategyCMAES`:
  - `maxfevals = 50`

**Usage**
```julia
# Get default options for Morris method
opts = sindbadDefaultOptions(GlobalSensitivityMorris())

# Get default options for Sobol method
opts = sindbadDefaultOptions(GlobalSensitivitySobol())
```

## Model and Definition Functions

### `getSindbadModels`

```julia
getSindbadModels()
```

Retrieves a dictionary of SINDBAD models and their approaches.

**Returns**
A dictionary containing:
- Keys: Model names as symbols
- Values: Corresponding model approaches and implementations

**Usage**
```julia
# Get all SINDBAD models and their approaches
models = getSindbadModels()
```

::: tip

`getSindbadModels` is particularly useful for:
- Discovering available models in `standard_sindbad_models` in the SINDBAD framework

:::

### `getSindbadDefinitions`

```julia
getSindbadDefinitions(sindbad_module, what_to_get; internal_only=true)
```

Returns all defined (and optionally internal) objects in the SINDBAD framework.

**Arguments**
- `sindbad_module`: The module to search for defined things
- `what_to_get`: The type of things to get (e.g., Type, Function)
- `internal_only`: Whether to only include internal definitions (default: true)

**Returns**
An array of all defined things in the SINDBAD framework that match the specified type.

**Usage**
```julia
# Get all defined types in the SINDBAD framework
defined_types = getSindbadDefinitions(Sindbad, Type)

# Get all functions in a specific module
functions = getSindbadDefinitions(Sindbad.Models, Function)

# Get all definitions including external ones
all_definitions = getSindbadDefinitions(Sindbad, Any, internal_only=false)
```

::: tip

`getSindbadDefinitions` is particularly useful for:
- Discovering available types and functions in SINDBAD modules
- Understanding the structure of SINDBAD's codebase
- Accessing internal implementations for debugging or development

:::
