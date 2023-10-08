export getExperimentInfo
export getGlobalAttributesForOutCubes
export getOutputFileInfo

"""
    getExperimentInfo(sindbad_experiment::String; replace_info = nothing)

A helper function just to get info after experiment has been loaded and modified
"""
function getExperimentInfo(sindbad_experiment::String; replace_info=Dict())
    @info "getExperimentInfo: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=deepcopy(replace_info))

    @info "getExperimentInfo: setup experiment..."
    info = setupInfo(info)
    saveInfo(info, info.tem.helpers.run.save_info)
    setDebugErrorCatcher(info.tem.helpers.run.catch_model_errors)
    @info "\n------------------------------------------------\n"
    return info
end


"""
    getGlobalAttributesForOutCubes(info)


"""
function getGlobalAttributesForOutCubes(info)
    os = Sys.iswindows() ? "Windows" : Sys.isapple() ?
         "macOS" : Sys.islinux() ? "Linux" : "unknown"
    io = IOBuffer()
    versioninfo(io)
    str = String(take!(io))
    julia_info = split(str, "\n")

    io = IOBuffer()
    # Pkg.status("Sindbad", io=io)
    # sindbad_version = String(take!(io))
    global_attr = Dict(
        "simulation_by" => ENV["USER"],
        "experiment" => info.experiment.basics.name,
        "domain" => info.experiment.basics.domain,
        "date" => string(Date(now())),
        # "SINDBAD" => sindbad_version,
        "machine" => Sys.MACHINE,
        "os" => os,
        "host" => gethostname(),
        "julia" => string(VERSION),
    )
    return global_attr
end


"""
    getOutputFileInfo(info)


"""
function getOutputFileInfo(info)
    global_metadata = getGlobalAttributesForOutCubes(info)
    file_prefix = joinpath(info.output.data, info.experiment.basics.name * "_" * info.experiment.basics.domain)
    out_file_info = (; global_metadata=global_metadata, file_prefix=file_prefix)
    return out_file_info
end


function saveInfo(info, ::DoSaveInfo)
    @info "  saveInfo: saving info..."
    @save joinpath(info.tem.helpers.output.settings, "info.jld2") info
    return nothing
end

function saveInfo(::DoNotSaveInfo)
    return nothing
end


function setDebugErrorCatcher(::DoCatchModelErrors)
    @info "  setDebugErrorCatcher: setting error catcher..."
    Sindbad.eval(:(error_catcher = []))
    return nothing
end

function setDebugErrorCatcher(::DoNotCatchModelErrors)
    return nothing
end
