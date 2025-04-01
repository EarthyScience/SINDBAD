
"""
   SindbadSetup

The `SindbadSetup` package provides tools for setting up and configuring SINDBAD experiments and runs. It handles the creation of experiment configurations, model structures, parameters, and output setups, ensuring a streamlined workflow for SINDBAD simulations.

# Purpose:
This package is designed to produce the SINDBAD `info` object, which contains all the necessary configurations and metadata for running SINDBAD experiments. It facilitates reading configurations, building model structures, and preparing outputs.

# Dependencies:
- `Sindbad`: Provides the core SINDBAD models.
- `Accessors`: Enables efficient access and modification of nested data structures, simplifying the handling of SINDBAD configurations.
- `ForwardDiff`: Supports automatic differentiation for parameter optimization and sensitivity analysis.
- `CSV`: Provides tools for reading and writing CSV files, commonly used for input and output data in SINDBAD experiments.
- `Dates`: Handles date and time operations, useful for managing temporal data in SINDBAD experiments.
- `Infiltrator`: Enables interactive debugging during the setup process, improving development and troubleshooting.
- `JSON`: Provides tools for parsing and generating JSON files, commonly used for configuration files.
- `JLD2`: Facilitates saving and loading SINDBAD configurations and outputs in a binary format for efficient storage and retrieval.
- `SindbadUtils`: Supplies utility functions for handling data and other helper tasks during the setup process.
- `SindbadMetrics`: Provides metrics for evaluating model performance, which can be integrated into the setup process.

# Included Files:
1. **`runtimeDispatchTypes.jl`**:
   - Defines runtime dispatch types used for configuring functions and their dispatches.

2. **`defaultOptions.jl`**:
   - Defines default configuration options for various optimization and global sensitivity analysis methods in SINDBAD.

3. **`getConfiguration.jl`**:
   - Contains functions for reading and parsing configuration files (e.g., JSON or CSV) to initialize SINDBAD experiments.

4. **`setupExperimentInfo.jl`**:
   - Builds the `info` object, which contains all the metadata and configurations required for running SINDBAD experiments.

5. **`setupTypes.jl`**:
   - Defines instances of data types in SINDBAD after reading the information from settings files.

6. **`setupPools.jl`**:
   - Handles the initialization of SINDBAD land by creating model pools, including state variables.

7. **`setupParameters.jl`**:
   - Manages the loading and setup of model parameters, including bounds, scaling, and initial values.

8. **`setupModels.jl`**:
   - Constructs the model structure, including the selection and configuration of orders SINDBAD models.

9. **`setupOutput.jl`**:
   - Prepares the output structure for SINDBAD experiments.

10. **`setupOptimization.jl`**:
   - Configures optimization settings for parameter estimation and model calibration.

11. **`setupInfo.jl`**:
   - Calls various functions to collect the `info` object by integrating all configurations, models, parameters, and outputs.

# Notes:
- The package re-exports several key packages (`Sindbad`, `Accessors`, `ForwardDiff`, `CSV`, `Dates`, `JLD2`, `SindbadUtils`, `SindbadMetrics`) for convenience, allowing users to access their functionality directly through `SindbadSetup`.
- Designed to be modular and extensible, enabling users to customize and expand the setup process for specific use cases.


# Examples:
1. **Setting up an experiment**:
```julia
using SindbadSetup
# Read configuration and build the experiment info
experiment_info = getConfiguration("config.json")
```

2. **Preparing model parameters**:
```julia
using SindbadSetup
# Initialize model parameters
parameters = setupParameters(experiment_info)
```

3. **Setting up outputs**:
```julia
using SindbadSetup
# Prepare output structure
outputs = setupOutput(experiment_info)
```
"""
module SindbadSetup

    using Sindbad
    @reexport using Accessors
    @reexport using ForwardDiff
    @reexport using CSV: CSV
    @reexport using Dates
    @reexport using Infiltrator
    using JSON: parsefile, json
    @reexport using JLD2: @save
    @reexport using Sindbad
    @reexport using SindbadUtils
    @reexport using SindbadMetrics

    include("runtimeDispatchTypes.jl")
    include("defaultOptions.jl")
    include("getConfiguration.jl")
    include("setupExperimentInfo.jl")
    include("setupTypes.jl")
    include("setupPools.jl")
    include("setupParameters.jl")
    include("setupModels.jl")
    include("setupOutput.jl")
    include("setupOptimization.jl")
    include("setupInfo.jl")

end # module SindbadSetup
