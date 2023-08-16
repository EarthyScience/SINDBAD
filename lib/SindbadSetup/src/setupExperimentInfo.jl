export getExperimentInfo

"""
    getExperimentInfo(sindbad_experiment::String; replace_info = nothing)

A helper function just to get info after experiment has been loaded and modified
"""
function getExperimentInfo(sindbad_experiment::String; replace_info=nothing)
    @info "getExperimentInfo: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=deepcopy(replace_info))

    @info "getExperimentInfo: setup experiment..."
    info = setupInfo(info)
    saveInfo(info, info.tem.helpers.run.save_info)
    setDebugErrorCatcher(info.tem.helpers.run.catch_model_errors)
    @info "\n------------------------------------------------\n"
    return info
end


function saveInfo(info, ::DoSaveInfo)
    @info "saveInfo: saving info..."
    @save joinpath(info.tem.helpers.output.settings, "info.jld2") info
    return nothing
end

function saveInfo(::DoNotSaveInfo)
    return nothing
end


function setDebugErrorCatcher(::DoCatchModelErrors)
    @info "setDebugErrorCatcher: setting error catcher..."
    Sindbad.eval(:(error_catcher = []))
    return nothing
end

function setDebugErrorCatcher(::DoNotCatchModelErrors)
    return nothing
end
