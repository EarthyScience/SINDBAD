using Sindbad.Simulation
using Sindbad.Simulation
using Sindbad.DataLoaders
using Sindbad.SetupSimulation
using SindbadTEM.Metrics
using Sindbad.MachineLearning
using Sindbad.Optimization
using Sindbad.Visualization
using Sindbad.Simulation

using InteractiveUtils
using DocumenterVitepress
using Documenter
using DocStringExtensions
# using DocumenterMermaid
# dev ../ ../lib/Utils ../lib/SindbadData ../lib/SindbadMetrics ../lib/SetupSimulation ../lib/SindbadTEM ../lib/SindbadML

makedocs(; sitename="Sindbad",
    authors="Sindbad Development Team",
    clean=true,
    format=DocumenterVitepress.MarkdownVitepress(
        repo = "github.com/EarthyScience/SINDBAD",
    ),
    remotes=nothing,
    draft=false,
    warnonly=true,
    source="src",
    build="build",
    )

final_site_dir = joinpath(@__DIR__,"build/final_site/")
if !isdir(final_site_dir)
    final_site_dir = joinpath(@__DIR__,"build/1/")
end

if !isdir(joinpath(final_site_dir, "/pages/concept/sindbad_info"))
    cp(joinpath(@__DIR__,"src/pages/concept/sindbad_info"), joinpath(final_site_dir, "pages/concept/sindbad_info"); force=true)
end

DocumenterVitepress.deploydocs(; 
    repo = "github.com/EarthyScience/SINDBAD", # this must be the full URL!
    target = joinpath(@__DIR__, "build"), # this is where Vitepress stores its output
    branch = "gh-pages",
    devbranch = "main",
    push_preview = true
)