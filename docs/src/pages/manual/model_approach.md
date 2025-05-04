# Model Approach in SINDBAD

This documentation explains how to work with model approaches in SINDBAD. For a comprehensive understanding of SINDBAD's modeling framework, see the [SINDBAD concept documentation](../concept/sindbad.md).

:::info

It is not recommended to build a model and approach from scratch by typing things. SINDBAD has a builtin function `generateSindbadApproach` to create the model and approach files that has all the components described. This ensures following the modeling conventions around which the performance and modularity are built.

Check the documentation of the function for further details as:
```julia
using Sindbad
?generateSindbadApproach
```
:::

## Viewing Model Approaches

To view available model approaches and their implementations:

```julia
using SindbadUtils: showMethodsOf
showMethodsOf(LandEcosystem)
```

This will display all available model approaches that are subtypes of `LandEcosystem`.

## Model Approach Structure

A model approach in SINDBAD typically follows this structure:

```julia
# Define the model type
abstract type newModel <: LandEcosystem end

@bounds @describe @units @timescale @with_kw struct newModel_v1{T1,T2} <: newModel
    param1::T1 = 1.0 | (2.0, 5.0) | "description 1" | "units 1" | ""
    param2::T2 = 0.0 | (1.0, 2.0) | "description 2" | "units 2" | ""
end

# Define the purpose
purpose(::Type{newModel}) = "Description of what this model does"
```

For more details about the modeling conventions and required methods, see the [modeling conventions documentation](../concept/modeling_conventions.md).

## Required Methods

### 1. `define`
```julia
function define(params::newModel_v1, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_newModel_v1 params
    @unpack_nt (f1, f2) ⇐ forcing
    @unpack_nt var1 ⇐ land.diagnostics

    ## calculate variables
    new_var_1 = f1*param1 + param2 + var1*f2

    ## pack land variables
    @pack_nt begin
        new_var_1 ⇒ land.diagnostics
    end
    return land
end
```
- Initializes model-specific variables
- Sets up model parameters
- Returns modified `land` structure

For more information about variable initialization, see the [land concept documentation](../concept/land.md#variable-initialization).

### 2. `compute`
```julia
function compute(params::newModel_v1, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_newModel_v1 params
    @unpack_nt (f1, f2) ⇐ forcing
    @unpack_nt var1 ⇐ land.diagnostics

    ## calculate variables
    var_1 = f1*param1 + param2 + f2

    ## pack land variables
    @pack_nt begin
        var_1 ⇒ land.diagnostics
    end
    return land
end
```
- Implements core model calculations
- Updates model state
- Returns modified `land` structure

## Input Arguments

::::tabs

=== approach

All models are defined as follows:

````julia
abstract type newModel <: LandEcosystem end

@bounds @describe @units @timescale @with_kw struct newModel_v1{T1,T2} <: newModel
    param1::T1 = 1.0 | (2.0, 5.0) | "description 1" | "units 1" | ""
    param2::T2 = 0.0 | (1.0, 2.0) | "description 2" | "units 2" | ""
end

````

=== forcing

A NamedTuple with all the forcing variables, i.e.

````julia
forcing = (;
    rain = 2.2f0,
    clay = [30f0, 10f0, 5f0, 2f0, 1f0],
    )
````

=== helpers

A NamedTuple with all the shared variables across models.


## Computing across Approaches

After implementing a model approach, you can:
1. Compose multiple approaches together, namely, apply `compute` on different methods and updating `land` on each one of them.
2. Apply the model over multiple time steps
3. Use `LandWrapper` to collect and analyze results

Also, note that in practice, you would want to do this for multiple time steps. For the output of this operation, we use a `LandWrapper` that collects all fields in a user-friendly manner (see [Land utils](./land_utils)).


## Performance Considerations

:::warning zero allocations
Test that all new `compute` methods have zero allocations:

```julia
using BenchmarkTools
@benchmark compute($model_example, $forcing, $land, $helpers)
```

or `@btime` for a shorter description:

```julia
@btime compute($model_example, $forcing, $land, $helpers);
```
:::

## Best Practices

1. **Type Definition**
   - Use clear, descriptive names
   - Follow SINDBAD naming conventions
   - Document the purpose of each model

2. **Method Implementation**
   - Follow the standard method order
   - Document each method's purpose
   - Handle errors appropriately

3. **Variable Management**
   - Use appropriate variable groups
   - Follow land structure conventions
   - Document variable purposes

4. **Documentation**
   - Include comprehensive docstrings
   - Document model assumptions
   - Provide usage examples
