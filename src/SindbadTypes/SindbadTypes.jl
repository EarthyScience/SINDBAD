export purpose
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
purpose(::Type{ambientCO2_constant}) = "sets ambient_CO2 as a constant"
```
# Retrieve the purpose
````
println(purpose(ambientCO2_constant))  # Output: "sets ambient_CO2 as a constant"
````
"""
function purpose end

purpose(T) = "Undefined purpose for $(nameof(T)) of type $(typeof(T)). Add `purpose(::Type{$(nameof(T))}) = \"the_purpose\"` in one of the files in the `src/SindbadTypes` folder where the function/type is defined."


# ------------------------- SindbadType ------------------------------------------------------------
export SindbadType
abstract type SindbadType end
purpose(::Type{SindbadType}) = "Abstract type for all Julia types in SINDBAD"

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


# append the docstring of the SindbadType type to the docstring of the Sindbad module so that all the methods of the SindbadType type are included after the models have been described
@doc """
$(getTypeDocString(SindbadType))
"""
SindbadType
