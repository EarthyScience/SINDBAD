using Revise
using Sindbad
using ProgressMeter
using Sindbad.ForwardDiff
using YAXArrays
# Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFile = "exp_mapEco/settings_mapEco/experiment.json"


info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
# spinup_forcing = getSpinupForcing(forcing.data, info.tem);



output = setupOutput(info);


info = setupOptimization(info);
output = setupOptiOutput(info, output);



#Sindbad.eval(:(debugcatcherr = []))
#@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);
#outcubes[2]

# optimization
observations = getObservation(info, Val(:yaxarray_s)); 


function unpackOpti(args; tem, forcing_variables)
    nforc = length(forcing_variables)
    outputs = first(args)
    forcings = args[2:(nforc+1)]
    observations = args[(nforc+2):end]
    return outputs,forcings,observations
end


function optimizeModelInner(args...; out, tem, info_optim, forcing_variables, obs_variables, spinup_forcing)
    output, forcing, observation = unpackOpti(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, forcing)...)
    observation = (; Pair.(obs_variables, observation)...)


    params, _ = optimizeModel(forcing, out, observation,
    tem, info_optim; spinup_forcing=spinup_forcing)
    output[:] = params.optim
end


function mapOptimizeModel(forcing, output, tem, info_optim, observations,
    ; spinup_forcing=nothing,max_cache=1e9)
    incubes = (forcing.data..., observations.data...)
    indims = (forcing.dims..., observations.dims...)
    forcing_variables = forcing.variables
    outdims = output.dims
    out = output.init_out
    # obscubes = observations.data
    obs_variables = observations.variables


    res = mapCube(optimizeModelInner,
    (incubes...,);
    out=out,
    tem=tem,
    info_optim = info_optim,
    forcing_variables=forcing_variables,
    obs_variables=obs_variables,
    spinup_forcing=spinup_forcing,
    indims=indims,
    outdims=output.paramdims,
    max_cache=1e9,
    )

   
end

res = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
    ; spinup_forcing=nothing,max_cache=2e9)

savecube(res,"./optiparams.zarr")