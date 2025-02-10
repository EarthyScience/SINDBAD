```@raw html
# Sindbad's structure 
```

The core components that define any model are explained on the following sections.

:::info

We should think about adding a template model structure. And use it as baseline to explain the components to new users that just want to know what is available.
- Document selected_models better! specially the order in which they are executed!

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

`land` is a NamedTuple (NT) that carries and passes information across SINDBAD's models. The `land` variables are organized in subfields, and the depth of the NT should be exactly 2: a field diving the variable groups, and a subfield storing the data.

If a variable is only used in only one model, but it is necessary to be precomputed, the model name itself, (e.g., cCycleBase) is used as the field. So, `land` can technically have many fields. But anything shared across models is grouped to contain variables with common characteristics, such as,

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

````@example land_fields
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


````@ansi land_fields
using SindbadUtils: tcPrint
tcPrint(land)
````

::: danger

- there are no-cross checks for overwriting of variables
- repeated fields across groups should be avoided

:::

## Compute

Then the application for the `newModel` is done calling `compute` as follows:

````julia
function compute(params::newModel_v1, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_newModel_v1 params
    @unpack_nt (f1, f2) ⇐ forcing
    @unpack_nt var1 ⇐ land.diagnostics # similarly from land.fluxes, land.pools, etc...

    ## calculate variables
    var_1 = f1*param1 + param2 + f2

    ## pack land variables
    @pack_nt begin
        var_1 ⇒ land.diagnostics # similarly to land.fluxes, land.pools, etc...
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
    @unpack_nt (f1, f2) ⇐ forcing
    @unpack_nt var1 ⇐ land.diagnostics # similarly from land.fluxes, land.pools, etc...

    ## calculate variables
    new_var_1 = f1*param1 + param2 + var1*f2

    ## pack land variables
    @pack_nt begin
        new_var_1 ⇒ land.diagnostics # similarly to land.fluxes, land.pools, etc...
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
    @unpack_nt (f1, f2) ⇐ forcing
    @unpack_nt var1 ⇐ land.diagnostics

    ## calculate variables
    new_var2 = f1*α + β + var1 * f2[2] # [!code focus]

    ## pack land variables
    @pack_nt begin
        new_var2 ⇒ land.diagnostics # [!code focus]
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
tcPrint(land)
````

### Apply compute to new model

Now, create a  `compute` function for this model

````@example mdesign
function compute(params::mExample, forcing, land, helpers)
    ## unpack parameters, forcing and variables store in land
    @unpack_mExample params
    @unpack_nt (f1, f2) ⇐ forcing
    @unpack_nt (var1, new_var2) ⇐ land.diagnostics

    ## calculate variables
    new_var1_value = f1*α + β + var1 * f2[2] + new_var2 * f2[1] # [!code highlight]
    # update var1 value
    var1 = new_var1_value # [!code highlight]
    ## pack land variables
    @pack_nt begin
        var1 ⇒ land.diagnostics # [!code highlight]
    end
    return land
end
# and apply `compute` to new model to update `var1` value
land = compute(model_example, forcing, land, helpers)
nothing # hide
````

````@ansi mdesign
tcPrint(land)
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

What's next? Well, `composing`! Namely, apply `compute` on different methods and updating `land` on each one of them.

The main functions for this are defined on `SindbadTEM`. See the `TEM` section to know more.

Also, note that in practice, you would want to do this for multiple time steps. For the output of this operation, we use a `LandWrapper` that collects all fields in a user-friendly manner.

## LandWrapper

```@example land_wrapper
using SindbadTEM.SindbadUtils: LandWrapper
using Random
Random.seed!(123)
```

The following mimics the expected output when performing a full forward simulation with multiple time steps. Here, you can see how to query the output.

```@example land_wrapper
land_time_series = map(1:10) do i
    (; fluxes = (; g_flux = rand(Float32)),
    diagnostics = (; c_vegs = rand(Float32, 5)), 
    models = (; ),
    pools = (; d_pool = rand(Float32, 4),),
    properties = (; ),
    states = (; )
    )
end
nothing # hide
```

```@ansi land_wrapper
land_wrapped = LandWrapper(land_time_series)
```

note that at the top level, only the main tuple names are printed. If you want to see what else is inside each one, then do the following:

```@ansi land_wrapper
land_wrapped.fluxes
```
and for the actual values

```@ansi land_wrapper
land_wrapped.fluxes.g_flux
```

or

```@ansi land_wrapper
land_wrapped.pools
```
with values

```@ansi land_wrapper
land_wrapped.pools.d_pool
```

## Plot LandWrapper output

```@example land_wrapper
using CairoMakie
```

```@example land_wrapper
g_flux = land_wrapped.fluxes.g_flux
lines(g_flux; figure = (; size = (600, 300)))
```

or the pools by first using `stackArrays`:

```@example land_wrapper
using SindbadTEM.SindbadUtils: stackArrays

d_pool = land_wrapped.pools.d_pool
series(stackArrays(d_pool); color = [:black, :red, :dodgerblue, :orange],
    figure = (; size = (600, 300)))
```

### Attach named dimensions to land outputs

Now, let's say that we know the `x` and `y` dimensions of your arrays, then you could for example do

```@example land_wrapper
using SindbadData.DimensionalData
using Dates

g_flux = land_wrapped.fluxes.g_flux
# create a time range
start_time = DateTime("2025-01-01")
end_time = DateTime("2025-01-10")
time_interval = start_time:Day(1):end_time
# attach a time dimension
dd_flux = DimArray(g_flux,  (Ti=time_interval, ); name=:g_flux,)
# plot
lines(dd_flux; figure = (; size = (600, 300)))
```

and similarly for the `d_pool`:

```@example land_wrapper
using SindbadData: toDimStackArray
using Dates

pool_names = ["root", "veg", "leaf", "wood"]
# attach a pools dimension
dd_pool = toDimStackArray(stackArrays(d_pool), time_interval, pool_names)
# plot
series(dd_pool; color = [:black, :red, :dodgerblue, :orange],
    figure = (; size = (600, 300)))
```