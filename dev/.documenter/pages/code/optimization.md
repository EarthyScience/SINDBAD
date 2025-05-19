<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization' href='#SindbadOptimization'><span class="jlbinding">SindbadOptimization</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadOptimization
```


The `SindbadOptimization` package provides tools for optimizing SINDBAD models, including parameter estimation, model calibration, and cost function evaluation. It integrates various optimization algorithms and utilities to streamline the optimization workflow for SINDBAD experiments.

**Purpose:**

This package is designed to support optimization tasks in SINDBAD, such as calibrating model parameters to match observations or minimizing cost functions. It leverages multiple optimization libraries and provides a unified interface for running optimization routines.

**Dependencies:**
- `CMAEvolutionStrategy`: Provides the CMA-ES (Covariance Matrix Adaptation Evolution Strategy) algorithm for global optimization.
  
- `Evolutionary`: Supplies evolutionary algorithms for optimization, useful for non-convex problems.
  
- `ForwardDiff`: Enables automatic differentiation for gradient-based optimization methods.
  
- `MultistartOptimization`: Implements multistart optimization for finding global optima by running multiple local optimizations.
  
- `NLopt`: Provides a collection of nonlinear optimization algorithms, including derivative-free methods.
  
- `Optim`: Supplies optimization algorithms such as BFGS and LBFGS for gradient-based optimization.
  
- `Optimization`: A unified interface for various optimization backends, simplifying the integration of multiple libraries.
  
- `OptimizationOptimJL`: Integrates the `Optim` library into the `Optimization` interface.
  
- `OptimizationBBO`: Provides black-box optimization methods for derivative-free optimization.
  
- `OptimizationGCMAES`: Implements the GCMA-ES (Global Covariance Matrix Adaptation Evolution Strategy) algorithm.
  
- `OptimizationCMAEvolutionStrategy`: Integrates CMA-ES into the `Optimization` interface.
  
- `QuasiMonteCarlo`: Provides quasi-Monte Carlo methods for optimization, useful for high-dimensional problems.
  
- `StableRNGs`: Supplies stable random number generators for reproducible optimization results.
  
- `GlobalSensitivity`: Provides tools for global sensitivity analysis, including Sobol indices and variance-based sensitivity analysis.
  
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `SindbadUtils`: Provides utility functions for handling NamedTuple, spatial operations, and other helper tasks for spatial and temporal operations.
  
- `SindbadSetup`: Provides the SINDBAD setup.
  
- `SindbadTEM`: Provides the SINDBAD Terrestrial Ecosystem Model (TEM) as the target for optimization tasks.
  
- `SindbadMetrics`: Supplies metrics for evaluating model performance, which are used in cost function calculations.
  

**Included Files:**
1. **`prepOpti.jl`**:
  - Prepares the necessary inputs and configurations for running optimization routines.
    
  
2. **`optimizer.jl`**:
  - Implements the core optimization logic, including merging algorithm options and selecting optimization methods.
    
  
3. **`cost.jl`**:
  - Defines cost functions for evaluating the loss of SINDBAD models against observations.
    
  
4. **`optimizeTEM.jl`**:
  - Provides functions for optimizing SINDBAD TEM parameters for single locations or small spatial grids.
    
  - Functionality to handle optimization using large-scale 3D data YAXArrays cubes, enabling parameter calibration across spatial dimensions.
    
  
5. **`sensitivityAnalysis.jl`**:
  - Provides functions for performing sensitivity analysis on SINDBAD models, including global sensitivity analysis and local sensitivity analysis.
    
  

::: tip Note
- The package integrates multiple optimization libraries, allowing users to choose the most suitable algorithm for their problem.
  
- Designed to be modular and extensible, enabling users to customize optimization workflows for specific use cases.
  
- Supports both gradient-based and derivative-free optimization methods, ensuring flexibility for different types of cost functions.
  

:::

**Examples:**
1. **Running an experiment**:
  

```julia
using SindbadExperiment
# Set up experiment parameters
experiment_config = ...

