# SINDBAD.jl

Welcome to the git repository for the development of the framework for **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els (SINDBAD). 

SINDBAD is a model data integration framework that encompasses the biogeochemical cycles of water and carbon, allows for extensive and flexible integration of parsimonious models with a diverse set of observational data streams.

### Repository Structure

Sindbad.jl includes a core Sindbad package in the root of the repository, and several sub-repositories in the lib directory following the conventions of mono-repo.

The packages (under /lib) are as follows:

- Sindbad: a core package in the root that includes definition of sindbad models and variables, and functions needed for internal model executions
- SindbadData: includes functions to load the forcing and observation data, and has dev dependency on SindbadUtils
- SindbadExperiment: includes the dev dependencies on all other Sindbad packages that can be used to run an experiment and save the experiment outputs
- SindbadML: includes the dev dependencies on SindbadTEM, SindbadMetrics, SindbadSetup, and SindbadUtils as well as external ML libraries to do hybrid modeling
- SindbadMetrics: includes the calculation of loss metrics and has dependency on SindbadUtils
- SindbadOptimization: includes the optimization schemes and functions to optimize the model, and has dev dependency on SindbadTEM and SindbadMetrics
- SindbadSetup: includes the setup of sindbad model structure and info from the json settings, and has dev dependency on Sindbad and SindbadUtils
- SindbadTEM: includes the main functions to run SINDBAD Terrestrial Ecosystem Model, and and has dev dependency on Sindbad, SindbadSetup, and SindbadUtils
- SindbadUtils: includes utility functions that are used in other Sindbad lib packages, which has no dev dependency on other lib packages and Sindbad info, and is dependent on external libraries only

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

Create the julia environment, activate it, and instantiate all dev dependencies and packages by pasting the following in the package mode of Julia REPL.

Sindbad Experiments:
```
dev ../.. ../../lib/SindbadUtils ../../lib/SindbadData ../../lib/SindbadMetrics ../../lib/SindbadSetup ../../lib/SindbadTEM ../../lib/SindbadOptimization ../../lib/SindbadExperiment
```

SindbadML:
```
dev ../.. ../../lib/SindbadUtils/ ../../lib/SindbadData/ ../../lib/SindbadMetrics/ ../../lib/SindbadSetup/ ../../lib/SindbadTEM ../../lib/SindbadML
```

Once the dev dependencies are built, run
```
resolve
instantiate
```


### Download the example data

Before running the experiments, download the example by running the following script in the ````examples```` directory

````bash
bash download_example_data.sh
````


### Using Sindbad in your example

Sindbad is divided into following sub-packages which can be imported in your example with
```using $PACKAGE```

For example 

```using SindbadExperiment```

allows to run the full experiment.

Other smaller packages can be imported and put together to build an experiment workflow as needed

## SINDBAD Contributors 

SINDBAD is developed at the Department of Biogeochemical Integration of the Max Planck Institute for Biogeochemistry in Jena, Germany with the following active contributors
with active contributions from [Sujan Koirala](https://www.bgc-jena.mpg.de/person/skoirala/2206), [Lazaro Alonso](https://www.bgc-jena.mpg.de/person/lalonso/2206), [Xu Shan](https://www.bgc-jena.mpg.de/person/138641/2206), [Hoontaek Lee](https://www.bgc-jena.mpg.de/person/hlee/2206), [Fabian Gans](https://www.bgc-jena.mpg.de/person/fgans/4777761), [Felix Cremer](https://www.bgc-jena.mpg.de/person/fcremer/2206), [Nuno Carvalhais](https://www.bgc-jena.mpg.de/person/ncarval/2206).

For a full list of current and previous contributors, see https://earthyscience.github.io/Sindbad.jl/dev/pages/about/team