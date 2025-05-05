# Optimization Methods in SINDBAD

This documentation provides a comprehensive overview of optimization methods in SINDBAD, including available methods, configuration settings, and how to implement new ones.

## Overview

SINDBAD uses a type-based dispatch system for optimization methods, allowing for flexible and extensible optimization approaches. The optimization process is configured through JSON files and can be customized for different experiments.

## Configuration

Optimization settings are defined in the `optimization.json` file:

```json
{
  "algorithm_optimization": "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
  "model_parameters_to_optimize": {
    "autoRespiration,RMN": null,
    "gppAirT,opt_airT": null
  },
  "multi_constraint_method": "metric_sum",
  "observational_constraints": [
    "gpp",
    "nee",
    "reco"
  ],
  "observations": {
    "default_cost": {
      "cost_metric": "NSE_inv",
      "cost_weight": 1.0
    }
  }
}
```

Key components:
- `algorithm_optimization`: Path to the optimization algorithm configuration or direct algorithm name
- `model_parameters_to_optimize`: Parameters to be optimized
- `multi_constraint_method`: Method for combining multiple constraints
- `observational_constraints`: Variables to be used as constraints
- `observations`: Cost metric and weight settings

### Algorithm Optimization Configuration

The `algorithm_optimization` field can be specified in two ways:

1. **Path to JSON File**
   ```json
   "algorithm_optimization": "opti_algorithms/CMAEvolutionStrategy_CMAES.json"
   ```
   This points to a JSON file containing the algorithm configuration, which should include:
   ```json
   {
     "algorithm": "CMAEvolutionStrategy_CMAES",
     "parameters": {
       "max_iterations": 1000,
       "tolerance": 1e-6,
       "population_size": 50
     }
   }
   ```

2. **Direct Algorithm Name**
   ```json
   "algorithm_optimization": "CMAEvolutionStrategy_CMAES"
   ```
   When specified as a string, it uses default parameters for the algorithm.

:::info

Using a JSON file for `algorithm_optimization` allows for:
- Custom parameter tuning
- Different configurations for different experiments
- Easy switching between algorithm settings

:::

## Available Optimization Methods

:::tip

To list all available optimization methods and their purposes, use:
```julia
using SindbadUtils
showMethodsOf(SindbadOptimizationMethod)
```
This will display a formatted list of all optimization methods and their descriptions.

:::

:::tip

To get default options for any optimization method, use `sindbadDefaultOptions`:

```julia
# Get default options for CMA-ES
opts = sindbadDefaultOptions(CMAEvolutionStrategyCMAES())
# Returns: (maxfevals = 50,)

# Get default options for Morris method
opts = sindbadDefaultOptions(GlobalSensitivityMorris())
# Returns: (total_num_trajectory = 200, num_trajectory = 15, len_design_mat = 10)

# Get default options for Sobol method
opts = sindbadDefaultOptions(GlobalSensitivitySobol())
# Returns: (samples = 5, method_options = (order = [0, 1],), sampler = "Sobol", sampler_options = ())
```

These default options can be used as a starting point for customizing optimization parameters in your configuration files.

:::

Current methods include:

### Bayesian Optimization
- `BayesOptKMaternARD5`: Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl

### Evolution Strategies
- `CMAEvolutionStrategyCMAES`: Covariance Matrix Adaptation Evolution Strategy (CMA-ES) from CMAEvolutionStrategy.jl
- `EvolutionaryCMAES`: CMA-ES implementation from Evolutionary.jl

### Gradient-based Methods
- `OptimLBFGS`: Limited-memory BFGS method from Optim.jl
- `OptimBFGS`: BFGS method from Optim.jl
- `OptimizationBFGS`: BFGS method from Optimization.jl
- `OptimizationFminboxGradientDescent`: Fminbox Gradient Descent method from Optimization.jl
- `OptimizationFminboxGradientDescentFD`: Fminbox Gradient Descent with forward differentiation from Optimization.jl

### Black Box Optimization
- `OptimizationBBOadaptive`: Black Box Optimization (adaptive) method from Optimization.jl
- `OptimizationBBOxnes`: Black Box Optimization (xNES) method from Optimization.jl

