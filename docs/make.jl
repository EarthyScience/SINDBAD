using Sindbad
using SindbadTEM
using InteractiveUtils
using DocumenterVitepress
using Documenter
using DocStringExtensions

# dev ../lib/SindbadUtils ../lib/SindbadData ../lib/SindbadMetrics ../lib/SindbadSetup ../lib/SindbadTEM

makedocs(; sitename="Sindbad",
    authors="Sindbad Pirates",
    clean=true,
    format=DocumenterVitepress.MarkdownVitepress(
        repo = "",
    ),
    remotes=nothing,
    draft=false,
    source="src",
    build="build",
    )