# Run the experiment
runExperimentOpti(experiment_config)
```

1. **Running a CMA-ES optimization**:
  

```julia
using SindbadOptimization
optimized_params = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, CMAEvolutionStrategyCMAES())
```


</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.cost' href='#SindbadOptimization.cost'><span class="jlbinding">SindbadOptimization.cost</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
cost(parameter_vector, default_values, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, parameter_updater, cost_options, multi_constraint_method, parameter_scaling_type, cost_method<: CostMethod)
```


Calculate the cost for a parameter vector.

**Arguments**
- `parameter_vector`: Vector of parameter values to be optimized
  
- &#39;default_values&#39;: Default values for model parameters
  
- `selected_models`: Collection of selected models for simulation
  
- `space_forcing`: Forcing data for the main simulation period
  
- `space_spinup_forcing`: Forcing data for the spin-up period
  
- `loc_forcing_t`: Time-specific forcing data
  
- `output_array`: Array to store simulation outputs
  
- `space_output`: Spatial output configuration
  
- `space_land`: Land surface characteristics
  
- `tem_info`: Temporal information for simulation
  
- `observations`: Observed data for comparison
  
- `parameter_updater`: Function to update parameters
  
- `cost_options`: Options for cost function calculation
  
- `multi_constraint_method`: Method for handling multiple constraints
  
- `parameter_scaling_type`: Type of parameter scaling
  
- `sindbad_cost_method <: CostMethod`: a type parameter indicating cost calculation method
  

**Returns**

Cost value representing the difference between model outputs and observations

**sindbad_cost_method:**

**CostMethod**

Abstract type for cost calculation methods in SINDBAD

**Available methods/subtypes:**
- `CostModelObs`: cost calculation between model output and observations 
  
- `CostModelObsLandTS`: cost calculation between land model output and time series observations 
  
- `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
  
- `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.costLand' href='#SindbadOptimization.costLand'><span class="jlbinding">SindbadOptimization.costLand</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
costLand(parameter_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, parameter_updater, cost_options, multi_constraint_method, parameter_scaling_type)

costLand(parameter_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, _, land_init, tem_info, observations, parameter_updater, cost_options, multi_constraint_method, parameter_scaling_type)
```


Calculates the cost of SINDBAD model simulations for a single location by comparing model outputs as collections of SINDBAD `land` with observations using specified metrics and constraints.

In the first variant, the `land_time_series` is preallocated for computational efficiency. In the second variant, the runTEM stacks the land using map function and the preallocations is not necessary.

**Arguments:**
- `parameter_vector::AbstractArray`: A vector of model parameter values to be optimized.
  
- `selected_models`: A tuple of selected SINDBAD models in the given model structure, the parameters of which are optimized.
  
- `forcing`: A forcing NamedTuple containing the time series of environmental drivers for the simulation.
  
- `spinup_forcing`: A forcing NamedTuple for the spinup phase, used to initialize the model to a steady state.
  
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
  
- `land_timeseries`: A preallocated vector to store the land state for each time step during the simulation.
  
- `land_init`: The initial SINDBAD land NamedTuple containing all fields and subfields.
  
- `tem_info`: A nested NamedTuple containing necessary information for running SINDBAD TEM, including helpers, models, and spinup configurations.
  
- `observations`: A NamedTuple or vector of arrays containing observational data, uncertainties, and masks for calculating performance metrics.
  
- `parameter_updater`: A function to update model parameters based on the `parameter_vector`.
  
- `cost_options`: A table specifying how each observation constraint should be used to calculate the cost or performance metric.
  
- `multi_constraint_method`: A method for combining the vector of costs into a single cost value or vector, as required by the optimization algorithm.
  
- `parameter_scaling_type`: Specifies the type of scaling applied to the parameters during optimization.
  

**Returns:**
- `cost_metric`: A scalar or vector representing the cost, calculated by comparing model outputs with observations using the specified metrics and constraints.
  

::: tip Note
- The function updates the selected models using the `parameter_vector` and `parameter_updater`.
  
- It runs the SINDBAD TEM simulation for the specified location using `runTEM`.
  
- The model outputs are compared with observations using `metricVector`, which calculates the performance metrics.
  
- The resulting cost vector is combined into a single cost value or vector using `combineMetric` and the specified `multi_constraint_method`.
  

:::

**Examples:**
1. **Calculating cost for a single location**:
  

```julia
cost = costLand(parameter_vector, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, parameter_updater, cost_options, multi_constraint_method, parameter_scaling_type)
```

1. **Using a custom multi-constraint method**:
  

```julia
custom_method = CustomConstraintMethod()
cost = costLand(parameter_vector, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, parameter_updater, cost_options, custom_method, parameter_scaling_type)
```

1. **Handling observational uncertainties**:
  - Observations can include uncertainties and masks to refine the cost calculation, ensuring robust model evaluation.
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.getCostVectorSize' href='#SindbadOptimization.getCostVectorSize'><span class="jlbinding">SindbadOptimization.getCostVectorSize</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getCostVectorSize(algo_options, parameter_vector, ::OptimizationMethod || GSAMethod)
```


