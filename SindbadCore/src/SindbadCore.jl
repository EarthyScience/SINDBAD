"""
    SindbadCore

A Julia package for the terrestrial ecosystem models within **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els `(SINDBAD)` framework.

The `SindbadCore` package serves as the core of the SINDBAD framework, providing foundational types, utilities, and tools for building and managing SINDBAD models.

# Purpose:
This package defines the `LandEcosystem` supertype, which serves as the base for all SINDBAD models. It also provides utilities for managing model variables, tools for model operations, and a catalog of variables used in SINDBAD workflows.

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
1. **`coreTypes.jl`**:
   - Defines the core types used in SINDBAD, including the `LandEcosystem` supertype and other fundamental types.

2. **`utilsCore.jl`**:
   - Contains core utility functions for SINDBAD, including helper methods for array operations and code generation macros for NamedTuple packing and unpacking.

3. **`sindbadVariableCatalog.jl`**:
   - Defines a catalog of variables used in SINDBAD models, ensuring consistency and standardization across workflows. Note that every new variable would need a manual entry in the catalog so that the output files are written with correct information.

4. **`modelTools.jl`**:
   - Provides tools for extracting information from SINDBAD models, including mode code, variables, and parameters.

5. **`Models/models.jl`**:
   - Implements the core SINDBAD models, inheriting from the `LandEcosystem` supertype. Also, introduces the fallback function for compute, precompute, etc. so that they are optional in every model.

6. **`generateCode.jl`**:
   - Contains code generation utilities for SINDBAD models and workflows.

# Notes:
- The `LandEcosystem` supertype serves as the foundation for all SINDBAD models, enabling extensibility and modularity.
- The package re-exports key functionality from other packages (e.g., `Flatten`, `StaticArraysCore`, `DataStructures`) to simplify usage and integration.
- Designed to be lightweight and modular, allowing seamless integration with other SINDBAD packages.

# Examples:
1. **Defining a new SINDBAD model**:
```julia
struct MyModel <: LandEcosystem
    # Define model-specific fields
end
```

2. **Using utilities from the package**:
```julia
using SindbadCore
# Access utilities or models
flattened_data = flatten(nested_data)
```

3. **Querying the variable catalog**:
```julia
using SindbadCore
catalog = getVariableCatalog()
```
"""
module SindbadCore
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
   using Crayons
   # @reexport using Crayons

   # create a tmp_ file for tracking the creation of new approaches. This is needed because precompiler is not consistently loading the newly created approaches. This file is appended every time a new model/approach is created which forces precompile in the next use of SindbadCore.
   file_path = file_path = joinpath(@__DIR__, "tmp_precompile_placeholder.jl")
   # Check if the file exists
   if isfile(file_path)
      # Include the file if it exists
      include(file_path)
   else
      # Create a blank file if it does not exist
      open(file_path, "w") do file
         # Optionally, you can write some initial content
         write(file, "# This is a blank file created by Sindbad module to keep track of newly added sindbad approaches/models which automatically updates this file and then forces precompilation to include the new models.\n")
      end
      println("Created a blank file: $file_path to track precompilation of new models and approaches")
   end
   
   include("Types/Types.jl")
   @reexport using .Types
   include("utilsCore.jl")   
   include("sindbadVariableCatalog.jl")
   include("modelTools.jl")
   include("Models/Models.jl")
   include("generateCode.jl")
   @reexport using .Models
   # ? maybe rename module, a shorter name?
   include("Utilities/Utilities.jl")
   @reexport using .Utilities
   include("Metrics/Metrics.jl")
   @reexport using .Metrics

   # append the docstring of the LandEcosystem type to the docstring of the Sindbad module so that all the methods of the LandEcosystem type are included after the models have been described
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
   struct MyModel <: LandEcosystem end

   # Implement required methods
   function define(params::MyModel, forcing, land, helpers)
   # Initialize arrays and variables
   return land
   end

   function precompute(params::MyModel, forcing, land, helpers)
   # Update variables with new realizations
   return land
   end

   function compute(params::MyModel, forcing, land, helpers)
   # Update model state in time
   return land
   end

   function update(params::MyModel, forcing, land, helpers)
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
