
"""
    Types Module

The `Types` module consolidates and organizes all the types used in the SINDBAD framework into a central location. This ensures a single line for type definitions, promoting consistency and reusability across all SINDBAD packages. It also provides helper functions and utilities for working with these types.


## Provided Types and Their Purpose

### 1. `SindbadTypes`
- **Purpose**: Abstract type serving as the base for all Julia types in the SINDBAD framework.
- **Use**: Provides a unified hierarchy for SINDBAD-specific types.

### 2. `ModelTypes`
- **Purpose**: Defines types for models in SindbadTEM.
- **Use**: Represents various model/processes.

### 3. `TimeTypes`
- **Purpose**: Defines types for handling time-related operations.
- **Use**: Manages temporal aggregation of data on the go.

### 4. `SpinupTypes`
- **Purpose**: Defines types for spinup processes in SindbadTEM.
- **Use**: Handles methods for initialization and equilibrium states for models.

### 5. `LandTypes`
- **Purpose**: Defines types for collecting variable from ```land``` and saving them.
- **Use**: Builds land and array for model execution.

### 6. `ArrayTypes`
- **Purpose**: Defines types for array structures used in SindbadTEM.
- **Use**: Provides specialized array types for efficient data handling in model simulation and output.

### 7. `InputTypes`
- **Purpose**: Defines types for input data and configurations.
- **Use**: Manages input flows and forcing data.

### 8. `ExperimentTypes`
- **Purpose**: Defines types for experiments conducted in SindbadTEM.
- **Use**: Represents experimental setups, configurations, and results.

### 9. `OptimizationTypes`
- **Purpose**: Defines types for optimization-related functions and methods in SindbadTEM.
- **Use**: Separates methods for optimization methods, cost functions, methods, etc.

### 10. `MetricsTypes`
- **Purpose**: Defines types for metrics used to evaluate model performance in SindbadTEM.
- **Use**: Represents performance metrics and cost evaluation.

### 11. `MLTypes`
- **Purpose**: Defines types for machine learning components in SindbadTEM.
- **Use**: Supports machine learning workflows and data structures.

### 12. `LongTuple`
- **Purpose**: Provides definitions and methods for working with `longTuple` type.
- **Use**: Facilitates operations on tuples with many elements to break them down into smaller tuples.

### 13. `TypesFunctions`
- **Purpose**: Provides helper functions related to SINDBAD types.
- **Use**: Includes utilities for introspection, type manipulation, and documentation.

## Key Functionality

### `purpose(T::Type)`
- **Description**: Returns a string describing the purpose of a type in the SINDBAD framework.
- **Use**: Provides a descriptive string for each type, explaining its role or functionality.
- **Example**:
```julia
purpose(::Type{BayesOptKMaternARD5}) = "Bayesian Optimization using Matern 5/2 kernel with Automatic Relevance Determination from BayesOpt.jl"
```

## Notes
- The `Types` module serves as the backbone for type definitions in SINDBAD, ensuring modularity and extensibility.
- Each type is documented with its purpose, making it easier for developers to understand and extend the framework.

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