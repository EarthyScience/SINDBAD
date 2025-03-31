# Sindbad.jl

[![][docs-stable-img]][docs-stable-url][![][docs-dev-img]][docs-dev-url][![][ci-img]][ci-url] [![][codecov-img]][codecov-url][![Julia][julia-img]][julia-url][![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue)](https://github.com/EarthyScience/Sindbad.jl/blob/main/LICENSE)

<img src="docs/src/assets/logo.png" align="right" style="padding-left:10px;" width="150"/>

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://earthyscience.github.io/Sindbad.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://earthyscience.github.io/Sindbad.jl/dev/

[codecov-img]: https://codecov.io/gh/EarthyScience/Sindbad.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/EarthyScience/Sindbad.jl

[ci-img]: https://github.com/EarthyScience/Sindbad.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/EarthyScience/Sindbad.jl/actions?query=workflow%3ACI

[julia-img]: https://img.shields.io/badge/julia-v1.10+-blue.svg
[julia-url]: https://julialang.org/

Welcome to the git repository for the development of the framework for **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els `(SINDBAD)`. 

`SINDBAD` is a model data integration framework that encompasses the `biogeochemical cycles of water and carbon`, allows for extensive and flexible integration of parsimonious models with a diverse set of observational data streams.

### Repository Structure

`Sindbad.jl` and its sub-repositories all live in the Sindbad `monorepo`. At the root level of the repository, definitions of Sindbad models, variables, and functions needed for internal model executions are included.

For a short description on sub-packages under `/lib/`

<details>
  <summary><span style="color:orange"> 🔥 Click for details 🔥</span></summary>

- `SindbadData.jl`: includes functions to load the forcing and observation data, and has dev dependency on SindbadUtils.

- `SindbadExperiment.jl`: includes the dev dependencies on all other Sindbad packages that can be used to run an experiment and save the experiment outputs.

- `SindbadMetrics.jl`: includes the calculation of loss metrics and has dependency on `SindbadUtils.jl`.

- `SindbadML.jl`: includes the dev dependencies on `SindbadTEM.jl`, `SindbadMetrics.jl`, `SindbadSetup.jl`, and `SindbadUtils.jl` as well as external ML libraries to do hybrid modeling.

- `SindbadOptimization.jl`: includes the optimization schemes and functions to optimize the model, and has dev dependency on `SindbadTEM.jl` and `SindbadMetrics.jl`.

- `SindbadSetup.jl`: includes the setup of sindbad model structure and info from the json settings, and has dev dependency on `Sindbad.jl` and `SindbadUtils.jl`.

- `SindbadTEM.jl`: includes the main functions to run SINDBAD Terrestrial Ecosystem Model, and has dev dependency on `Sindbad.jl`, `SindbadSetup.jl`, and `SindbadUtils.jl`.

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

Create a new experiment directory, e.g., my_env by copying the ```base_env``` in the ```examples``` directory.


```
julia > run(`cp -rv base_env exp_mine`)
julia > run(`cd exp_mine`)
```

The ```Project.toml``` includes all SINDBAD packages as,

```
[sources]
Sindbad = {path = "../.."}
SindbadData = {path = "../../lib/SindbadData"}
SindbadExperiment = {path = "../../lib/SindbadExperiment"}
SindbadML = {path = "../../lib/SindbadML"}
SindbadMetrics = {path = "../../lib/SindbadMetrics"}
SindbadOptimization = {path = "../../lib/SindbadOptimization"}
SindbadSetup = {path = "../../lib/SindbadSetup"}
SindbadTEM = {path = "../../lib/SindbadTEM"}
SindbadUtils = {path = "../../lib/SindbadUtils"}
```

You could delete the ones you are not going to use by deleting the entries in the toml.

To instantiate and environment, open a Julia REPL, go to the package mode by typing ```]``` and enter:
```
instantiate
```

You may need an additional ```resolve``` and ```update```.

Alternatively you could add the local package in dev mode by doing:

```
dev ../.. ../../lib/SindbadUtils ../../lib/SindbadData ../../lib/SindbadMetrics ../../lib/SindbadSetup ../../lib/SindbadTEM ../../lib/SindbadOptimization ../../lib/SindbadExperiment ../../lib/SindbadML
```

Note that the paths are relative to the environment directory. Even in this method, the local sources as shown in the first method can be added to the ```Project.toml``` so that the updates and changes are automatically sourced.


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

## Copyright
SINDBAD (Strategies to Integrate Data and Biogeochemical Models) A model data integration framework
Copyright (C) 2025  Max-Planck-Gesellschaft zur Förderung der Wissenschaften

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
