using Sindbad
using Documenter

DocMeta.setdocmeta!(Sindbad, :DocTestSetup, :(using Sindbad); recursive=true)

makedocs(;
    modules=[Sindbad],
    authors="lazarusA <lazarus.alon@gmail.com> and contributors",
    repo="https://git.bgc-jena.mpg.de/lalonso/Sindbad.jl/blob/{commit}{path}#{line}",
    sitename="Sindbad.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lalonso.gitlab.io/Sindbad.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
