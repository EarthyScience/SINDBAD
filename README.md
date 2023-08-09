# SINDBAD.jl

Welcome to the git repository for the development of the framework for **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els (SINDBAD). 

SINDBAD is a model data integration framework that encompasses the biogeochemical cycles of water and carbon, allows for extensive and flexible integration of parsimonious models with a diverse set of observational data streams.

## Developers

### Sindbad model and experiments
SINDBAD is developed at the Department of Biogeochemical Integration of the Max Planck Institute for Biogeochemistry in Jena, Germany. 

- Sujan Koirala (<skoirala@bgc-jena.mpg.de>)

- Lazaro Alonso (<lalonso@bgc-jena.mpg.de>)

- Nuno Carvalhais (<ncarval@bgc-jena.mpg.de>)

### Technical Support

- Fabian Gans (<fgans@bgc-jena.mpg.de>)

- Felix Cremer (<fcremer@bgc-jena.mpg.de>)

## Details

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://git.bgc-jena.mpg.de/sindbad/sindbad.jl)
[![Build Status](https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl/badges/main/pipeline.svg)](https://git.bgc-jena.mpg.de/sindbad/sindbad.jl/pipelines)
[![Coverage](https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl/badges/main/coverage.svg)](https://git.bgc-jena.mpg.de/sindbad/sindbad.jl/commits/main)

### Installation

- with git repo access
```
julia]
pkg > add https://git.bgc-jena.mpg.de/sindbad/sindbad.jl.git
```

- without git repo access

Get the latest sindbad.jl package and browse to the directory (sindbad_root)

### How to dev/use the different packages

Start a julia prompt in the sindbad_root
```
julia
```
Note that you may need to do the following in the new BGC cluster

```
ml proxy
ml julia
```

Go to main example directory
```
cd examples
```

Create a new experiment directory, e.g., my_env and go to that directory

```
julia > run(`mkdir -p my_env`)
julia > run(`cd my_env`)
```

Create the julia environment and instantiate all dependencies and packages as,
```
julia > include("../start_environment.jl")
```

### Download the example data

Before running the experiments, download the example by running the following script in the ````examples```` directory

````bash
bash download_example_data.sh
````

### Using Sindbad in your example

Sindbad is divided into following sub-packages which can be imported in your example with
```using $PACKAGE```
- Sindbad: pacckage including core models and setup of SINDBAD experiment
- SindbadTEM: package to run SINDABD experiment in the forward mode
- SindbadOptimization: package to carry out paramater optimization and invesion