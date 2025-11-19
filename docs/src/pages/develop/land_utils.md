# SINDBAD Land

`land` is a NamedTuple (NT) that carries and passes information across SINDBAD's models. For a detailed explanation of the `land` structure and its role in SINDBAD, see the [land concept documentation](../concept/land.md).

```julia
land = (;
    constants = (; ),
    diagnostics = (; ),
    fluxes = (; ),
    models = (; ),
    pools = (; ),
    properties = (; ),
    states = (; )
)
```

## Viewing Land Variables

### Basic Variable Access

To view land variables, you can use the `land` structure. For more information about variable types and their purposes, refer to the [land concept documentation](../concept/land.md#variable-types).

```julia
# View all available variables
keys(land)

# Access a specific variable
land.cVeg  # Carbon in vegetation
land.cSoil # Carbon in soil
land.TWS   # Total Water Storage
```

### Checking Variable Grouping

For every approach structure/implementation, the `land` should be examined for potential violations of the variable grouping using:

```julia
using SindbadCore.Utilities: tcPrint
tcPrint(land)
```

::: danger
- There are no cross-checks for overwriting of variables
- Repeated fields across groups should be avoided
:::

For more information about variable grouping and organization, see the [land concept documentation](../concept/land.md#variable-organization).

## Working with Time Series Data

### Using LandWrapper

The `LandWrapper` provides a convenient way to work with time series data from land model simulations. For more details about time series handling in SINDBAD, see the [land concept documentation](../concept/land.md#time-series-handling).

```julia
using SindbadCore.Utilities: LandWrapper
using Random
Random.seed!(123)

# Create example time series data
land_time_series = map(1:10) do i
    (; 
        fluxes = (; g_flux = rand(Float32)),
        diagnostics = (; c_vegs = rand(Float32, 5)), 
        models = (; ),
        pools = (; d_pool = rand(Float32, 4)),
        properties = (; ),
        states = (; )
    )
end

# Wrap the time series data
land_wrapped = LandWrapper(land_time_series)
```

The purpose of `LandWrapper` is to provide a structured interface for working with time series data from land model simulations. It:

1. Organizes time series data into a hierarchical structure
2. Provides convenient access to variables across time steps
3. Supports visualization and analysis of time series data
4. Maintains the relationship between different variable groups
5. Enables easy conversion to dimensional arrays for plotting

### Accessing Wrapped Data

```julia
# Access top-level groups
land_wrapped.fluxes
land_wrapped.pools

# Access specific variables
land_wrapped.fluxes.g_flux
land_wrapped.pools.d_pool
```

## Plotting Land Variables

### Basic Time Series Plots

For more information about visualization best practices, see the [land concept documentation](../concept/land.md#visualization).

```julia
using CairoMakie

# Plot a single flux
g_flux = land_wrapped.fluxes.g_flux
lines(g_flux; figure = (; size = (600, 300)))

# Plot multiple pools
using SindbadCore.Utilities: stackArrays
d_pool = land_wrapped.pools.d_pool
series(stackArrays(d_pool); 
    color = [:black, :red, :dodgerblue, :orange],
    figure = (; size = (600, 300))
)
```

### Adding Dimensions to Data

For more information about working with dimensional data, see the [land concept documentation](../concept/land.md#dimensional-data).

```julia
using DimensionalData
using Dates

# Add time dimension to flux data
start_time = DateTime("2025-01-01")
end_time = DateTime("2025-01-10")
time_interval = start_time:Day(1):end_time

g_flux = land_wrapped.fluxes.g_flux
dd_flux = DimArray(g_flux[:], (Ti=time_interval,); name=:g_flux)
lines(dd_flux; figure = (; size = (600, 300)))

# Add dimensions to pool data
using Sindbad.DataLoaders: toDimStackArray
pool_names = ["root", "veg", "leaf", "wood"]
dd_pool = toDimStackArray(stackArrays(d_pool), time_interval, pool_names)
series(dd_pool; 
    color = [:black, :red, :dodgerblue, :orange],
    figure = (; size = (600, 300))
)
```

## Best Practices

For comprehensive guidelines on working with land variables, see the [land concept documentation](../concept/land.md#best-practices).

1. **Data Organization**
   - Keep variables in their appropriate groups
   - Avoid duplicating variables across groups
   - Use descriptive names for variables

2. **Time Series Handling**
   - Use `LandWrapper` for time series data
   - Add appropriate dimensions to data
   - Consider memory usage for large datasets

3. **Visualization**
   - Use appropriate plot types for different variables
   - Include clear labels and legends
   - Consider color schemes for accessibility

4. **Documentation**
   - Document variable meanings and units
   - Include plot interpretation guidelines
   - Note any data processing steps