Calculates the size of the cost vector required for a specific optimization or sensitivity analysis method.

**Arguments:**
- `algo_options`: A NamedTuple or dictionary containing algorithm-specific options (e.g., population size, number of trajectories).
  
- `parameter_vector`: A vector of parameters used in the optimization or sensitivity analysis.
  
- `::OptimizationMethod`: The optimization or sensitivity analysis method. Supported methods include:
  - `CMAEvolutionStrategyCMAES`: Covariance Matrix Adaptation Evolution Strategy.
    
  - `GSAMorris`: Morris method for global sensitivity analysis.
    
  - `GSASobol`: Sobol method for global sensitivity analysis.
    
  - `GSASobolDM`: Sobol method with Design Matrices.
    
  

**Returns:**
- An integer representing the size of the cost vector required for the specified method.
  

**Notes:**
- For `CMAEvolutionStrategyCMAES`, the size is determined by the population size or a default formula based on the parameter vector length.
  
- For `GSAMorris`, the size is calculated as the product of the number of trajectories and the length of the design matrix.
  
- For `GSASobol`, the size is determined by the number of parameters and the number of samples.
  
- For `GSASobolDM`, the size is equivalent to that of `GSASobol`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.globalSensitivity' href='#SindbadOptimization.globalSensitivity'><span class="jlbinding">SindbadOptimization.globalSensitivity</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
globalSensitivity(cost_function, method_options, p_bounds, ::GSAMethod; batch=true)
```


Performs global sensitivity analysis using the specified method.

**Arguments:**
- `cost_function`: A function that computes the cost or output of the model based on input parameters.
  
- `method_options`: A set of options specific to the chosen sensitivity analysis method.
  
- `p_bounds`: A vector or matrix specifying the bounds of the parameters for sensitivity analysis.
  
- `::GSAMethod`: The sensitivity analysis method to use.
  
- `batch`: A boolean flag indicating whether to perform batch processing (default: `true`).
  

**Returns:**
- A `results` object containing the sensitivity indices and other relevant outputs for the specified method.
  

**algorithm:**

**GSAMethod**

Abstract type for global sensitivity analysis methods in SINDBAD

**Available methods/subtypes:**
- `GSAMorris`: Morris method for global sensitivity analysis 
  
- `GSASobol`: Sobol method for global sensitivity analysis 
  
- `GSASobolDM`: Sobol method with derivative-based measures for global sensitivity analysis 
  


---


**Extended help**

**Notes:**
- The function internally calls the `gsa` function from the GlobalSensitivity.jl package with the specified method and options.
  
- The `cost_function` should be defined to compute the model output based on the input parameters.
  
- The `method_options` argument allows fine-tuning of the sensitivity analysis process for each method.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.optimizeTEM' href='#SindbadOptimization.optimizeTEM'><span class="jlbinding">SindbadOptimization.optimizeTEM</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple)
```


