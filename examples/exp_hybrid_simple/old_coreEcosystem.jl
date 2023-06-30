using Sindbad, ForwardSindbad, OptimizeSindbad

experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);
info, forcing = getForcing(info, Val{:zarr}());
land_init = createLandInit(info.pools, info.tem);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

tblParams = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters)

loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
f_one = prepRunEcosystem(output.data,
    output.land_init,
    info.tem.models.forward,
    forc,
    forcing.sizes,
    info.tem);

tem_helpers = info.tem.helpers;
tem_spinup = info.tem.spinup;
tem_models = info.tem.models;
tem_variables = info.tem.variables;
tem_optim = info.optim;
out_variables = output.variables;
forward = info.tem.models.forward;

function getLocDataObsN(outcubes, forcing, obs, loc_space_map)
    loc_forcing = map(forcing) do a
        return view(a; loc_space_map...)
    end
    loc_obs = map(obs) do a
        return view(a; loc_space_map...)
    end
    ar_inds = last.(loc_space_map)

    loc_output = map(outcubes) do a
        return getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output, loc_obs
end

site_location = loc_space_maps[1];
loc_forcing, loc_output, loc_obs =
    getLocDataObsN(output.data, 
        forc, obs, site_location);

loc_space_ind = loc_space_inds[1];
loc_land_init = land_init_space[1];
loc_output = loc_outputs[1];
loc_forcing = loc_forcings[1];

res_out = ForwardSindbad.coreEcosystem(
        forward,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        Val(tem_variables),
        loc_land_init,
        f_one);

@time ForwardSindbad.coreEcosystem(
            forward,
            loc_forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            Val(tem_variables),
            loc_land_init,
            f_one);

function get_loc_loss(
    newApproaches,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    loc_land_init,
    f_one)
    big_land = ForwardSindbad.coreEcosystem(
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        Val(tem_variables),
        loc_land_init,
        f_one)
    # model_data = (; gpp = gpp)
    lossVec = getLossVectorArray(loc_obs, big_land, tem_optim)
    t_loss = combineLossArray(lossVec, Val{:sum}())
    return t_loss
end

get_loc_loss(
    forward,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    loc_land_init,
    f_one)

function loc_loss(upVector, forward, kwargs...)    
    newApproaches = Tuple(updateModelParametersType(tblParams, forward, upVector))
    return get_loc_loss(newApproaches, kwargs...)
end

kwargs =(;
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    loc_land_init,
    f_one
);

loc_loss(tblParams.defaults, forward, kwargs...)

using ForwardDiff

fg(x) = loc_loss(x, forward, kwargs...)
@time ForwardDiff.gradient(fg, tblParams.defaults)