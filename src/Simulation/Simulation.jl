"""
    Simulation

The `Simulation` module provides the core functionality for running the SINDBAD Terrestrial Ecosystem Model (TEM). It includes utilities for preparing model-ready objects, managing spinup processes and running models.

# Purpose:
This module integrates various components and utilities required to execute the SINDBAD TEM, including precomputations, spinup, and time loop simulations. It supports parallel execution and efficient handling of large datasets.

# Dependencies:
- `ComponentArrays`: Used for managing complex, hierarchical data structures like land variables and model states.
- `NLsolve`: Used for solving nonlinear equations, particularly in spinup processes (e.g., fixed-point solvers).
- `ProgressMeter`: Displays progress bars for long-running simulations, improving user feedback.
- `SindbadTEM`: Provides the core SINDBAD models and types.
- `DataLoaders`: Provides the SINDBAD data handling functions.
- `SindbadTEM.Utils`: Provides utility functions for handling NamedTuple, spatial operations, and other helper tasks for spatial and temporal operations.
- `SetupSimulation`: Provides the SINDBAD setup functions.
- `ThreadPools`: Enables efficient thread-based parallelization for running simulations across multiple locations.

# Included Files:
1. **`utilsSimulation.jl`**:
   - Core helpers for extracting forcing slices, managing outputs, logging progress, and orchestrating helper NamedTuples.

2. **`deriveSpinupForcing.jl`**:
   - Provides functionality for deriving spinup forcing data, which is used to force the model during initialization to a steady state.

3. **`prepTEMOut.jl`**:
   - Handles the preparation of output structures, ensuring that results are stored efficiently during simulations.

4. **`runModels.jl`**:
   - Contains functions for executing individual models within the SINDBAD framework.

5. **`prepTEM.jl`**:
   - Prepares the necessary inputs and configurations for running the TEM, including spatial and temporal data preparation.

6. **`runTEMLoc.jl`**:
   - Implements the logic for running the TEM for a single location, including optional spinup and the main simulation loop.

7. **`runTEMSpace.jl`**:
   - Extends the functionality to handle spatial grids, enabling simulations across multiple locations with parallel execution.

8. **`runTEMCube.jl`**:
   - Adds support for running the TEM on 3D `YAXArrays` cubes, useful for large-scale simulations with spatial dimensions.

9. **`runExperiment.jl`**:
   - High-level orchestration that wires setup, simulation, and optional optimization/ML hooks into a repeatable workflow.

10. **`saveOutput.jl`**:
    - Serialization helpers for storing simulation outputs and diagnostics.

11. **`spinupTEM.jl`**:
   - Manages the spinup process, initializing the model to a steady state using various methods (e.g., ODE solvers, fixed-point solvers).

12. **`spinupSequence.jl`**:
    - Handles sequential spinup loops, allowing for iterative refinement of model states during the spinup process.

# Notes:
- The package is designed to be modular and extensible, allowing users to customize and extend its functionality for specific use cases.
- It integrates tightly with the SINDBAD framework, leveraging shared types and utilities from `SetupSimulation`.
"""
module Simulation
   using ComponentArrays
   using NLsolve
   using ProgressMeter
   using SindbadTEM
   using SindbadTEM.Utils
   using ..SetupSimulation
   using ..DataLoaders
   using ..Visualization
   using ..Optimization
   using ThreadPools

   include("utilsSimulation.jl")
   include("deriveSpinupForcing.jl")
   include("prepTEMOut.jl")
   include("runModels.jl")
   include("prepTEM.jl")
   include("runTEMLoc.jl")
   include("runTEMSpace.jl")
   include("runTEMCube.jl")
   include("spinupTEM.jl")
   include("spinupSequence.jl")
   include("runExperiment.jl")
   include("saveOutput.jl")

end # module Simulation
