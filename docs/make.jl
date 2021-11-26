using Sinbad
using Documenter

DocMeta.setdocmeta!(Sinbad, :DocTestSetup, :(using Sinbad); recursive = true)

makedocs(;
    modules = [Sindbad],
    authors = "lazarusA <lazarus.alon@gmail.com> and contributors",
    repo = "https://git.bgc-jena.mpg.de/sindbad/sinbad.jl/blob/{commit}{path}#{line}",
    sitename = "Sindbad.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://git.bgc-jena.mpg.de/sindbad/sinbad.jl",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md",
    ]
)
