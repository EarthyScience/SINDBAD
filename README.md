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
m1 = rainSnow()
m2 = snowMelt()
models = (m1, m2)

forcing, timesteps = getforcing()

outTime = evolveEcosystem(forcing, models, timesteps)
```
