export getExperimentInfo
export prepExperimentForward
export prepExperimentOpti


"""
    getExperimentInfo(experiment_json::String; replace_info=nothing)

A helper function just to get info after experiment has been loaded and modified
"""

"""
    getExperimentInfo(sindbad_experiment::String; replace_info = nothing)

DOCSTRING
"""
function getExperimentInfo(sindbad_experiment::String; replace_info=nothing)
    @info "prepExperimentForward: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=deepcopy(replace_info))

    @info "prepExperimentForward: setup experiment..."
    info = setupInfo(info)
    return info
end

"""
prepExperimentForward(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""

"""
    prepExperimentForward(sindbad_experiment::String; replace_info = nothing)

DOCSTRING
"""
function prepExperimentForward(sindbad_experiment::String; replace_info=nothing)
    @info "\n----------------------------------------------\n"

    @info "prepExperimentForward: getting experiment info..."
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)

    if getBool(info.tem.helpers.run.save_info)
        @info "prepExperimentForward: saving info..."
        @save joinpath(info.tem.helpers.output.settings, "info.jld2") info
    end

    if getBool(info.tem.helpers.run.catch_model_errors)
        @info "prepExperimentForward: setting error catcher..."
        Sindbad.eval(:(error_catcher = []))
    end
    @info "\n----------------------------------------------\n"
    @info "prepExperimentForward: get forcing data..."
    forcing = getForcing(info)

    @info "\n----------------------------------------------\n"

    @info "prepExperimentForward: setup output..."
    @info "\n----------------------------------------------\n"
    output = prepTEMOut(info, forcing.helpers)
    return info, forcing, output
end

"""
prepExperimentOpti(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""

"""
    prepExperimentOpti(sindbad_experiment::String; replace_info = nothing)

DOCSTRING
"""
function prepExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    @info "\n----------------------------------------------\n"

    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)

    @info "runExperiment: get observations..."
    @info "\n----------------------------------------------\n"
    observations = getObservation(info, forcing.helpers)
    return info, forcing, output, observations
end
