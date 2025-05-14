using Sindbad
using SindbadTEM
using SindbadData
using SindbadSetup
using SindbadMetrics
using SindbadML
using SindbadOptimization
using SindbadVisuals
using SindbadExperiment

using InteractiveUtils
using DocumenterVitepress
using Documenter
using DocStringExtensions
# using DocumenterMermaid
# dev ../ ../lib/SindbadUtils ../lib/SindbadData ../lib/SindbadMetrics ../lib/SindbadSetup ../lib/SindbadTEM ../lib/SindbadML

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

if !isdir(joinpath(@__DIR__,"build/final_site/pages/concept/sindbad_info"))
    cp(joinpath(@__DIR__,"src/pages/concept/sindbad_info"), joinpath(@__DIR__,"build/final_site/pages/concept/sindbad_info"); force=true)
end

deploydocs(; 
    repo = "github.com/EarthyScience/SINDBAD", # this must be the full URL!
    target = "build", # this is where Vitepress stores its output
    branch = "gh-pages",
    devbranch = "main",
    push_preview = true
)