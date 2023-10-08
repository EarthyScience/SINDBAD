export optimizeTEMYax

"""
    unpackYaxOpti(args; forcing_vars::AbstractArray)


"""
function unpackYaxOpti(all_cubes; forcing_vars::AbstractArray)
    nforc = length(forcing_vars)
    outputs = first(all_cubes)
    forcings = all_cubes[2:(nforc+1)]
    observations = all_cubes[(nforc+2):end]
    return outputs, forcings, observations
end

"""
    optimizeYax(map_cubes; out::NamedTuple, tem::NamedTuple, optim::NamedTuple, forcing_vars::AbstractArray, obs_vars::AbstractArray)



# Arguments:
- `map_cubes`: collection/tuple of all input, observation and output cubes from mapCube
- `out`: DESCRIPTION
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `optim`: DESCRIPTION
- `forcing_vars`: forcing variables
- `obs_vars`: observation variables
"""
function optimizeYax(map_cubes...;
    out::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple,
    forcing_vars::AbstractArray,
    obs_vars::AbstractArray)
    output, forcing, observation = unpackYaxOpti(map_cubes; forcing_vars)
    forcing = (; Pair.(forcing_vars, forcing)...)
    observation = (; Pair.(obs_vars, observation)...)
    land_output_type = getfield(SindbadSetup, toUpperCaseFirst(info.experiment.exe_rules.land_output_type, "LandOut"))()
    params = optimizeTEM(forcing, observation, info, land_output_type)
    return output[:] = params.optim
end

"""
    optimizeTEMYax(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, optim::NamedTuple, observations::NamedTuple; max_cache = 1.0e9)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `optim`: DESCRIPTION
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `max_cache`: DESCRIPTION
"""
function optimizeTEMYax(forcing::NamedTuple,
    output::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple,
    observations::NamedTuple;
    max_cache=1e9)
    incubes = (forcing.data..., observations.data...)
    indims = (forcing.dims..., observations.dims...)
    forcing_vars = collect(forcing.variables)
    outdims = output.parameter_dim
    out = output.land_init
    obs_vars = collect(observations.variables)

    params = mapCube(optimizeYax,
        (incubes...,);
        out=out,
        tem=tem,
        optim=optim,
        forcing_vars=forcing_vars,
        obs_vars=obs_vars,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache)
    return params
end
