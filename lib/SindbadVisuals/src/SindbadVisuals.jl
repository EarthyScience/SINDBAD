module SindbadVisuals
using Reexport: @reexport
using GLMakie
using Colors
using SindbadUtils

include("plot_output_data.jl")
@reexport using GLMakie.Makie

end # module SindbadVisuals
