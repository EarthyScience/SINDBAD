# SINDBAD land

```land``` is a NamedTuple that carries and passes information across SINDBAD models.

## SINDBAD metrics

This document is for the metrics used to evaluate and optimize SINDBAD.

## The library
The sindbad metrics are under the library package ```SindbadMetrics``` in the lib directory.


## How to

### get the list of metrics?
In the REPL, starting using SindbadMetrics
````Julia
using SindbadMetrics
````

````Julia
subtypes(SindbadMetric)
````

## add a new metric
define and export types in ```metricTypes.jl``` as
````julia
export NewMtric
struct NewMtric <: SindbadMetric end
````

Note that the ```NewMetirc``` should 
- be in PascalCase.
- be subtype of ```SindbadMetric```

Once the type is defined, it should be used as. dispatch in the loss function in ```metrics.jl```

````julia
function metric(y, yσ, ŷ, ::NewMetirc)
    new_metric = f(y, yσ, ŷ)
    return new_metric
end

````
The function should 
- always be called loss
- should have the same first three arguments
- should dispatch on the type of the argument as ```::NewMetirc```

