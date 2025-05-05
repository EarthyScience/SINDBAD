# Land Data Structure

The `land` structure is a `NamedTuple` that serves as the primary data container for SINDBAD models, facilitating information exchange between different model components.

## Structure Organization

The `land` variables are organized hierarchically with exactly two levels:
1. **Field**: Groups variables by their functional category
2. **Subfield**: Contains the actual data values

## Field Categories

Variables are grouped into the following categories based on their characteristics and usage:

### Shared Fields
These fields contain variables used across multiple models:

- **constants**: Helper variables and structure-dependent parameters that remain constant throughout the simulation
- **diagnostics**: Derived variables indicating stressors, controllers, and rates based on forcing, pools, or states
- **fluxes**: Mass/area/time variables representing ecosystem fluxes
- **models**: Type-based instances used for soil property calculations and pool updates
- **pools**: Storage variables automatically generated from `model_structure.json`
- **properties**: Land surface characteristics (soil, vegetation) and their derivatives
- **states**: Ecosystem states and derived variables

### Model-Specific Fields
Variables used exclusively by a single model are stored under the model name (e.g., `cCycleBase`).

## Structure Validation

To ensure proper organization and prevent potential issues, use the following command to examine the `land` structure:

```julia
julia> tcPrint(land)
```

::: danger Important Considerations

- No automatic checks prevent variable overwriting
- Avoid duplicating fields across different groups
- Maintain consistent naming conventions
- Ensure proper variable grouping

:::

## Best Practices

1. **Organization**
   - Keep variables in their appropriate categories
   - Use consistent naming conventions
   - Document any model-specific fields

2. **Validation**
   - Regularly check structure using `tcPrint`
   - Verify variable grouping
   - Ensure no unintended overwrites

3. **Maintenance**
   - Update documentation when adding new fields
   - Review structure after model modifications
   - Maintain clear variable categorization