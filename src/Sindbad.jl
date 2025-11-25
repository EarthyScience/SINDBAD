"""
    Sindbad

Top-level orchestration package for **S**trategies to **IN**tegrate
**D**ata and **B**iogeochemic**A**l mo**D**els. `Sindbad` reexports the
complete `SindbadTEM` modeling stack and combines the user-facing
modules under `src/` to offer a single public entry point for data
ingest, configuration, simulation, optimization, machine learning,
and visualization workflows.

# Purpose:
- Provide a cohesive API that ties together process-level models from
  `SindbadTEM` with higher-level experiment tooling.
- Ensure every stage of a SINDBAD pipeline—data handling, setup, model
  execution, calibration, post-processing, and plotting—is available
  through one package.

# Dependencies:
- `SindbadTEM`: Core terrestrial ecosystem models, types, and utilities.
- `ConstructionBase`: Shared constructors needed by downstream modules.
- `CSV`: Input/output of tabular forcing and calibration datasets.
- `JSON`: Experiment metadata serialization (`parsefile`, `json`, `print`).
- `JLD2`: Persisting SINDBAD state, diagnostics, and trained artifacts.
- `YAXArrays` + `YAXArrays.Datasets`: Labeled n-dimensional arrays and
  dataset writers for model output.

# Included Modules:
1. **DataLoaders** (`src/DataLoaders/`):
   - Handles file IO, preprocessing, and conversion into SINDBAD-native
     data structures; exposes reusable loaders and utility helpers.
2. **SetupSimulation** (`src/SetupSimulation/`):
   - Builds experiment `info` objects, validates model selections, and
     wires pools, spinup settings, and derived configuration metadata.
3. **Simulation** (`src/Simulation/`):
   - Orchestrates terrestrial ecosystem simulations, including spinup,
     forward runs, diagnostics, and interaction with `SindbadTEM`.
4. **Optimization** (`src/Optimization/`):
   - Provides parameter-calibration utilities, optimizer bridges
     (NLopt, Optim, CMA-ES variants), and experiment-wide objective hooks.
5. **MachineLearning** (`src/MachineLearning/`):
   - Adds ML-assisted surrogates, emulators, and training pipelines that
     integrate with Sindbad outputs and optimization targets.
6. **Visualization** (`src/Visualization/`):
   - Supplies plotting and reporting helpers for experiment evaluation
     (time series, spatial maps, diagnostic overlays, etc.).

# Notes:
- Each submodule is included and reexported so end users can call
  `using Sindbad` and immediately access `Sindbad.DataLoaders`,
  `Sindbad.Simulation`, and the rest without extra imports.
- Shared dependencies are loaded here to guarantee consistent versions
  across all components.

# Examples:
```julia
using Sindbad

info = Sindbad.SetupSimulation.build_info("experiment_config.json")
forcing = Sindbad.DataLoaders.load_forcing(info)
results = Sindbad.Simulation.run(info, forcing)
Sindbad.Visualization.plot_output(results)
```
"""
module Sindbad
  using SindbadTEM.Reexport: @reexport

  @reexport using SindbadTEM
  @reexport using ConstructionBase
  @reexport using CSV: CSV
  @reexport using JSON: parsefile, json, print as json_print
  @reexport using JLD2: @save, load
  @reexport using YAXArrays: YAXArrays, YAXArray
  @reexport using YAXArrays.Datasets: savedataset



  include("DataLoaders/DataLoaders.jl")
  @reexport using .DataLoaders
  include("SetupSimulation/SetupSimulation.jl")
  @reexport using .SetupSimulation
  include("Visualization/Visualization.jl")
  @reexport using .Visualization
  include("Optimization/Optimization.jl")
  @reexport using .Optimization
  include("MachineLearning/MachineLearning.jl")
  @reexport using .MachineLearning
  include("Simulation/Simulation.jl")
  @reexport using .Simulation
end # module Sindbad
