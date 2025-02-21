```land``` is a NamedTuple that carries and passes information across SINDBAD models.

## Fields of land

The ```land``` variables are organized in the subfields, and the depth of the NT should be exactly 2: a field diving the variable groups, and a subfield storing the data.

If a variable is only used in only one model, but it is necessary to be precomputed, the model name itself, (e.g., cCycleBase) is used as the field. So, ```land``` can technically have many fields. But, anything that is shared across models are grouped to contain the variables that have common characteristics as,

- constants: helpers and variables that are dependent on the model structure but do not change in time or model iterations/parameters
- diagnostics: variables that are derived from either forcing/pools/states to indicates stressors, controllers, rates and so on.
- fluxes: variables in mass/area/time units
- models: instances that help model computation by dispatching on types. used in calculation of soil properties or updating pools
- pools: model storages and pools and their changes, usually only those variables automatically generated from model_structure.json
- properties: variables pertaining to characteristics of the land surface, e.g., soil and vegetation properties, and those directly derived from them
- states: ecosystem states and variables derived from these states and pools

## Displaying land
For every model structure/implementation, the ```land``` should be examined for potential violations of the variable grouping using:


````julia
julia> tcPrint(land)
````

::: danger

- there are no-cross checks for overwriting of variables
- repeated fields across groups should be avoided

:::