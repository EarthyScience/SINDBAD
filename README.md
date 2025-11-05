# Sindbad.jl

[![][docs-stable-img]][docs-stable-url][![][docs-dev-img]][docs-dev-url][![][ci-img]][ci-url] [![][codecov-img]][codecov-url][![Julia][julia-img]][julia-url][![License: EUPLv1.2](https://img.shields.io/badge/License-EUPLv1.2-seagreen)](https://github.com/EarthyScience/Sindbad.jl/blob/main/LICENSE)

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

Researchers and developers actively developing the model and doing research using [this public SINDBAD repo](https://github.com/EarthyScience/SINDBAD) are encouraged to contact and join [the RnD-Team](./governance4RnD.md), which provides "beta" updates under active development.

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
pkg > add git@github.com:EarthyScience/SINDBAD.git
```

- without git repo access

Get the latest sindbad.jl package and browse to the directory (sindbad_root)

### How to dev/use the different packages

Start a julia prompt in the sindbad_root

```
julia
```

Go to main sandbox directory
```
cd sandbox
```

Create a new sandbox directory, e.g., my_env and go to that directory

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

Before running the experiments, download the example by running the following script in the ````sandbox```` directory

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
with active contributions from [Sujan Koirala](https://www.bgc-jena.mpg.de/person/skoirala/2206), [Xu Shan](https://www.bgc-jena.mpg.de/person/138641/2206), [Jialiang Zhou](https://www.bgc-jena.mpg.de/person/137086/2206), [Lazaro Alonso](https://www.bgc-jena.mpg.de/person/lalonso/2206), [Fabian Gans](https://www.bgc-jena.mpg.de/person/fgans/4777761), [Felix Cremer](https://www.bgc-jena.mpg.de/person/fcremer/2206), [Nuno Carvalhais](https://www.bgc-jena.mpg.de/person/ncarval/2206).

For a full list of current and previous contributors, see http://sindbad-mdi.org/pages/about/team.html

## Copyright and license


**SINDBAD: Strategies to Integrate Data and Biogeochemical Models**  

**Copyright © 2025**  
Max-Planck-Gesellschaft zur Förderung der Wissenschaften

For copyright details, see the [NOTICE](./NOTICE) file.

---

#### License

SINDBAD is free and open-source software, licensed under the [European Union Public License v1.2 (EUPL)](https://eupl.eu/1.2/en).

---

#### Your Rights

You are free to:

- Copy, modify, and redistribute the code  
- Use the software as a package in your own projects, regardless of their license or copyright status  
- Apply the software in both commercial and non-commercial contexts  

---

#### Your Responsibilities

If you modify the code — excluding changes made solely for interoperability — you **must redistribute the modified version under the EUPL v1.2 or a compatible license**. This ensures the long-term sustainability of the project and supports an open, inclusive, and collaborative community.

---

#### Disclaimer

This software is provided in the hope that it will be useful, but **without any warranty** — including, without limitation, the implied warranties of merchantability or fitness for a particular purpose.
