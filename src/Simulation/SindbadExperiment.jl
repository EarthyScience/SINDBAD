"""
    Sindbad.Simulation

The `Sindbad.Simulation` module provides tools for designing, running, and analyzing experiments in the SINDBAD MDI framework. It integrates SINDBAD packages and utilities to streamline the experimental workflow, from data preparation to model execution and output analysis.

# Purpose:
This module acts as a high-level interface for conducting experiments using the SINDBAD framework. It leverages the functionality of core SINDBAD packages and provides additional utilities for running experiments and managing outputs.

# Dependencies:
- `SindbadTEM`: Provides the core SINDBAD models and types.
- `SindbadTEM.Utils`: Provides utility functions for handling data, spatial operations, and other helper tasks.
- `SetupSimulation`: Manages setup configurations, parameter handling, and shared types for SINDBAD experiments.
- `DataLoaders`: Handles data ingestion, preprocessing, and management for SINDBAD experiments.
- `SindbadTEM`: Implements the SINDBAD Terrestrial Ecosystem Model (TEM), enabling simulations for single locations, spatial grids, and cubes.
- `Sindbad.Optimization`: Provides optimization algorithms for parameter estimation and model calibration.
- `SindbadMetrics`: Supplies metrics for evaluating model performance and comparing simulations with observations.

# Included Files:
1. **`runExperiment.jl`**:
   - Contains functions for executing experiments, including setting up models, running simulations, and managing workflows.

2. **`saveOutput.jl`**:
   - Provides utilities for saving experiment outputs in various formats, ensuring compatibility with downstream analysis tools.

# Notes:
- The package re-exports core SINDBAD packages (`Sindbad`, `Utils`, `SetupSimulation`, `DataLoaders`, `SindbadTEM`, `Sindbad.Optimization`, `SindbadMetrics`) for convenience, allowing users to access their functionality directly through `Sindbad.Simulation`.
- Designed to be extensible, enabling users to customize and expand the experimental workflow as needed.
- Future extensions may include support for additional data formats (e.g., NetCDF, Zarr) and advanced output handling.

# Examples:
1. **Running an experiment**:
```julia
using Sindbad.Simulation
# Set up experiment parameters
experiment_config = ...

# Run the experiment
runExperimentForward(experiment_config)
```
"""
module Sindbad.Simulation
    using Sindbad.Simulation
    @reexport using Sindbad.Simulation
    @reexport using Utils

    include("runExperiment.jl")
    include("saveOutput.jl")

end # module Sindbad.Simulation
