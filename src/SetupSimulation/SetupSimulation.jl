
"""
   SetupSimulation

The `SetupSimulation` package provides tools for setting up and configuring SINDBAD experiments and runs. It handles the creation of experiment configurations, model structures, parameters, and output setups, ensuring a streamlined workflow for SINDBAD simulations.

# Purpose:
This package is designed to produce the SINDBAD `info` object, which contains all the necessary configurations and metadata for running SINDBAD experiments. It facilitates reading configurations, building model structures, and preparing outputs.

# Dependencies:
- `Sindbad`: Provides the core SINDBAD models and types.
- `Utils`: Supplies utility functions for handling data and other helper tasks during the setup process.
- `ConstructionBase`: Provides a base type for constructing types, enabling the creation of custom types for SINDBAD experiments.
- `CSV`: Provides tools for reading and writing CSV files, commonly used for input and output data in SINDBAD experiments.
- `Infiltrator`: Enables interactive debugging during the setup process, improving development and troubleshooting.
- `JSON`: Provides tools for parsing and generating JSON files, commonly used for configuration files.
- `JLD2`: Facilitates saving and loading SINDBAD configurations and outputs in a binary format for efficient storage and retrieval.

# Included Files:

1. **`defaultOptions.jl`**:
   - Defines default configuration options for various optimization and global sensitivity analysis methods in SINDBAD.

2. **`getConfiguration.jl`**:
   - Contains functions for reading and parsing configuration files (e.g., JSON or CSV) to initialize SINDBAD experiments.

3. **`setupExperimentInfo.jl`**:
   - Builds the `info` object, which contains all the metadata and configurations required for running SINDBAD experiments.

4. **`setupTypes.jl`**:
   - Defines instances of data types in SINDBAD after reading the information from settings files.

5. **`setupPools.jl`**:
   - Handles the initialization of SINDBAD land by creating model pools, including state variables.

6. **`updateParameters.jl`**:
   - Implements logic for updating model parameters based on metric evaluations, enabling iterative model calibration.

7. **`setupParameters.jl`**:
   - Manages the loading and setup of model parameters, including bounds, scaling, and initial values.

7. **`setupModels.jl`**:
   - Constructs the model structure, including the selection and configuration of orders SINDBAD models.

8. **`setupOutput.jl`**:
   - Prepares the output structure for SINDBAD experiments.

9. **`setupOptimization.jl`**:
   - Configures optimization settings for parameter estimation and model calibration.

10. **`setupInfo.jl`**:
   - Calls various functions to collect the `info` object by integrating all configurations, models, parameters, and outputs.

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