**Arguments:**
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
  
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
  
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.optimizeTEMYax-NTuple{5, NamedTuple}' href='#SindbadOptimization.optimizeTEMYax-NTuple{5, NamedTuple}'><span class="jlbinding">SindbadOptimization.optimizeTEMYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
optimizeTEMYax(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, optim::NamedTuple, observations::NamedTuple; max_cache=1e9)
```


Optimizes the Terrestrial Ecosystem Model (TEM) parameters for each pixel by mapping over the YAXcube(s).

**Arguments**
- `forcing::NamedTuple`: Input forcing data for the TEM model
  
- `output::NamedTuple`: Output configuration settings
  
- `tem::NamedTuple`: TEM model parameters and settings
  
- `optim::NamedTuple`: Optimization parameters and settings
  
- `observations::NamedTuple`: Observed data for model calibration
  

**Keywords**
- `max_cache::Float64=1e9`: Maximum cache size for optimization process
  

**Returns**

Optimized TEM parameters cube

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.optimizer' href='#SindbadOptimization.optimizer'><span class="jlbinding">SindbadOptimization.optimizer</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, algorithm <: OptimizationMethod)
```


Optimize model parameters using various optimization algorithms.

**Arguments:**
- `cost_function`: A function handle that takes a parameter vector as input and calculates a cost/loss (scalar or vector).
  
- `default_values`: A vector of default parameter values to initialize the optimization.
  
- `lower_bounds`: A vector of lower bounds for the parameters.
  
- `upper_bounds`: A vector of upper bounds for the parameters.
  
- `algo_options`: A set of options specific to the chosen optimization algorithm.
  
- `algorithm`: The optimization algorithm to be used.
  

**Returns:**
- `optim_para`: A vector of optimized parameter values.
  

**algorithm:**

**OptimizationMethod**

Abstract type for optimization methods in SINDBAD

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
  


---


**Extended help**

**Notes:**
- The function supports a wide range of optimization algorithms, each tailored for specific use cases.
  
- Some methods do not require bounds for optimization, while others do.
  
- The `cost_function` should be defined by the user to calculate the loss based on the model output and observations. It is defined in cost.jl.
  
- The `algo_options` argument allows fine-tuning of the optimization process for each algorithm.
  
- Some algorithms (e.g., `BayesOptKMaternARD5`, `OptimizationBBOxnes`) require additional configuration steps, such as setting kernels or merging default and user-defined options.
  

**Examples:**
1. **Using CMAES from CMAEvolutionStrategy.jl**:
  

```julia
optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, CMAEvolutionStrategyCMAES())
```

1. **Using BFGS from Optim.jl**:
  

```julia
optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, OptimBFGS())
```

1. **Using Black Box Optimization (xNES) from Optimization.jl**:
  

```julia
optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, OptimizationBBOxnes())
```


**Implementation Details:**
- The function internally calls the appropriate optimization library and algorithm based on the `algorithm` argument.
  
- Each algorithm has its own implementation details, such as handling bounds, configuring options, and solving the optimization problem.
  
- The results are processed to extract the optimized parameter vector (`optim_para`), which is returned to the user.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.prepCostOptions' href='#SindbadOptimization.prepCostOptions'><span class="jlbinding">SindbadOptimization.prepCostOptions</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
prepCostOptions(observations, cost_options, ::CostMethod)
```


Prepares cost options for optimization by filtering variables with insufficient data points and setting up the required configurations.

**Arguments:**
- `observations`: A NamedTuple or a vector of arrays containing observation data, uncertainties, and masks used for calculating performance metrics or loss.
  
- `cost_options`: A table listing each observation constraint and its configuration for calculating the loss or performance metric.
  
- `::CostMethod`: A type indicating the cost function method. 
  

**Returns:**
- A filtered table of `cost_options` containing only valid variables with sufficient data points.
  

**cost methods:**

**CostMethod**

Abstract type for cost calculation methods in SINDBAD

**Available methods/subtypes:**
- `CostModelObs`: cost calculation between model output and observations 
  
- `CostModelObsLandTS`: cost calculation between land model output and time series observations 
  
- `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
  
