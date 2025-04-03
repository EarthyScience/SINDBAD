"""
    SindbadExperiment

The `SindbadExperiment` package provides tools for designing, running, and analyzing experiments in the SINDBAD MDI framework. It integrates core SINDBAD packages and utilities to streamline the experimental workflow, from data preparation to model execution and output analysis.

# Purpose:
This package acts as a high-level interface for conducting experiments using the SINDBAD framework. It leverages the functionality of core SINDBAD packages and provides additional utilities for running experiments and managing outputs.

# Dependencies:
- `Sindbad`: The core SINDBAD package, providing foundational types and utilities for the SINDBAD framework.
- `SindbadUtils`: Provides utility functions for handling data, spatial operations, and other helper tasks.
- `SindbadSetup`: Manages setup configurations, parameter handling, and shared types for SINDBAD experiments.
- `SindbadData`: Handles data ingestion, preprocessing, and management for SINDBAD experiments.
- `SindbadTEM`: Implements the SINDBAD Terrestrial Ecosystem Model (TEM), enabling simulations for single locations, spatial grids, and cubes.
- `SindbadOptimization`: Provides optimization algorithms for parameter estimation and model calibration.
- `SindbadMetrics`: Supplies metrics for evaluating model performance and comparing simulations with observations.

# Included Files:
1. **`runExperiment.jl`**:
   - Contains functions for executing experiments, including setting up models, running simulations, and managing workflows.

2. **`saveOutput.jl`**:
   - Provides utilities for saving experiment outputs in various formats, ensuring compatibility with downstream analysis tools.

# Notes:
- The package re-exports core SINDBAD packages (`Sindbad`, `SindbadUtils`, `SindbadSetup`, `SindbadData`, `SindbadTEM`, `SindbadOptimization`, `SindbadMetrics`) for convenience, allowing users to access their functionality directly through `SindbadExperiment`.
- Designed to be extensible, enabling users to customize and expand the experimental workflow as needed.
- Future extensions may include support for additional data formats (e.g., NetCDF, Zarr) and advanced output handling.

# Examples:
1. **Running an experiment**:
```julia
using SindbadExperiment
# Set up experiment parameters
experiment_config = ...

# Run the experiment
runExperiment(experiment_config)
```

2. **Saving experiment outputs**:
```julia
using SindbadExperiment
# Save outputs to a file
saveOutput(output_data, "results.nc")
```
"""
module SindbadExperiment
    using Sindbad
    @reexport using Sindbad
    @reexport using SindbadUtils
    @reexport using SindbadSetup
    @reexport using SindbadData
    @reexport using SindbadTEM
    @reexport using SindbadOptimization
    @reexport using SindbadMetrics

    include("runExperiment.jl")
    include("saveOutput.jl")

end # module SindbadExperiment
