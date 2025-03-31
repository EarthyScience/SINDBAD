### Repository Structure

`SINDBAD` and its sub-repositories all live in the Sindbad `monorepo`. At the root level of the repository, definitions of Sindbad models, variables, and functions needed for internal model executions are included.

For a short description on sub-packages under `/lib/`

<details>
  <summary><span style="color:orange"> 🔥 Click for details 🔥</span></summary>

- `SindbadData.jl`: includes functions to load the forcing and observation data, and has dev dependency on SindbadUtils.

- `SindbadExperiment.jl`: includes the dev dependencies on all other Sindbad packages that can be used to run an experiment and save the experiment outputs.

- `SindbadMetrics.jl`: includes the calculation of loss metrics and has dependency on `SindbadUtils.jl`.

- `SindbadML.jl`: includes the dev dependencies on `SindbadTEM.jl`, `SindbadMetrics.jl`, `SindbadSetup.jl`, and `SindbadUtils.jl` as well as external ML libraries to do hybrid modeling.

- `SindbadOptimization.jl`: includes the optimization schemes and functions to optimize the model, and has dev dependency on `SindbadTEM.jl` and `SindbadMetrics.jl`.

- `SindbadSetup.jl`: includes the setup of sindbad model structure and info from the json settings, and has dev dependency on `SINDBAD` and `SindbadUtils.jl`.

- `SindbadTEM.jl`: includes the main functions to run SINDBAD Terrestrial Ecosystem Model, and has dev dependency on `SINDBAD`, `SindbadSetup.jl`, and `SindbadUtils.jl`.

- `SindbadUtils.jl`: includes utility functions that are used in other Sindbad lib packages, which has no dev dependency on other lib packages and Sindbad info, and is dependent on external libraries only.

</details>

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


### Using Sindbad in your example

Sindbad is divided into following sub-packages which can be imported in your example with
```using $PACKAGE```

For example 

```using SindbadExperiment```

allows to run the full experiment.

Other smaller packages can be imported and put together to build an experiment workflow as needed
