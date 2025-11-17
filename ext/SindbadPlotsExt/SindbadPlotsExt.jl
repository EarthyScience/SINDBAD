"""
# SindbadPlotsExt Module

The `SindbadPlotsExt` extension provides visualization tools and helpers for the SINDBAD output analysis. While still under development, the aim is to provide comprehensive tools for visualizing and understanding the behavior of models within the SINDBAD framework.

## Features
- **Output Data Visualization**: Tools for plotting model outputs and diagnostics of hybrid experimetn.
- **Input-Output Relationships**: Functions for visualizing input-output structures of models.
- **Interactive Plots**: Support for interactive visualizations using `GLMakie`.
- **Static Plots**: Support for static visualizations using `Plots`.

## Dependencies
- `SindbadCore`: Core SINDBAD framework.
- `Plots`: For static plotting.

## Included Files
- `plotOutputData.jl`: Contains functions for visualizing model output data.
- `plotFromSindbadInfo.jl`: Contains functions for visualizing input-output relationships and other metadata from `SINDBAD info`.

## Usage
To use the extension, simply do:
```julia
using Plots
```
"""
module SindbadPlotsExt
    using SindbadCore
    import Sindbad
    import Sindbad: plotIOModelStructure

    using Plots:
        annotate! as plots_annotate!,
        default as plots_default,
        histogram as plots_histogram,
        histogram! as plots_histogram!,
        scatter as plots_scatter,
        scatter! as plots_scatter!,
        vline as plots_vline,
        vline! as plots_vline!,
        hline as plots_hline,
        hline! as plots_hline!,
        xlims! as plots_xlims!,
        ylims! as plots_ylims!,
        xlabel! as plots_xlabel!,
        ylabel! as plots_ylabel!,
        title! as plots_title!,
        plot as plots_plot,
        plot! as plots_plot!,
        savefig as plots_savefig,
        text as plots_text,
        mm as plots_mm,
        cm as plots_cm

    include("plotOutputUsingPlots.jl")
    include("plotFromSindbadInfo.jl")

end # module SindbadPlotsExt
