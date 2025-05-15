"""
# SindbadVisuals Module

The `SindbadVisuals` module provides visualization tools and helpers for the SINDBAD output analysis. While still under development, the aim is to provide comprehensive tools for visualizing and understanding the behavior of models within the SINDBAD framework.

## Features
- **Output Data Visualization**: Tools for plotting model outputs and diagnostics of hybrid experimetn.
- **Input-Output Relationships**: Functions for visualizing input-output structures of models.
- **Interactive Plots**: Support for interactive visualizations using `GLMakie`.
- **Static Plots**: Support for static visualizations using `Plots`.

## Dependencies
- `Sindbad`: Core SINDBAD framework.
- `SindbadUtils`: Utility functions for SINDBAD.
- `GLMakie`: For interactive plotting.
- `Plots`: For static plotting.
- `Colors`: For color management in plots.

## Included Files
- `plotOutputData.jl`: Contains functions for visualizing model output data.
- `plotFromSindbadInfo.jl`: Contains functions for visualizing input-output relationships and other metadata from `SINDBAD info`.

## Usage
To use the module, simply import it:
```julia
using SindbadVisuals
```
"""
module SindbadVisuals
    using Sindbad
    using SindbadUtils
    # using GLMakie
    # @reexport using GLMakie.Makie
    using Colors
    @reexport using Plots: annotate! as plots_annotate!, default as plots_default, scatter as plots_scatter, scatter! as plots_scatter!, vline as plots_vline, vline! as plots_vline!, hline as plots_hline, hline! as plots_hline!, xlims! as plots_xlims!, ylims! as plots_ylims!, xlabel! as plots_xlabel!, ylabel! as plots_ylabel!, title! as plots_title!, plot as plots_plot, plot! as plots_plot!, savefig as plots_savefig, text as plots_text, mm as plots_mm

    # include("plotOutputData.jl")
    include("plotFromSindbadInfo.jl")

end # module SindbadVisuals
