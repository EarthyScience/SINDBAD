"""
    TEM

The `TEM` module provides the core functionality for running the SINDBAD Terrestrial Ecosystem Model (TEM). It includes utilities for preparing model-ready objects, managing spinup processes and running models.

# Purpose:
This module integrates various components and utilities required to execute the SINDBAD TEM, including precomputations, spinup, and time loop simulations. It supports parallel execution and efficient handling of large datasets.

# Dependencies:
- `ComponentArrays`: Used for managing complex, hierarchical data structures like land variables and model states.
- `NLsolve`: Used for solving nonlinear equations, particularly in spinup processes (e.g., fixed-point solvers).
- `ProgressMeter`: Displays progress bars for long-running simulations, improving user feedback.
- `Sindbad`: Provides the core SINDBAD models and types.
- `SindbadData`: Provides the SINDBAD data handling functions.
- `SindbadUtils`: Provides utility functions for handling NamedTuple, spatial operations, and other helper tasks for spatial and temporal operations.
- `SindbadSetup`: Provides the SINDBAD setup functions.
- `ThreadPools`: Enables efficient thread-based parallelization for running simulations across multiple locations.

# Included Files:
1. **`utilsTEM.jl`**:
   - Contains utility functions for handling extraction of forcing data, managing/filling outputs, and other helper operations required during TEM execution.

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
   - Adds support for running the TEM on 3D data YAXArrayscubes, useful for large-scale simulations with spatial dimensions.

9. **`spinupTEM.jl`**:
   - Manages the spinup process, initializing the model to a steady state using various methods (e.g., ODE solvers, fixed-point solvers).

10. **`spinupSequence.jl`**:
    - Handles sequential spinup loops, allowing for iterative refinement of model states during the spinup process.

# Notes:
- The package is designed to be modular and extensible, allowing users to customize and extend its functionality for specific use cases.
- It integrates tightly with the SINDBAD framework, leveraging shared types and utilities from `SindbadSetup`.
"""
module TEM
   using ComponentArrays
   using NLsolve
   using SindbadCore
   using YAXArrays: mapCube
   using ThreadPools
   using ..Setup

   include("utilsTEM.jl")
   include("deriveSpinupForcing.jl")
   include("prepTEMOut.jl")
   include("prepTEM.jl")
   include("runTEMLoc.jl")
   include("runTEMSpace.jl")
   include("runTEMCube.jl")
   include("spinupTEM.jl")
   include("spinupSequence.jl")

end # module TEM
