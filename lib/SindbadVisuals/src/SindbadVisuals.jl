module SindbadVisuals
using Reexport: @reexport
using GLMakie
using Colors
using SindbadUtils

include("plotOutputData.jl")
@reexport using GLMakie.Makie

end # module SindbadVisuals
