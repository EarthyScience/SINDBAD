using Sindbad
using Documenter

#DocMeta.setdocmeta!(Sindbad, :DocTestSetup, :(using Sindbad); recursive=true)

makedocs(;
    #modules=[Sindbad],
    #authors="SINDBAD <sindbad.pirates@bgc-jena.mpg.de> and contributors",
    #repo="https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl/blob/{commit}{path}#{line}",
    sitename="Sindbad.jl",
    format=Documenter.HTML(; prettyurls=true),
    #format=Documenter.HTML(;
    #    prettyurls=get(ENV, "CI", "false") == "true",
    #    canonical="https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl",
    #    assets=String[]
    #),
    pages=["Home" => "index.md", "Basic usage" => "basics.md"])
#=
deploydocs(;
    repo="git.bgc-jena.mpg.de/sindbad/Sindbad.jl"
)
=#
