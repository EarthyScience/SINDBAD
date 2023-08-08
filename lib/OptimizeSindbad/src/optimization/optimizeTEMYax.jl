export mapOptimizeModel

"""
    unpackYaxOpti(args; forcing_variables::AbstractArray)

DOCSTRING
"""
function unpackYaxOpti(args; forcing_variables::AbstractArray)
    nforc = length(forcing_variables)
    outputs = first(args)
    forcings = args[2:(nforc+1)]
    observations = args[(nforc+2):end]
    return outputs, forcings, observations
end

"""
    doOptimizeModel(args; out::NamedTuple, tem::NamedTuple, optim::NamedTuple, forcing_variables::AbstractArray, obs_variables::AbstractArray)

DOCSTRING

# Arguments:
- `args`: DESCRIPTION
- `out`: DESCRIPTION
- `tem`: DESCRIPTION
- `optim`: DESCRIPTION
- `forcing_variables`: DESCRIPTION
- `obs_variables`: DESCRIPTION
"""
function doOptimizeModel(args...;
    out::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple,
    forcing_variables::AbstractArray,
    obs_variables::AbstractArray)
    output, forcing, observation = unpackYaxOpti(args; forcing_variables)
    forcing = (; Pair.(forcing_variables, forcing)...)
    observation = (; Pair.(obs_variables, observation)...)
    params = optimizeTEM(forcing, observation, info, Val(:land_stacked))
    return output[:] = params.optim
end

"""
    mapOptimizeModel(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, optim::NamedTuple, observations::NamedTuple; max_cache = 1.0e9)

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: DESCRIPTION
- `tem`: DESCRIPTION
- `optim`: DESCRIPTION
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `max_cache`: DESCRIPTION
"""
function mapOptimizeModel(forcing::NamedTuple,
    output::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple,
    observations::NamedTuple,
    ;
    max_cache=1e9)
    incubes = (forcing.data..., observations.data...)
    indims = (forcing.dims..., observations.dims...)
    forcing_variables = collect(forcing.variables)
    outdims = output.paramdims
    out = output.land_init
    obs_variables = collect(observations.variables)

    params = mapCube(doOptimizeModel,
        (incubes...,);
        out=out,
        tem=tem,
        optim=optim,
        forcing_variables=forcing_variables,
        obs_variables=obs_variables,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache)
    return params
end
