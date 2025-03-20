export optimizeTEMYax

"""
    unpackYaxOpti(args; forcing_vars::AbstractArray)

Unpacks the variables for the mapCube function

# Arguments
- `all_cubes`: Collection of cubes containing input, output and optimization/observation variables
- `forcing_vars::AbstractArray`: Array specifying which variables should be forced/constrained

# Returns
Unpacked data arrays
"""
function unpackYaxOpti(all_cubes; forcing_vars::AbstractArray)
    nforc = length(forcing_vars)
    outputs = first(all_cubes)
    forcings = all_cubes[2:(nforc+1)]
    observations = all_cubes[(nforc+2):end]
    return outputs, forcings, observations
end

"""   
    optimizeYax(map_cubes...; out::NamedTuple, tem::NamedTuple, optim::NamedTuple, forcing_vars::AbstractArray, obs_vars::AbstractArray)

A helper function to optimize parameters for each pixel by mapping over the YAXcube(s).

# Arguments
- `map_cubes...`: Variadic input of cube maps to be optimized
- `out::NamedTuple`: Output configuration parameters
- `tem::NamedTuple`: TEM (Terrestrial Ecosystem Model) configuration parameters
- `optim::NamedTuple`: Optimization configuration parameters
- `forcing_vars::AbstractArray`: Array of forcing variables used in optimization
- `obs_vars::AbstractArray`: Array of observation variables used in optimization
"""
function optimizeYax(map_cubes...; out::NamedTuple, tem::NamedTuple, optim::NamedTuple, forcing_vars::AbstractArray, obs_vars::AbstractArray)
    output, forcing, observation = unpackYaxOpti(map_cubes; forcing_vars)
    forcing = (; Pair.(forcing_vars, forcing)...)
    observation = (; Pair.(obs_vars, observation)...)
    land_output_type = getfield(SindbadSetup, toUpperCaseFirst(info.settings.experiment.exe_rules.land_output_type, "LandOut"))()
    params = optimizeTEM(forcing, observation, info, land_output_type)
    return output[:] = params.optim
end

"""
    optimizeTEMYax(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, optim::NamedTuple, observations::NamedTuple; max_cache=1e9)

Optimizes the Terrestrial Ecosystem Model (TEM) parameters for each pixel by mapping over the YAXcube(s).


# Arguments
- `forcing::NamedTuple`: Input forcing data for the TEM model
- `output::NamedTuple`: Output configuration settings
- `tem::NamedTuple`: TEM model parameters and settings
- `optim::NamedTuple`: Optimization parameters and settings
- `observations::NamedTuple`: Observed data for model calibration

# Keywords
- `max_cache::Float64=1e9`: Maximum cache size for optimization process

# Returns
Optimized TEM parameters cube
"""
function optimizeTEMYax(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, optim::NamedTuple, observations::NamedTuple; max_cache=1e9)
    incubes = (forcing.data..., observations.data...)
    indims = (forcing.dims..., observations.dims...)
    forcing_vars = collect(forcing.variables)
    outdims = output.parameter_dim
    out = output.land_init
    obs_vars = collect(observations.variables)

    params = mapCube(optimizeYax, (incubes...,); out=out, tem=tem, optim=optim, forcing_vars=forcing_vars, obs_vars=obs_vars, indims=indims, outdims=outdims, max_cache=max_cache)
    return params
end