### Other Methods
- `OptimizationGCMAESDef`: GCMAES method from Optimization.jl
- `OptimizationGCMAESFD`: GCMAES method with forward differentiation from Optimization.jl
- `OptimizationMultistartOptimization`: Multistart Optimization method from Optimization.jl
- `OptimizationNelderMead`: Nelder-Mead method from Optimization.jl
- `OptimizationQuadDirect`: QuadDIRECT method from Optimization.jl

## Adding a New Optimization Method

### 1. Define the New Optimization Method Type

In `runtimeDispatchTypes.jl`, add a new struct that subtypes `SindbadOptimizationMethod`:

```julia
import SindbadUtils: purpose

# Define the new optimization type
struct YourNewOptimizationMethod <: SindbadOptimizationMethod end

# Define its purpose
purpose(::Type{YourNewOptimizationMethod}) = "Description of what YourNewOptimizationMethod does"
```

:::info

When naming new optimization types that use external packages, follow the convention `PackageNameMethodName`. For example:
- `CMAEvolutionStrategyCMAES` for the CMA-ES method from CMAEvolutionStrategy.jl
- `OptimizationBFGS` for the BFGS method from Optimization.jl
- `BayesOptKMaternARD5` for the Matern 5/2 kernel method from BayesOpt.jl

This convention helps identify both the package and the specific method being used.

:::

### 2. Set Default Options

In `defaultOptions.jl`, add default options for your new optimization method:

```julia
# Add default options for your new method
sindbadDefaultOptions(::YourNewOptimizationMethod) = (
    max_iterations = 1000,
    tolerance = 1e-6,
    population_size = 50,
    # Add other default parameters specific to your method
)
```

:::tip

When setting default options:
1. Choose reasonable default values that work well for most cases
2. Include all essential parameters needed by the optimization method
3. Use descriptive parameter names that match the underlying package's terminology
4. Consider adding parameters for:
   - Convergence criteria (e.g., `max_iterations`, `tolerance`)
   - Population/ensemble settings (e.g., `population_size`)
   - Algorithm-specific parameters
   - Performance tuning options

:::

:::warning Make sure:

1. Test the default options with different problem sizes
3. Consider adding validation for parameter values in your implementation
4. Keep the default options simple but flexible enough for common use cases

:::

### 3. Implement the Optimization Function

In `optimizer.jl`, implement your optimization function with the following signature:

```julia
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::YourNewOptimizationMethod)
    # Your implementation here
end
```

The function should:
1. Set up the optimization problem
2. Configure the algorithm parameters
3. Run the optimization
4. Return the results

Example implementation structure:
```julia
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::YourNewOptimizationMethod)
    # Set up optimization problem
    problem = OptimizationProblem(
        cost_function,
        default_values,
        lower_bounds,
        upper_bounds
    )
    
    # Configure algorithm
    algorithm = YourAlgorithm(; algo_options...)
    
    # Run optimization
    result = optimize(problem, algorithm)
    
    return result
end
```

### 4. Update Algorithm Configuration (if needed)

If your method requires special configuration, update the algorithm configuration file:

```json
{
  "algorithm": "your_new_method",
  "parameters": {
    "max_iterations": 1000,
    "tolerance": 1e-6,
    "population_size": 50
  }
}
```

## Important Considerations

1. **Parameter Handling**
   - Ensure proper handling of parameter bounds
   - Implement appropriate scaling if needed
   - Consider parameter constraints

2. **Performance**
   - Optimize for large parameter sets
   - Consider parallelization opportunities
   - Implement efficient memory management

3. **Convergence**
   - Set appropriate stopping criteria
   - Handle numerical stability
   - Implement error handling

4. **Documentation**
   - Add comprehensive docstrings
   - Include usage examples
   - Document any special requirements

## Testing

After implementing your new optimization method:
1. Test with small parameter sets
2. Verify convergence behavior
3. Check performance with larger parameter sets
4. Ensure compatibility with different cost functions

## Best Practices

1. **Algorithm Selection**
   - Choose appropriate algorithm for the problem type
   - Consider problem dimensionality
   - Account for computational resources

2. **Parameter Configuration**
   - Set reasonable bounds
   - Configure appropriate stopping criteria
   - Adjust population sizes if needed

3. **Performance Optimization**
   - Implement efficient data structures
   - Consider parallelization
   - Optimize memory usage

4. **Error Handling**
   - Handle numerical instabilities
   - Implement appropriate fallbacks
   - Provide informative error messages 