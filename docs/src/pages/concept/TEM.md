# Terrestrial Ecosystem Model (TEM)

The Terrestrial Ecosystem Model (TEM) serves as the core component of SINDBAD's Model-Data Integration (MDI) framework. It provides a comprehensive system for:
- Representing ecosystem processes
- Implementing process modeling approaches
- Managing model execution (spinup, time loops, etc.)

## Model Components

### Ecosystem Processes

A **Model** represents a fundamental ecosystem process that can be modeled using various methods. Each model focuses on a specific, indivisible process. For example, rather than modeling `photosynthesis` as a single process, it can be decomposed into components like:
- `radiation use`
- `transpiration`
- Other sub-processes

### Modeling Approaches

An **Approach** defines the specific method used to calculate or emulate a process. For instance, `baseflow` generation might be modeled using:
- A `linear` approach (proportional to groundwater storage)
- Alternative methods based on different assumptions

### Core Methods

Every SINDBAD approach implements these fundamental methods:

1. **define**
   - Initializes memory allocation
   - Sets up required variables and arrays

2. **precompute**
   - Updates variables based on parameters/forcing
   - Prepares for time-dependent calculations

3. **compute**
   - Advances model state in time
   - Applies dynamic updates using current data

4. **update** (optional)
   - Modifies pools and variables
   - Handles within-time-step adjustments

## Parameter Estimation

Model parameters control process responses and are often uncertain. SINDBAD supports various parameter estimation methods:

1. **Parameter Calibration**
   - Based on modeling principles
   - Incorporates physical constraints

2. **Optimization**
   - Mathematical optimization techniques
   - Cost function minimization

3. **Machine Learning**
   - Parameter learning approaches
   - Data-driven estimation

## Model Structure

### Ecosystem Model

The core of SINDBAD's framework combines:
- Ecosystem processes
- Execution methods
- Initialization procedures
- Time-stepping algorithms

### Model Configuration

A Model Structure represents a collection of ecosystem processes designed for specific scientific objectives. It includes:
- Selected SINDBAD models
- Defined approaches
- Process dependencies

::: warning Model Dependencies
Models may have interdependencies. For example:
- `fAPAR` depends on `LAI`
- Required models must be included in the structure
:::

### Model Selection

Experiments can select models from:
- Standard SINDBAD models
- Custom model variants
- Subsets of available models

::: tip Viewing Available Models

```julia
using Sindbad
standard_sindbad_models
all_available_sindbad_models
```

:::

## Model Implementation Example

Here's an example of implementing a custom model structure for vegetation growth with water limitations:

```julia
# Define custom model structure
hypothetical_models = (
    :radiation,      # Handles radiation use
    :transpiration,  # Manages water use
    :soilwater,     # Controls soil moisture
    :allocation,    # Distributes resources
    :turnover       # Handles biomass changes
)

# Replace default models in experiment setup
hypothetical_replace_info = (;"model_structure.sindbad_models" => hypothetical_models)
info = getExperimentInfo(experiment_json; replace_info=hypothetical_replace_info)
```

::: tip Model Structure Configuration
- Models are selected through [model structure settings](../settings/model_structure.md)
- The `selected_models` field defines which models are active in an experiment
- Custom model structures must maintain required dependencies
:::

## Model Execution Details

The `runTEM` function manages the complete lifecycle of the TEM:

### Core Functions

1. **Initialization**
   - `defineTEM`: Initializes model variables and arrays
   - `precomputeTEM`: Updates variables based on new realizations

2. **Time Stepping**
   - `timeLoopTEM`: Manages the temporal evolution
   - `computeTEM`: Updates land state for each time step

3. **State Management**
   - `coreTEM`: Coordinates overall execution
   - Handles precomputation, spinup, and time-stepping

### Execution Flow

1. **Setup Phase**
   - Initialize model components
   - Configure parameters
   - Set up data structures

2. **Spinup Phase**
   - Run equilibrium iterations
   - Stabilize ecosystem states
   - Verify convergence

3. **Main Simulation**
   - Execute time steps
   - Update model states
   - Process outputs

## Spinup Configuration

The spinup process ensures model stability by:

1. **Initialization**
   - Set initial conditions
   - Configure climate forcing
   - Define convergence criteria

2. **Equilibrium Search**
   - Iterate model states
   - Monitor pool changes
   - Check convergence

3. **Validation**
   - Verify state stability
   - Check mass balance
   - Document final states

::: warning Spinup Considerations
- Ensure sufficient spinup duration
- Monitor convergence carefully
- Validate equilibrium conditions
- Document spinup configuration
:::

## Best Practices

1. **Model Selection**
   - Choose appropriate process representations
   - Consider computational requirements
   - Verify model dependencies
   - Test model combinations

2. **Parameter Management**
   - Document parameter sources
   - Validate parameter ranges
   - Consider uncertainty
   - Test sensitivity

3. **Execution**
   - Monitor convergence
   - Check mass balance
   - Validate results
   - Document configurations

4. **Spinup**
   - Verify equilibrium conditions
   - Check convergence criteria
   - Monitor state variables
   - Document spinup duration
