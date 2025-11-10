using SindbadExperiment
using SindbadML
packages_list = (:Sindbad, :SindbadUtils, :SindbadTEM, :SindbadSetup, :SindbadData, :SindbadOptimization, :SindbadExperiment, :SindbadML, :SindbadMetrics)
mkpath("./src/pages/code_gen")
lib_path = joinpath(@__DIR__, "../lib")


foreach(packages_list) do package_name
    doc_path = joinpath(@__DIR__, "./src/pages/code_gen/$(package_name).md")
    open(doc_path, "w") do o_file
        write(o_file, "```@docs\n$(package_name)\n```\n")
        write(o_file, "## Functions\n\n")
        the_package = getfield(Main, package_name)
        lib_functions = getSindbadDefinitions(the_package, Function)
        if !isempty(lib_functions)
            foreach(lib_functions) do function_name
                write(o_file, "### $(function_name)\n")
                write(o_file, "```@docs\n$(function_name)\n```\n")
                write(o_file, "\n----\n\n")
            end
        end
        lib_methods = getSindbadDefinitions(the_package, Method)
        if !isempty(lib_methods)
            write(o_file, "## Methods\n\n")
            foreach(lib_methods) do method_name
                write(o_file, "### $(method_name)\n")
                write(o_file, "```@docs\n$(method_name)\n```\n")
                write(o_file, "\n----\n\n")
            end
        end

        lib_types = getSindbadDefinitions(the_package, Type)
        if !isempty(lib_types)
            write(o_file, "## Types\n\n")
            foreach(lib_types) do type_name
                write(o_file, "### $(type_name)\n")
                write(o_file, "```@docs\n$(type_name)\n```\n")
                write(o_file, "\n----\n\n")
            end
        end
        write(o_file, "```@meta\nCollapsedDocStrings = false\nDocTestSetup= quote\nusing $(package_name)\nend\n```\n")
        # write(o_file, "\n```@autodocs\nModules = [$(package_name)]\nPublic = false\n```")
        println("Generation Complete:: $(doc_path)")
    end
end

open(joinpath(@__DIR__, "./src/pages/code_gen/SindbadModels.md"), "w") do o_file
    # write(o_file, "## Models\n\n")
    write(o_file, "```@docs\nSindbad.Models\n```\n")

    write(o_file, "## Available Models\n\n")

    sindbad_models_from_types = nameof.(SindbadCore.subtypes(SindbadCore.LandEcosystem))
    foreach(sort(collect(sindbad_models_from_types))) do sm
        sms = string(sm)
        write(o_file, "### $(sm)\n\n")
        # write(o_file, "== $(sm)\n")
        write(o_file, "```@docs\n$(sm)\n```\n")
        write(o_file, ":::details $(sm) approaches\n\n")
        write(o_file, ":::tabs\n\n")

        foreach(SindbadCore.subtypes(getfield(Sindbad, sm))) do apr

            write(o_file, "== $(apr)\n")
            write(o_file, "```@docs\n$(apr)\n```\n")
        end
        write(o_file, "\n:::\n\n")
        write(o_file, "\n----\n\n")
    end
    write(o_file, "## Internal\n\n")
    write(o_file, "```@meta\nCollapsedDocStrings = false\nDocTestSetup= quote\nusing SindbadCore.Models\nend\n```\n")
    write(o_file, "\n```@autodocs\nModules = [SindbadCore.Models]\nPublic = false\n```")
end