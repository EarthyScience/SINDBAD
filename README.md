# Sinbad

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lalonso.gitlab.io/Sindbad.jl/dev)
[![Build Status](https://git.bgc-jena.mpg.de/sindbad/sinbad.jl/badges/main/pipeline.svg)](https://git.bgc-jena.mpg.de/sindbad/sinbad.jl/pipelines)
[![Coverage](https://git.bgc-jena.mpg.de/sindbad/sinbad.jl/badges/main/coverage.svg)](https://git.bgc-jena.mpg.de/sindbad/sinbad.jl/commits/main)

```julia
julia]
pkg > add https://git.bgc-jena.mpg.de/sindbad/sinbad.jl.git
```

```julia
using Sinbad
Model((rainSnow(), snowMelt()))
Model with parent object of type: 

Tuple{rainSnow, snowMelt}


Parameters:
┌───────────┬─────────────┬───────────────────────────────────────────┬─────────┬────────────┬─────────┐
│ component │   fieldname │                                       val │   units │     bounds │ forcing │
├───────────┼─────────────┼───────────────────────────────────────────┼─────────┼────────────┼─────────┤
│  rainSnow │        Rain │  [0.334908, 0.294191, 0.682813, 0.947053] │  mm d⁻¹ │   (0, 100) │    true │
│  rainSnow │        Snow │                                   missing │  mm d⁻¹ │    nothing │ nothing │
│  rainSnow │        Tair │ [0.0122408, 0.0206268, 0.749856, 0.10416] │      °C │  (-80, 60) │    true │
│  rainSnow │  Tair_thres │                                       0.5 │      °C │    (-5, 5) │ nothing │
│  rainSnow │      precip │                                   missing │    mm/d │    nothing │ nothing │
│  snowMelt │          Rn │ [0.864155, 0.0207866, 0.196542, 0.875294] │  MJ m⁻² │ (-50, 500) │    true │
│  snowMelt │        Tair │   [0.975886, 0.352139, 0.40019, 0.258772] │       C │  (-80, 60) │    true │
│  snowMelt │      melt_T │                                         3 │ nothing │    nothing │ nothing │
│  snowMelt │     melt_Rn │                                         2 │ nothing │    nothing │ nothing │
│  snowMelt │ snowMeltOut │                                   missing │ nothing │    nothing │ nothing │
└───────────┴─────────────┴───────────────────────────────────────────┴─────────┴────────────┴─────────┘
```
