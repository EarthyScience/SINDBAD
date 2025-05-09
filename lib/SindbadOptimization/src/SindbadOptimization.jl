"""
    SindbadOptimization

The `SindbadOptimization` package provides tools for optimizing SINDBAD models, including parameter estimation, model calibration, and cost function evaluation. It integrates various optimization algorithms and utilities to streamline the optimization workflow for SINDBAD experiments.

# Purpose:
This package is designed to support optimization tasks in SINDBAD, such as calibrating model parameters to match observations or minimizing cost functions. It leverages multiple optimization libraries and provides a unified interface for running optimization routines.

# Dependencies:
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
- `SindbadTEM`: Provides the SINDBAD Terrestrial Ecosystem Model (TEM) as the target for optimization tasks.
- `SindbadMetrics`: Supplies metrics for evaluating model performance, which are used in cost function calculations.

# Included Files:
1. **`prepOpti.jl`**:
   - Prepares the necessary inputs and configurations for running optimization routines.

2. **`optimizer.jl`**:
   - Implements the core optimization logic, including merging algorithm options and selecting optimization methods.

3. **`cost.jl`**:
   - Defines cost functions for evaluating the loss of SINDBAD models against observations.

4. **`optimizeTEM.jl`**:
   - Provides functions for optimizing SINDBAD TEM parameters for single locations or small spatial grids.
   - Functionality to handle optimization using large-scale 3D data YAXArrays cubes, enabling parameter calibration across spatial dimensions.

!!! note
    - The package integrates multiple optimization libraries, allowing users to choose the most suitable algorithm for their problem.
    - Designed to be modular and extensible, enabling users to customize optimization workflows for specific use cases.
    - Supports both gradient-based and derivative-free optimization methods, ensuring flexibility for different types of cost functions.

# Examples:
1. **Running a CMA-ES optimization**:
```julia
using SindbadOptimization
optimized_params = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, CMAEvolutionStrategyCMAES())
```

2. **Optimizing SINDBAD TEM parameters**:
```julia
using SindbadOptimization
results = optimizeTEM(model, forcing, observations, info)
```
"""
module SindbadOptimization

   using CMAEvolutionStrategy: minimize, xbest
   # using BayesOpt: ConfigParameters, set_kernel!, bayes_optimization, SC_MAP
   using Evolutionary: Evolutionary
   using ForwardDiff
   using GlobalSensitivity
   using MultistartOptimization: MultistartOptimization
   using NLopt: NLopt
   using Optim
   using Optimization
   using OptimizationOptimJL
   using OptimizationBBO
   using OptimizationGCMAES
   using OptimizationCMAEvolutionStrategy
   # using OptimizationQuadDIRECT
   using QuasiMonteCarlo
   using StableRNGs
   using Sindbad
   using SindbadUtils
   using SindbadSetup
   using SindbadTEM
   using SindbadMetrics

   include("prepOpti.jl")
   include("optimizer.jl")
   include("cost.jl")
   include("optimizeTEM.jl")
   include("sensitivityAnalysis.jl")

end # module SindbadOptimization
