"""
    Types

The `Types` module consolidates and organizes all the types used in the SINDBAD framework into a central location. This ensures a single source for type definitions, promoting consistency and reusability across all SINDBAD packages. It also provides helper functions and utilities for working with these types.

# Purpose:
This module serves as the backbone for type definitions in SINDBAD, ensuring modularity and extensibility. It provides a unified hierarchy for SINDBAD-specific types and includes utilities for introspection, type manipulation, and documentation.

# Dependencies:
- `InteractiveUtils`: Enables interactive exploration and debugging during development.
- `Base.Docs`: Provides documentation utilities for type introspection.

# Included Files:
1. **`ModelTypes.jl`**:
   - Defines types for models in SindbadTEM, representing various model/processes.

2. **`TimeTypes.jl`**:
   - Defines types for handling time-related operations, managing temporal aggregation of data.

3. **`SpinupTypes.jl`**:
   - Defines types for spinup processes in SindbadTEM, handling methods for initialization and equilibrium states.

4. **`LandTypes.jl`**:
   - Defines types for collecting variables from `land` and saving them, building land and array structures for model execution.

5. **`ArrayTypes.jl`**:
   - Defines types for array structures used in SindbadTEM, providing specialized array types for efficient data handling.

6. **`InputTypes.jl`**:
   - Defines types for input data and configurations, managing input flows and forcing data.

7. **`ExperimentTypes.jl`**:
   - Defines types for experiments conducted in SindbadTEM, representing experimental setups, configurations, and results.

8. **`OptimizationTypes.jl`**:
   - Defines types for optimization-related functions and methods, separating methods for optimization, cost functions, etc.

9. **`MetricsTypes.jl`**:
   - Defines types for metrics used to evaluate model performance, representing performance metrics and cost evaluation.

10. **`MLTypes.jl`**:
    - Defines types for machine learning components, supporting machine learning workflows and data structures.

11. **`LongTuple.jl`**:
    - Provides definitions and methods for working with `longTuple` type, facilitating operations on tuples with many elements.

12. **`TypesFunctions.jl`**:
    - Provides helper functions related to SINDBAD types, including utilities for introspection, type manipulation, and documentation.

13. **`docStringForTypes.jl`**:
    - Auto-generated documentation that appends type docstrings to the main module for discoverability.

# Notes:
- The `Types` module serves as the backbone for type definitions in SINDBAD, ensuring modularity and extensibility.
- Each type is documented with its purpose via the `purpose` function, making it easier for developers to understand and extend the framework.
- The `SindbadTypes` abstract type serves as the base for all Julia types in the SINDBAD framework.

# Examples:
1. **Querying type purpose**:
```julia
using SindbadTEM.Types
purpose(BayesOptKMaternARD5)  # Returns the purpose string for the type
```

2. **Working with SINDBAD types**:
```julia
using SindbadTEM.Types
# All SINDBAD types are available through this module
```

"""
module Types
    using InteractiveUtils
    using Base.Docs: doc as base_doc
    export purpose, base_doc
    """
        purpose(T::Type)

    Returns a string describing the purpose of a type in the SINDBAD framework.

    # Description
    - This is a base function that should be extended by each package for their specific types.
    - When in SINDBAD models, purpose is a descriptive string that explains the role or functionality of the model or approach within the SINDBAD framework. If the purpose is not defined for a specific model or approach, it provides guidance on how to define it.
    - When in SINDBAD lib, purpose is a descriptive string that explains the dispatch on the type for the specific function. For instance, metricTypes.jl has a purpose for the types of metrics that can be computed.


    # Arguments
    - `T::Type`: The type whose purpose should be described

    # Returns
    - A string describing the purpose of the type
        
    # Example
    ```julia
    # Define the purpose for a specific model
    purpose(::Type{BayesOptKMaternARD5}) = "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"

    # Retrieve the purpose
    println(purpose(BayesOptKMaternARD5))  # Output: "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"
    ```
    """
    function purpose end

    purpose(T) = "Undefined purpose for $(nameof(T)) of type $(typeof(T)). Add `purpose(::Type{$(nameof(T))}) = \"the_purpose\"` in one of the files in the `src/Types` folder where the function/type is defined."


    # ------------------------- SindbadTypes ------------------------------------------------------------
    export SindbadTypes
    abstract type SindbadTypes end
    purpose(::Type{SindbadTypes}) = "Abstract type for all Julia types in SINDBAD"

    include("ModelTypes.jl")
    include("TimeTypes.jl")
    include("SpinupTypes.jl")
    include("LandTypes.jl")
    include("ArrayTypes.jl")
    include("InputTypes.jl")
    include("ExperimentTypes.jl")
    include("OptimizationTypes.jl")
    include("MetricsTypes.jl")
    include("MLTypes.jl")
    include("LongTuple.jl")
    include("TypesFunctions.jl")


    # append the docstring of the SindbadTypes type to the docstring of the Sindbad module so that all the methods of the SindbadTypes type are included after the models have been described
    @doc """
    $(getTypeDocString(SindbadTypes))
    """
    SindbadTypes
end