- `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 
  


---


**Extended help**

**Notes:**
- The function iterates through the observation variables and checks if the number of valid data points meets the minimum threshold specified in `cost_options.min_data_points`.
  
- Variables with insufficient data points are excluded from the returned `cost_options`.
  
- The function modifies the `cost_options` table by adding:
  - `valids`: Indices of valid data points for each variable.
    
  - `is_valid`: A boolean flag indicating whether the variable meets the minimum data point requirement.
    
  
- Unnecessary fields such as `min_data_points`, `temporal_data_aggr`, and `aggr_func` are removed from the final `cost_options`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.prepOpti' href='#SindbadOptimization.prepOpti'><span class="jlbinding">SindbadOptimization.prepOpti</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
prepOpti(forcing, observations, info, cost_method::CostModelObs)
```


Prepares optimization parameters, settings, and helper functions based on the provided inputs.

**Arguments:**
- `forcing`: Input forcing data used for the optimization process.
  
- `observations`: Observed data used for comparison or calibration during optimization.
  
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of the experiment.
  
- `cost_method`: The method used to calculate the cost function. 
  

**Returns:**
- A NamedTuple `opti_helpers` containing:
  - `parameter_table`: Processed model parameters for optimization.
    
  - `cost_function`: A function to compute the cost for optimization.
    
  - `cost_options`: Options and settings for the cost function.
    
  - `default_values`: Default parameter values for the models.
    
  - `lower_bounds`: Lower bounds for the parameters.
    
  - `upper_bounds`: Upper bounds for the parameters.
    
  - `run_helpers`: Helper information for running the optimization.
    
  

**cost_method:**

**CostMethod**

Abstract type for cost calculation methods in SINDBAD

**Available methods/subtypes:**
- `CostModelObs`: cost calculation between model output and observations 
  
- `CostModelObsLandTS`: cost calculation between land model output and time series observations 
  
- `CostModelObsMT`: multi-threaded cost calculation between model output and observations 
  
- `CostModelObsPriors`: cost calculation between model output, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET 
  


---


**Extended help**

**Notes:**
- The function processes the input data and configuration to set up the optimization problem.
  
- It prepares model parameters, cost options, and helper functions required for the optimization process.
  
- Depending on the `cost_method`, the cost function is customized to handle specific data types or computation methods.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.prepParameters-Tuple{Any, Any}' href='#SindbadOptimization.prepParameters-Tuple{Any, Any}'><span class="jlbinding">SindbadOptimization.prepParameters</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
prepParameters(parameter_table, parameter_scaling)
```


Prepare model parameters for optimization by processing default and bounds of the parameters to be optimized.

**Arguments**
- `parameter_table`: Table of the parameters to be optimized
  
- `parameter_scaling`: Scaling method/type for parameter optimization
  

**Returns**

A tuple containing processed parameters ready for optimization

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.optimizeYax-Tuple' href='#SindbadOptimization.optimizeYax-Tuple'><span class="jlbinding">SindbadOptimization.optimizeYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
optimizeYax(map_cubes...; out::NamedTuple, tem::NamedTuple, optim::NamedTuple, forcing_vars::AbstractArray, obs_vars::AbstractArray)
```


A helper function to optimize parameters for each pixel by mapping over the YAXcube(s).

**Arguments**
- `map_cubes...`: Variadic input of cube maps to be optimized
  
- `out::NamedTuple`: Output configuration parameters
  
- `tem::NamedTuple`: TEM (Terrestrial Ecosystem Model) configuration parameters
  
- `optim::NamedTuple`: Optimization configuration parameters
  
- `forcing_vars::AbstractArray`: Array of forcing variables used in optimization
  
- `obs_vars::AbstractArray`: Array of observation variables used in optimization
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadOptimization.unpackYaxOpti-Tuple{Any}' href='#SindbadOptimization.unpackYaxOpti-Tuple{Any}'><span class="jlbinding">SindbadOptimization.unpackYaxOpti</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
unpackYaxOpti(args; forcing_vars::AbstractArray)
```


Unpacks the variables for the mapCube function

**Arguments**
- `all_cubes`: Collection of cubes containing input, output and optimization/observation variables
  
- `forcing_vars::AbstractArray`: Array specifying which variables should be forced/constrained
  

**Returns**

Unpacked data arrays

</details>

