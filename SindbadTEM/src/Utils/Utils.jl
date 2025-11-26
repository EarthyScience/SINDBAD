"""
    Utils

The `Utils` module provides a collection of utility functions and tools for handling data, managing NamedTuples, and performing spatial and temporal operations in the SINDBAD framework. It serves as a foundational package for simplifying common tasks and ensuring consistency across SINDBAD experiments.

# Purpose:
This module is designed to provide reusable utilities for data manipulation, statistical operations, and spatial/temporal processing.

# Dependencies:
- `SindbadTEM`: Provides the core SINDBAD models and types.
- `Crayons`: Enables colored terminal output, improving the readability of logs and messages.
- `StyledStrings`: Provides styled text for enhanced terminal output.
- `Dates`: Facilitates date and time operations, useful for temporal data processing.
- `FIGlet`: Generates ASCII art text, useful for creating visually appealing headers in logs or outputs.
- `Logging`: Provides logging utilities for debugging and monitoring SINDBAD workflows.

# Included Files:
1. **`getArrayView.jl`**:
   - Implements functions for creating views of arrays, enabling efficient data slicing and subsetting.

2. **`utilsBasic.jl`**:
   - Contains general-purpose utility functions for data manipulation and processing.

3. **`utilsNT.jl`**:
   - Provides utilities for working with NamedTuples, including transformations and access operations.

4. **`utilsTemporal.jl`**:
   - Handles temporal operations, including time-based filtering and aggregation.

# Notes:
- The module provides foundational utilities used across all SINDBAD packages.
- Functions are designed to be type-stable and performant for use in performance-critical workflows.
- NamedTuple utilities enable efficient manipulation of SINDBAD's structured data types.

# Examples:
1. **Working with array views**:
```julia
using SindbadTEM.Utils
view = getArrayView(data, indices)
```

2. **Manipulating NamedTuples**:
```julia
using SindbadTEM.Utils
# Utilities for NamedTuple operations are available throughout SINDBAD
```

"""
module Utils
   using ..SindbadTEM
   using ..SindbadTEM.Types
   using Crayons
   using StyledStrings
   using FIGlet
   using Logging
   using Accessors
   using Dates
   using DataStructures
   using StatsBase
   
   include("getArrayView.jl")
   include("utilsBasic.jl")
   include("utilsNT.jl")
   include("utilsTemporal.jl")
   
end # module Utils
