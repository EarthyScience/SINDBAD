export getExperimentInfo
export prepExperimentForward
export prepExperimentOpti


"""
    getExperimentInfo(sindbad_experiment::String; replace_info = nothing)

A helper function just to get info after experiment has been loaded and modified
"""
function getExperimentInfo(sindbad_experiment::String; replace_info=nothing)
    @info "prepExperimentForward: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=deepcopy(replace_info))

    @info "prepExperimentForward: setup experiment..."
    info = setupInfo(info)
    return info
end


function saveInfo(info, ::DoSaveInfo)
    @info "prepExperimentForward: saving info..."
    @save joinpath(info.tem.helpers.output.settings, "info.jld2") info
    return nothing
end

function saveInfo(::DoNotSaveInfo)
    return nothing
end


function setDebugErrorCatcher(::DoCatchModelErrors)
    @info "prepExperimentForward: setting error catcher..."
    Sindbad.eval(:(error_catcher = []))
    return nothing
end

function setDebugErrorCatcher(::DoNotCatchModelErrors)
    return nothing
end


"""
    prepExperimentForward(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function prepExperimentForward(sindbad_experiment::String; replace_info=nothing)
    @info "\n----------------------------------------------\n"

    @info "prepExperimentForward: getting experiment info..."
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)

    saveInfo(info, info.tem.helpers.run.save_info)
    setDebugErrorCatcher(info.tem.helpers.run.catch_model_errors)

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
