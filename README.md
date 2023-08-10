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

### Package Structure

Sindbad.jl includes a core Sindbad package in the root of the repository, and several sub-repositories in the lib directory.
The packages are as follows

- Sindbad: a core package in the root that includes definition of sindbad models and variables, and functions needed for internal model executions
- SindbadData: includes functions to load the forcing and observation data, and has dev dependency on SindbadUtils
- SindbadExperiment: includes the dev dependencies on all other Sindbad packages that can be used to run an experiment and save the experiment outputs
- SindbadHybrid: includes the dev dependencies on SindbadTEM, SindbadMetrics, SindbadSetup, and SindbadUtils as well as external ML libraries to do hybrid modeling
- SindbadMetrics: includes the calculation of loss metrics and has dependency on SindbadUtils
- SindbadOptimization: includes the optimization schemes and functions to optimize the model, and has dev dependency on SindbadTEM and SindbadMetrics
- SindbadSetup: includes the setup of sindbad model structure and info from the json settings, and has dev dependency on Sindbad and SindbadUtils
- SindbadTEM: includes the main functions to run SINDBAD Terrestrial Ecosystem Model, and and has dev dependency on Sindbad, SindbadSetup, and SindbadUtils
- SindbadUtils: includes utility functions that are used in other Sindbad lib packages, which has no dev dependency on other lib packages and Sindbad info, and is dependent on external libraries only. 

### Using Sindbad in your example

Sindbad is divided into following sub-packages which can be imported in your example with
```using $PACKAGE```

For example 

```using SindbadExperiment```

allows to run the full experiment.

Other smaller packages can be imported and put together to build an experiment workflow as needed
