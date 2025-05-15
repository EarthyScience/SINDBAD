export getExperimentInfo
export getGlobalAttributesForOutCubes

"""
    getExperimentInfo(sindbad_experiment::String; replace_info=Dict())

Loads and sets up the experiment configuration, saving the information and enabling debugging options if specified.

# Arguments:
- `sindbad_experiment::String`: Path to the experiment configuration file.
- `replace_info::Dict`: (Optional) A dictionary of fields to replace in the configuration.

# Returns:
- A NamedTuple `info` containing the fully loaded and configured experiment information.

# Notes:
- The function performs the following steps:
  1. Loads the experiment configuration using `getConfiguration`.
  2. Sets up the experiment `info` using `setupInfo`.
  3. Saves the experiment `info` if `save_info` is enabled.
  4. Sets up a debug error catcher if `catch_model_errors` is enabled.
"""
function getExperimentInfo(sindbad_experiment::String; replace_info=Dict())
    @info "getExperimentInfo: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=deepcopy(replace_info))

    @info "getExperimentInfo: setup experiment..."
    info = setupInfo(info)
    saveInfo(info, info.helpers.run.save_info)
    setDebugErrorCatcher(info.helpers.run.catch_model_errors)
    @info "\n------------------------------------------------\n"
    return info
end


"""
    getGlobalAttributesForOutCubes(info)

Generates global attributes for output cubes, including system and experiment metadata.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- A dictionary `global_attr` containing global attributes such as:
  - `simulation_by`: The user running the simulation.
  - `experiment`: The name of the experiment.
  - `domain`: The domain of the experiment.
  - `date`: The current date.
  - `machine`: The machine architecture.
  - `os`: The operating system.
  - `host`: The hostname of the machine.
  - `julia`: The Julia version.

# Notes:
- The function collects system information using Julia's `Sys` module and `versioninfo`.
"""
function getGlobalAttributesForOutCubes(info)
    os = Sys.iswindows() ? "Windows" : Sys.isapple() ?
         "macOS" : Sys.islinux() ? "Linux" : "unknown"
    io = IOBuffer()
    versioninfo(io)
    str = String(take!(io))
    julia_info = split(str, "\n")

    # io = IOBuffer()
    # Pkg.status("Sindbad", io=io)
    # sindbad_version = String(take!(io))
    global_attr = Dict(
        "simulation_by" => ENV["USER"],
        "experiment" => info.temp.experiment.basics.name,
        "domain" => info.temp.experiment.basics.domain,
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
    saveInfo(info, to_save::DoSaveInfo | ::DoNotSaveInfo)

Saves or skips saving the experiment configuration to a file.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.
- `::DoSaveInfo`: A type dispatch indicating that the information should be saved.
- `::DoNotSaveInfo`: A type dispatch indicating that the information should not be saved.

# Returns:
- `nothing`.

# Notes:
- When saving, the experiment configuration is saved as a `.jld2` file in the `settings` directory.
"""
function saveInfo end

function saveInfo(info, ::DoSaveInfo)
    @info "  saveInfo: saving info..."
    @save joinpath(info.output.dirs.settings, "info.jld2") info
    return nothing
end

function saveInfo(::DoNotSaveInfo)
    return nothing
end

"""
    setDebugErrorCatcher(::DoCatchModelErrors | ::DoNotCatchModelErrors)

Enables/Disables a debug error catcher for the SINDBAD framework. When enabled, a variable `error_catcher` is enabled and can be written to from within SINDBAD models and functions. This can then be accessed from any scope with `Sindbad.error_catcher`

# Arguments:
- `::DoCatchModelErrors`: A type dispatch indicating that model errors should be caught.
- `::DoNotCatchModelErrors`: A type dispatch indicating that model errors should not be caught.

# Returns:
- `nothing`.

# Notes:
- When enabled, sets up an empty error catcher using `Sindbad.eval`.
"""
function setDebugErrorCatcher end

function setDebugErrorCatcher(::DoCatchModelErrors)
    @info "  setDebugErrorCatcher: setting error catcher..."
    Sindbad.eval(:(error_catcher = []))
    return nothing
end

function setDebugErrorCatcher(::DoNotCatchModelErrors)
    return nothing
end
