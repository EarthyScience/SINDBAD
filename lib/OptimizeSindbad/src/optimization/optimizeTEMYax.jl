export mapOptimizeModel

function unpackYaxOpti(args; forcing_variables::AbstractArray)
    nforc = length(forcing_variables)
    outputs = first(args)
    forcings = args[2:(nforc+1)]
    observations = args[(nforc+2):end]
    return outputs, forcings, observations
end

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
