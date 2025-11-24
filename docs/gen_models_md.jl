using Sindbad.Simulation
using InteractiveUtils
open(joinpath(@__DIR__, "./src/pages/code/models.md"), "w") do o_file
    # write(o_file, "## Models\n\n")
    write(o_file, "```@docs\nSindbadTEM.Processes\n```\n")

    write(o_file, "## Available Models\n\n")

    sindbad_models_from_types = nameof.(Sindbad.subtypes(Sindbad.LandEcosystem))
    foreach(sort(collect(sindbad_models_from_types))) do sm
        sms = string(sm)
        write(o_file, "### $(sm)\n\n")
        # write(o_file, "== $(sm)\n")
        write(o_file, "```@docs\n$(sm)\n```\n")
        write(o_file, ":::details $(sm) approaches\n\n")
        write(o_file, ":::tabs\n\n")

        foreach(Sindbad.subtypes(getfield(Sindbad, sm))) do apr

            write(o_file, "== $(apr)\n")
            write(o_file, "```@docs\n$(apr)\n```\n")
        end
        write(o_file, "\n:::\n\n")
        write(o_file, "\n----\n\n")
    end
    write(o_file, "## Internal\n\n")
    write(o_file, "```@meta\nCollapsedDocStrings = false\nDocTestSetup= quote\nusing SindbadTEM.Processes\nend\n```\n")
    write(o_file, "\n```@autodocs\nModules = [SindbadTEM.Processes]\nPublic = false\n```")
end