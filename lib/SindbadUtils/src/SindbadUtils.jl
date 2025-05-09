"""
    SindbadUtils

The `SindbadUtils` package provides a collection of utility functions and tools for handling data, managing NamedTuples, and performing spatial and temporal operations in the SINDBAD framework. It serves as a foundational package for simplifying common tasks and ensuring consistency across SINDBAD experiments.

# Purpose:
This package is designed to provide reusable utilities for data manipulation, statistical operations, and spatial/temporal processing. 
    
# Dependencies:
- `Crayons`: Enables colored terminal output, improving the readability of logs and messages.
- `StyledStrings`: Provides styled text for enhanced terminal output.
- `DataStructures`: Supplies advanced data structures (e.g., `OrderedDict`, `Deque`) for efficient data handling.
- `Dates`: Facilitates date and time operations, useful for temporal data processing.
- `FIGlet`: Generates ASCII art text, useful for creating visually appealing headers in logs or outputs.
- `Logging`: Provides logging utilities for debugging and monitoring SINDBAD workflows.
- `NaNStatistics`: Extends statistical operations to handle missing values (`NaN`), ensuring robust data analysis.
- `StaticArraysCore`: Supports efficient, fixed-size arrays for performance-critical operations.
- `StatsBase`: Supplies basic statistical functions (e.g., `mean`, `sum`, `sample`) for data analysis.

# Included Files:
1. **`utilsTypes.jl`**:
   - Defines custom types and structures used across SINDBAD utilities.

2. **`getArrayView.jl`**:
   - Implements functions for creating views of arrays, enabling efficient data slicing and subsetting.

3. **`utils.jl`**:
   - Contains general-purpose utility functions for data manipulation and processing.

4. **`utilsNT.jl`**:
   - Provides utilities for working with NamedTuples, including transformations and access operations.

5. **`utilsSpatial.jl`**:
   - Implements spatial operations, such as extracting subsets of data based on spatial dimensions.

6. **`utilsTemporal.jl`**:
   - Handles temporal operations, including time-based filtering and aggregation.

# Notes:
- The package re-exports key packages (`NaNStatistics`, `StatsBase`) for convenience, allowing users to access their functionality directly through `SindbadUtils`.
- Designed to be lightweight and modular, enabling seamless integration with other SINDBAD packages.

# Examples:
1. **Handling NamedTuples**:
```julia
using SindbadUtils
transformed_nt = transformNamedTuple(input_nt, transformation_function)
```

2. **Calculating statistics with missing values**:
```julia
using SindbadUtils
mean_value = mean(data_with_nans, skipmissing=true)
```
"""
module SindbadUtils
    using Crayons
    using StyledStrings
    using DataStructures
    using Dates
    using FIGlet
    using Logging
    using Reexport: @reexport
    @reexport using Accessors: @set
    @reexport using NaNStatistics
    using StaticArraysCore
    @reexport using StatsBase: mean, rle, sample, sum
    using Sindbad
    using Base.Docs: doc as Base_docs_doc
    # @reexport import Sindbad: subtypes, methodsOf, showMethodsOf

    include("getArrayView.jl")
    include("utils.jl")
    include("utilsNT.jl")
    include("utilsTemporal.jl")
        
end # module SindbadUtils
