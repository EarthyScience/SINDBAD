"""
    SindbadTEM

A Julia package for the terrestrial ecosystem models within **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els `(SINDBAD)` framework.

The `SindbadTEM` package serves as the core of the SINDBAD framework, providing foundational types, utilities, and tools for building and managing SINDBAD models.

# Purpose:
This module defines the `LandEcosystem` supertype, which serves as the base for all SINDBAD models. It also provides utilities for managing model variables, tools for model operations, and a catalog of variables used in SINDBAD workflows.

# Dependencies:
- `Reexport`: Simplifies re-exporting functionality from other packages, ensuring a clean and modular design.
- `CodeTracking`: Enables tracking of code definitions, useful for debugging and development workflows.
- `DataStructures`: Provides advanced data structures (e.g., `OrderedDict`, `Deque`) for efficient data handling in SINDBAD models.
- `Dates`: Handles date and time operations, useful for managing temporal data in SINDBAD experiments.
- `Flatten`: Supplies tools for flattening nested data structures, simplifying the handling of hierarchical model variables.
- `InteractiveUtils`: Enables interactive exploration and debugging during development.
- `Parameters`: Provides macros for defining and managing model parameters in a concise and readable manner.
- `StaticArraysCore`: Supports efficient, fixed-size arrays (e.g., `SVector`, `MArray`) for performance-critical operations in SINDBAD models.
- `TypedTables`: Provides lightweight, type-stable tables for structured data manipulation.
- `Accessors`: Enables efficient access and modification of nested data structures, simplifying the handling of SINDBAD configurations.
- `StatsBase`: Supplies statistical functions such as `mean`, `percentile`, `cor`, and `corspearman` for computing metrics like correlation and distribution-based statistics.
- `NaNStatistics`: Extends statistical operations to handle missing values (`NaN`), ensuring robust data analysis.


# Included Files:
1. **`Types/Types.jl`**:
   - Collects all SINDBAD types (model, time, land, array, experiment, etc.) and exports `purpose` along with helper utilities. Re-exported via `SindbadTEM.Types`.

2. **`TEMUtils.jl`**:
   - Provides helper macros and functions for manipulating pools, NamedTuples, logging, and other TER utilities. Re-exported as `SindbadTEM.TEMUtils`.

3. **`sindbadVariableCatalog.jl`**:
   - Defines the canonical catalog of SINDBAD variables to keep file IO metadata consistent.

4. **`TEMTools.jl`**:
   - Supplies tooling for inspecting models (I/O listings, parameter conversions, docstring builders, etc.).

5. **`Processes/Processes.jl`**:
   - Declares the process hierarchy, metadata macros, and all process/approach definitions. Re-exported as `SindbadTEM.Processes`.

6. **`generateCode.jl`**:
   - Houses code-generation utilities to scaffold new SINDBAD process implementations and workflows.

7. **`Types/docStringForTypes.jl`**:
   - Auto-generated documentation that appends type docstrings to the main module for discoverability.

# Notes:
- The `LandEcosystem` supertype serves as the foundation for all SINDBAD models, enabling extensibility and modularity.
- The package re-exports key functionality from other packages (e.g., `Flatten`, `StaticArraysCore`, `DataStructures`) to simplify usage and integration.
- Designed to be lightweight and modular, allowing seamless integration with other SINDBAD modules in the top src directory of the repository.

# Examples:
1. **Defining a new SINDBAD model**:
```julia
struct MyProcess <: LandEcosystem
    # Define model-specific fields
end
```

2. **Using utilities from the package**:
```julia
using Sindbad.Simulation
# Access utilities or models
flattened_data = flatten(nested_data)
```

3. **Querying the variable catalog**:
```julia
using Sindbad.Simulation
catalog = getVariableCatalog()
```
"""
module SindbadTEM
   using Reexport: @reexport
   @reexport using Reexport
   @reexport using Pkg
   @reexport using CodeTracking
   @reexport using DataStructures: DataStructures
   @reexport using Dates
   # @reexport using Flatten: flatten, metaflatten, fieldnameflatten, parentnameflatten
   @reexport using InteractiveUtils
   @reexport using StaticArraysCore: StaticArray, SVector, MArray, SizedArray
   @reexport using TypedTables: Table
   @reexport using Accessors: @set
   @reexport using StatsBase
   @reexport using NaNStatistics
   @reexport using Crayons
   using StyledStrings

   # create a tmp_ file for tracking the creation of new approaches. This is needed because precompiler is not consistently loading the newly created approaches. This file is appended every time a new model/approach is created which forces precompile in the next use of SindbadTEM.
   file_path = file_path = joinpath(@__DIR__, "tmp_precompile_placeholder.jl")
   # Check if the file exists
   if isfile(file_path)
      # Include the file if it exists
      include(file_path)
   else
      # Create a blank file if it does not exist
      open(file_path, "w") do file
         # Optionally, you can write some initial content
         write(file, "# This is a blank file created by SindbadTEM module to keep track of newly added sindbad approaches/processes which automatically updates this file and then forces precompilation to include the new processes.\n")
      end
      println("Created a blank file: $file_path to track precompilation of new processes and approaches")
   end
   
   include("Types/Types.jl")
   @reexport using .Types
   include("sindbadVariableCatalog.jl")
   include("TEMTools.jl")
   include("TEMUtils.jl")   
   include("Processes/Processes.jl")
   include("generateCode.jl")
   @reexport using .Processes
   include("Utils/Utils.jl")
   @reexport using .Utils
   include("Metrics/Metrics.jl")
   @reexport using .Metrics

   # append the docstring of the LandEcosystem type to the docstring of the SindbadTEM module so that all the methods of the LandEcosystem type are included after the models have been described
   @doc """
   LandEcosystem

   $(purpose(LandEcosystem))

   # Methods
   All subtypes of `LandEcosystem` must implement at least one of the following methods:
   - `define`: Initialize arrays and variables
   - `precompute`: Update variables with new realizations
   - `compute`: Update model state in time
   - `update`: Update pools within a single time step


   # Example
   ```julia
   # Define a new model type
   struct MyProcess <: LandEcosystem end

   # Implement required methods
   function define(params::MyProcess, forcing, land, helpers)
   # Initialize arrays and variables
   return land
   end

   function precompute(params::MyProcess, forcing, land, helpers)
   # Update variables with new realizations
   return land
   end

   function compute(params::MyProcess, forcing, land, helpers)
   # Update model state in time
   return land
   end

   function update(params::MyProcess, forcing, land, helpers)
   # Update pools within a single time step
   return land
   end
   ```

   ---

   # Extended help
   $(methodsOf(Types.LandEcosystem))
   """
   Types.LandEcosystem
   
   include(joinpath(@__DIR__, "Types/docStringForTypes.jl"))
end
