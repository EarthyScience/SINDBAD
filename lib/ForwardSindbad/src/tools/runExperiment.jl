export runExperimentForward

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""

"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, output, nothing::Val{:forward})

DOCSTRING

# Arguments:
- `info`: DESCRIPTION
- `forcing`: DESCRIPTION
- `output`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:forward})
    print("-------------------Forward Run Mode---------------------------\n")

    additionaldims = setdiff(keys(forcing.helpers.sizes), [:time])
    if isempty(additionaldims)
        run_output = mapRunEcosystem(forcing,
            output,
            info.tem,
            info.tem.models.forward;
            max_cache=info.experiment.exe_rules.yax_max_cache)
    else
        run_output = runTEM!(forcing, info)
    end
    return run_output
end

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""

"""
    runExperimentForward(sindbad_experiment::String; replace_info = nothing)

DOCSTRING
"""
function runExperimentForward(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, output, Val(:forward))
    saveOutCubes(info, run_output, output)
    return run_output
end
