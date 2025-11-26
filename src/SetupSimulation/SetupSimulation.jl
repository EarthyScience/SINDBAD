
"""
   SetupSimulation

The `SetupSimulation` module provides tools for setting up and configuring SINDBAD experiments and runs. It handles the creation of experiment configurations, model structures, parameters, and output setups, ensuring a streamlined workflow for SINDBAD simulations.

# Purpose:
This module is designed to produce the SINDBAD `info` object, which contains all the necessary configurations and metadata for running SINDBAD experiments. It facilitates reading configurations, building model structures, and preparing outputs.

# Dependencies:
- `SindbadTEM`: Provides the core SINDBAD models and types.
- `SindbadTEM.Utils`: Supplies utility functions for handling data and other helper tasks during the setup process.
- `ConstructionBase`: Provides a base type for constructing types, enabling the creation of custom types for SINDBAD experiments.
- `CSV`: Provides tools for reading and writing CSV files, commonly used for input and output data in SINDBAD experiments.
- `Infiltrator`: Enables interactive debugging during the setup process, improving development and troubleshooting.
- `JSON`: Provides tools for parsing and generating JSON files, commonly used for configuration files.
- `JLD2`: Facilitates saving and loading SINDBAD configurations and outputs in a binary format for efficient storage and retrieval.

# Included Files:
1. **`defaultOptions.jl`**:
   - Defines default configuration knobs for optimization, sensitivity, and ML routines referenced during setup.

2. **`getConfiguration.jl`**:
   - Reads JSON/CSV configuration files and normalizes them into the internal settings representation.

3. **`setupExperimentInfo.jl`**:
   - Builds the experiment `info` NamedTuple that downstream modules consume.

4. **`setupTypes.jl`**:
   - Instantiates SINDBAD types after parsing settings (time, land, metrics, optimization, etc.).

5. **`setupPools.jl`**:
   - Initializes land pools and state variables based on model structure, helpers, and constants.

6. **`updateParameters.jl`**:
   - Applies metric feedback to parameter values (e.g., during optimization iterations).

7. **`setupParameters.jl`**:
   - Loads parameter metadata (bounds, timescales, priors) and prepares arrays used by optimization/ML.

8. **`setupModels.jl`**:
   - Validates and orders the selected processes, wiring approaches to the overall run sequence.

9. **`setupOutput.jl`**:
   - Configures diagnostic/output arrays, filenames, and write schedules.

10. **`setupOptimization.jl`**:
    - Collects optimizer-specific settings (algorithm, stopping criteria, restarts, etc.).

11. **`setupHybridML.jl`**:
    - Handles hybrid ML-specific configuration (fold definitions, feature sets, surrogate wiring).

12. **`setupInfo.jl`**:
    - Final assembly step that integrates all previous pieces into the `info` object exported to simulations.

# Notes:
- The package re-exports several key packages (`Infiltrator`, `CSV`, `JLD2`) for convenience, allowing users to access their functionality directly through `SetupSimulation`.
- Designed to be modular and extensible, enabling users to customize and expand the setup process for specific use cases.

"""
module SetupSimulation

   using SindbadTEM
   using SindbadTEM.Utils
   using ConstructionBase
   @reexport using CSV: CSV
   @reexport using Infiltrator
   using JSON: parsefile, json, print as json_print
   @reexport using JLD2: @save, load

   include("defaultOptions.jl")
   include("getConfiguration.jl")
   include("setupExperimentInfo.jl")
   include("setupTypes.jl")
   include("setupPools.jl")
   include("updateParameters.jl")
   include("setupParameters.jl")
   include("setupModels.jl")
   include("setupOutput.jl")
   include("setupOptimization.jl")
   include("setupHybridML.jl")
   include("setupInfo.jl")

   #  include doc strings for all types in Types
   ds_file = joinpath(dirname(pathof(SindbadTEM)), "Types/docStringForTypes.jl")
   loc_types = subtypes(SindbadTypes)
   open(ds_file, "a") do o_file
      writeTypeDocString(o_file, SindbadTypes)
      for T in loc_types
         o_file = loopWriteTypeDocString(o_file, T)
      end
   end
   include(ds_file)

end # module SetupSimulation
