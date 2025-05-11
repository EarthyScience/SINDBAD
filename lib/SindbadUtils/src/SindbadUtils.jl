"""
    SindbadUtils

The `SindbadUtils` package provides a collection of utility functions and tools for handling data, managing NamedTuples, and performing spatial and temporal operations in the SINDBAD framework. It serves as a foundational package for simplifying common tasks and ensuring consistency across SINDBAD experiments.

# Purpose:
This package is designed to provide reusable utilities for data manipulation, statistical operations, and spatial/temporal processing. 
    
# Dependencies:
- `Sindbad`: Provides the core SINDBAD models and types.
- `Crayons`: Enables colored terminal output, improving the readability of logs and messages.
- `StyledStrings`: Provides styled text for enhanced terminal output.
- `Dates`: Facilitates date and time operations, useful for temporal data processing.
- `FIGlet`: Generates ASCII art text, useful for creating visually appealing headers in logs or outputs.
- `Logging`: Provides logging utilities for debugging and monitoring SINDBAD workflows.

# Included Files:
1. **`getArrayView.jl`**:
   - Implements functions for creating views of arrays, enabling efficient data slicing and subsetting.

2. **`utils.jl`**:
   - Contains general-purpose utility functions for data manipulation and processing.

3. **`utilsNT.jl`**:
   - Provides utilities for working with NamedTuples, including transformations and access operations.

4. **`utilsTemporal.jl`**:
   - Handles temporal operations, including time-based filtering and aggregation.

"""
module SindbadUtils
   using Sindbad
   using Crayons
   using StyledStrings
   using FIGlet
   using Logging

   include("getArrayView.jl")
   include("utils.jl")
   include("utilsNT.jl")
   include("utilsTemporal.jl")
   
end # module SindbadUtils
