```@raw html
# Sindbad's structure 
```

The core components that define any model are explained on the following sections.

:::info

We should think about adding a template model structure. And use it as baseline to explain the components to new users that just want to know what is available.

:::

## Modelling Design

The computation of any model requires the following input arguments:

### model, forcing, land and helpers

::::tabs

=== model

All models are defined as follows:

````julia
abstract type newModel <: LandEcosystem end

@bounds @describe @units @with_kw struct newModel_v1{T1,T2} <: newModel
    param1::T1 = 1.0 | (2.0, 5.0) | "description 1" | "units 1"
    param2::T2 = 0.0 | (1.0, 2.0) | "description 2" | "units 2"
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

=== land

```land``` is a NamedTuple (NT) that carries and passes information across SINDBAD models. The ```land``` variables are organized in the subfields, and the depth of the NT should be exactly 2: a field diving the variable groups, and a subfield storing the data.

If a variable is only used in only one model, but it is necessary to be precomputed, the model name itself, (e.g., cCycleBase) is used as the field. So, ```land``` can technically have many fields. But, anything that is shared across models are grouped to contain the variables that have common characteristics as,

:::tabs

== constants

Helpers and variables that are dependent on the model structure but do not change in time or model iterations/parameters.

== diagnostics

Variables that are derived from either forcing/pools/states to indicates stressors, controllers, rates and so on.

== fluxes

Variables in mass/area/time units.

== models

Instances that help model computation by dispatching on types. used in calculation of soil properties or updating pools.

== pools

Model storages and pools and their changes, usually only those variables automatically generated from model_structure.json.

== properties

Variables pertaining to characteristics of the land surface, e.g., soil and vegetation properties, and those directly derived from them.

== states

Ecosystem states and variables derived from these states and pools.

:::

````julia
land = (;
    constants = (; ),
    diagnostics = (; ),
    fluxes = (; ),
    models = (; ),
    pools = (; ),
    properties = (; ),
    states = (; )
    )
````

=== helpers

A NamedTuple with all the shared variables across models.

::::

## Displaying land
For every model structure/implementation, the ```land``` should be examined for potential violations of the variable grouping using:


````julia
julia> using SindbadUtils: tcPrint
# julia> tcPrint(land)  # this should work, we need some merging
nothing 
````


- there are no-cross checks for overwriting of variables
- repeated fields across groups should be avoided

## Compute

Then the application for the `newModel` is done calling `compute` as follows:

````julia
function compute(params::newModel_v1, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_newModel_v1 params
    @unpack_land (f1, f2) ∈ forcing
    @unpack_land var1 ∈ land.diagnostics # similarly from land.fluxes, land.pools, etc...

    ## calculate variables
    var_1 = f1*param1 + param2 + f2

    ## pack land variables
    @pack_land begin
        var_1 => land.diagnostics # similarly to land.fluxes, land.pools, etc...
    end
    return land
end

````

## Define / precompute one-time variables

If additional one-time calculations are necessary, then those should be defined via a `define` function call as:

````julia
function define(params::newModel_v1, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_newModel_v1 params
    @unpack_land (f1, f2) ∈ forcing
    @unpack_land var1 ∈ land.diagnostics # similarly from land.fluxes, land.pools, etc...

    ## calculate variables
    new_var_1 = f1*param1 + param2 + var1*f2

    ## pack land variables
    @pack_land begin
        new_var_1 => land.diagnostics # similarly to land.fluxes, land.pools, etc...
    end
    return land
end

````

## Creating model components

### Model definition

````@example mdesign
using Sindbad
using Sindbad: @describe, @bounds, @units, @with_kw
# Define a model abstract type
abstract type modelExample <: LandEcosystem end
# define a concrete struct type
@bounds @describe @units @with_kw struct mExample{T1,T2} <: modelExample
    α::T1 = 1.0 | (2.0, 5.0) | "description 1" | "units 1"
    β::T2 = 0.0 | (1.0, 2.0) | "description 2" | "units 2"
end
nothing # hide
````

### Input arguments

Now, let's precompute additional variables. For that, we would need some toy `forcing`, `land`, and `helpers`

````@example mdesign
forcing = (;
    f1 = 2.0f0,
    f2 = [1.0f0, 2.5f0]
    )

land = (;
    constants = (; ),
    diagnostics = (; var1=2.5f0),
    fluxes = (; ),
    models = (; ),
    pools = (; ),
    properties = (; ),
    states = (; )
    )

## and not special helpers for now
helpers = (;
    );
nothing # hide
````

### Define / precompute new variable

Now, `define` a function for this model

````@example mdesign
function define(params::mExample, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_mExample params
    @unpack_land (f1, f2) ∈ forcing
    @unpack_land var1 ∈ land.diagnostics

    ## calculate variables
    new_var2 = f1*α + β + var1 * f2[2] # [!code focus]

    ## pack land variables
    @pack_land begin
        new_var2 => land.diagnostics # [!code focus]
    end
    return land
end
````

### Instantiate model struct

````@example mdesign
model_example = mExample()
````

### Apply the `define` function

````@example mdesign
land = define(model_example, forcing, land, helpers)
nothing # hide
````


display `land` using tcPrint

````@ansi mdesign
using SindbadUtils: tcPrint
# tcPrint(land) #  # this should work, we need some merging
nothing
````

### Apply compute to new model

Now, create a  `compute` function for this model

````@example mdesign
function compute(params::mExample, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_mExample params
    @unpack_land (f1, f2) ∈ forcing
    @unpack_land (var1, new_var2) ∈ land.diagnostics

    ## calculate variables
    new_var1_value = f1*α + β + var1 * f2[2] + new_var2 * f2[1] # [!code highlight]
    # update var1 value
    var1 = new_var1_value # [!code highlight]
    ## pack land variables
    @pack_land begin
        var1 => land.diagnostics # [!code highlight]
    end
    return land
end

## and apply `compute` to new model to update var1 value

land = compute(model_example, forcing, land, helpers)
nothing # hide
````

````@ansi mdesign
# tcPrint(land) # this should work, we need some merging
nothing
````

### Zero allocations

:::warning zero allocations

Test that all new `compute` methods have zero allocations.

````@ansi mdesign
using BenchmarkTools
@benchmark compute($model_example, $forcing, $land, $helpers)
````

or `@btime` for a shorter description

````@ansi mdesign
@btime compute($model_example, $forcing, $land, $helpers);
````

:::

What's next? Well, `composing`! This is calling `compute` on different methods updating `land` on each one of them. 

The main functions for this are defined on `SindbadTEM`. See the `TEM` section to know more.
