# SINDBAD.jl

Welcome to the git repository for the development of the framework for **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els (SINDBAD). 

SINDBAD is a model data integration framework that encompasses the biogeochemical cycles of water and carbon, allows for extensive and flexible integration of parsimonious models with a diverse set of observational data streams.

### Developers

SINDBAD is being developed at the Department of Biogeochemical Integration of the Max Planck Institute for Biogeochemistry in Jena, Germany. Following is the list of SINDBAD Julia developers.

- Sujan Koirala (<skoirala@bgc-jena.mpg.de>)

- Lazaro Alonso (<lalonso@bgc-jena.mpg.de>)

- Felix Cremer (<fcremer@bgc-jena.mpg.de>)

- Fabian Gans (<fgans@bgc-jena.mpg.de>)

- Nuno Carvalhais (<ncarval@bgc-jena.mpg.de>)

### Details

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lalonso.gitlab.io/sindbad.jl/dev)
[![Build Status](https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl/badges/main/pipeline.svg)](https://git.bgc-jena.mpg.de/sindbad/sindbad.jl/pipelines)
[![Coverage](https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl/badges/main/coverage.svg)](https://git.bgc-jena.mpg.de/sindbad/sindbad.jl/commits/main)

### Installation

```julia
julia]
pkg > add https://git.bgc-jena.mpg.de/sindbad/sindbad.jl.git
```

### How to dev/use the different packages

```julia
julia]
pkg > dev --local https://git.bgc-jena.mpg.de/sindbad/sindbad.jl.git # local will clone the repository at ./dev/Sindbad
```
Now, `dev` the sub packages

```julia
julia]
pkg > dev dev/Sindbad/ForwardSindbad dev/Sindbad/OptimizeSindbad  # local will clone the repository at ./dev/Sindbad
```

### Usage

Before running the experiments, download the example by running the following script in the ````examples``` directory

````bash
bash download_example_data.sh
````

The example directory consists of several experiments for different model structure. Browse through the folders (starting with exp_*), and use experiment*.jl scripts there to run the experiments.
