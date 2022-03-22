using Sinbad
using Documenter

DocMeta.setdocmeta!(Sinbad, :DocTestSetup, :(using Sinbad); recursive=true)

makedocs(;
    modules=[Sinbad],
    authors="lazarusA <lazarus.alon@gmail.com> and contributors",
    repo="https://git.bgc-jena.mpg.de/sindbad/sinbad.jl/blob/{commit}{path}#{line}",
    sitename="Sinbad.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://git.bgc-jena.mpg.de/sindbad/sinbad.jl",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "Basic usage" => "basics.md"
    ]
)
#=
deploydocs(;
    repo="git.bgc-jena.mpg.de/sindbad/sinbad.jl"
)
=#
