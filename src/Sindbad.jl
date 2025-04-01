"""
    Sindbad

A Julia package for the terrestrial ecosystem models within **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els `(SINDBAD)` framework.

The `Sindbad` package serves as the core of the SINDBAD framework, providing foundational types, utilities, and tools for building and managing SINDBAD models.

# Purpose:
This package defines the `LandEcosystem` supertype, which serves as the base for all SINDBAD models. It also provides utilities for managing model variables, tools for model operations, and a catalog of variables used in SINDBAD workflows.

# Dependencies:
- `Reexport`: Simplifies re-exporting functionality from other packages, ensuring a clean and modular design.
- `CodeTracking`: Enables tracking of code definitions, useful for debugging and development workflows.
- `DataStructures`: Provides advanced data structures (e.g., `OrderedDict`, `Deque`) for efficient data handling in SINDBAD models.
- `DocStringExtensions`: Facilitates the creation of structured and extensible docstrings for improved documentation.
- `Flatten`: Supplies tools for flattening nested data structures, simplifying the handling of hierarchical model variables.
- `InteractiveUtils`: Enables interactive exploration and debugging during development.
- `Parameters`: Provides macros for defining and managing model parameters in a concise and readable manner.
- `StaticArraysCore`: Supports efficient, fixed-size arrays (e.g., `SVector`, `MArray`) for performance-critical operations in SINDBAD models.

# Included Files:
1. **`utilsCore.jl`**:
   - Contains core utility functions for SINDBAD, including helper methods for array operations and code generation macros for NamedTuple packing and unpacking.

2. **`sindbadVariableCatalog.jl`**:
   - Defines a catalog of variables used in SINDBAD models, ensuring consistency and standardization across workflows. Note that every new variable would need a manual entry in the catalog so that the output files are written with correct information.

3. **`Models/models.jl`**:
   - Implements the core SINDBAD models, inheriting from the `LandEcosystem` supertype. Also, introduces the fallback function for compute, precompute, etc. so that they are optional in every model.

4. **`modelTools.jl`**:
   - Provides tools for extracting information from SINDBAD models, including mode code, variables, and parameters.

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
using Sindbad
# Access utilities or models
flattened_data = flatten(nested_data)
```

3. **Querying the variable catalog**:
```julia
using Sindbad
catalog = getVariableCatalog()
```
"""
module Sindbad
    using Reexport: @reexport
    @reexport using CodeTracking
    @reexport using DataStructures: DataStructures
    using DocStringExtensions
    @reexport using Flatten: flatten, metaflatten, fieldnameflatten, parentnameflatten
    @reexport using InteractiveUtils
    using Parameters
    @reexport using Reexport
    @reexport using StaticArraysCore: StaticArray, SVector, MArray, SizedArray

    ## Define SINDBAD supertype
    export LandEcosystem
    abstract type LandEcosystem end

include("utilsCore.jl")
include("sindbadVariableCatalog.jl")
include("modelTools.jl")
include("Models/models.jl")
include("generateCode.jl")
@reexport using .Models
end
