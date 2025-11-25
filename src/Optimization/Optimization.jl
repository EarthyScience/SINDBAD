"""
    Optimization

The `Optimization` module provides tools for optimizing SINDBAD models, including parameter estimation, model calibration, and cost function evaluation. It integrates various optimization algorithms and utilities to streamline the optimization workflow for SINDBAD experiments.

# Purpose:
This module is designed to support optimization tasks in SINDBAD, such as calibrating model parameters to match observations or minimizing cost functions. It leverages multiple optimization libraries and provides a unified interface for running optimization routines.

# Dependencies:
- `CMAEvolutionStrategy`: Covariance Matrix Adaptation Evolution Strategy backend.
- `Evolutionary`: Additional evolutionary/metaheuristic optimizers.
- `ForwardDiff`: Automatic differentiation for gradient-based workflows.
- `MultistartOptimization`: Multi-start orchestration utilities.
- `NLopt`: Large suite of derivative-free and gradient-based optimizers.
- `Optim`: Quasi-Newton and trust-region algorithms (BFGS, LBFGS, etc.).
- `Optimization` + `OptimizationOptimJL`: SciML interface plus the Optim bridge.
- `OptimizationGCMAES` / `OptimizationCMAEvolutionStrategy`: Extra CMA-ES variants exposed through `Optimization`.
- `QuasiMonteCarlo`: Low-discrepancy sequence sampling (initial populations, Sobol sets, etc.).
- `StableRNGs`: Reproducible random number generation for stochastic optimizers.
- `GlobalSensitivity`: Sobol/variance-based sensitivity tooling for pre/post analysis.
- `SindbadTEM` and `SindbadTEM.Utils`: Core TEM types and helper utilities.
- `SindbadTEM.Metrics`: Metric/cost definitions referenced during optimization.
- `Sindbad.SetupSimulation` / `Sindbad.Simulation`: Provide the experiment `info` and runtime hooks the optimizers call.

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

5. **`sensitivityAnalysis.jl`**:
   - Provides functions for performing sensitivity analysis on SINDBAD models, including global sensitivity analysis and local sensitivity analysis.

!!! note
    - The package integrates multiple optimization libraries, allowing users to choose the most suitable algorithm for their problem.
    - Designed to be modular and extensible, enabling users to customize optimization workflows for specific use cases.
    - Supports both gradient-based and derivative-free optimization methods, ensuring flexibility for different types of cost functions.

# Examples:
1. **Running an experiment**:
```julia
using Sindbad.Simulation
# Set up experiment parameters
experiment_config = ...

# Run the experiment
runExperimentOpti(experiment_config)
```
2. **Running a CMA-ES optimization**:
```julia
using Sindbad.Optimization
optimized_params = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, CMAEvolutionStrategyCMAES())
```
"""
module Optimization

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
   # using OptimizationBBO
   using OptimizationGCMAES
   using OptimizationCMAEvolutionStrategy
   # using OptimizationQuadDIRECT
   using QuasiMonteCarlo
   using StableRNGs
   using SindbadTEM
   using SindbadTEM.Utils
   using SindbadTEM.Metrics
   using ..SetupSimulation
   # using ..Simulation

   include("prepOpti.jl")
   include("optimizer.jl")
   include("cost.jl")
   include("optimizeTEM.jl")
   include("sensitivityAnalysis.jl")

end # module Optimization
