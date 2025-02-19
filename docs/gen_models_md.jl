using Sindbad

open(joinpath(@__DIR__, "./src/pages/code/models.md"), "w") do o_file
    foreach(sort(collect(sindbad_models))) do sm
        sms = string(sm)
        write(o_file, "## $(sm)\n\n")
        # write(o_file, "== $(sm)\n")
        write(o_file, "```@docs\n$(sm)\n```\n")
        write(o_file, ":::details $(sm) approaches\n\n")
        write(o_file, ":::tabs\n\n")

        foreach(subtypes(getfield(Sindbad, sm))) do apr

            write(o_file, "== $(apr)\n")
            write(o_file, "```@docs\n$(apr)\n```\n")
        end
        write(o_file, "\n:::\n\n")
    end
end