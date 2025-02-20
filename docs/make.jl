using Sindbad
using SindbadTEM
using SindbadData
using SindbadSetup
using SindbadMetrics
using SindbadML
using InteractiveUtils
using DocumenterVitepress
using Documenter
using DocStringExtensions

# dev ../lib/SindbadUtils ../lib/SindbadData ../lib/SindbadMetrics ../lib/SindbadSetup ../lib/SindbadTEM ../lib/SindbadML

makedocs(; sitename="Sindbad",
    authors="Sindbad Pirates",
    clean=true,
    format=DocumenterVitepress.MarkdownVitepress(
        repo = "",
    ),
    remotes=nothing,
    draft=false,
    warnonly=true,
    source="src",
    build="build",
    )
