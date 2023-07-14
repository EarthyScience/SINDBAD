using Sindbad, ForwardSindbad, OptimizeSindbad
using ForwardDiff


experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);
info, forcing = getForcing(info, Val{:zarr}());
land_init = createLandInit(info.pools, info.tem);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);
obsv = getObsKeyedArrayFromYaxArray(observations);

tblParams = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters)

loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepRunEcosystem(output,
    forc,
    info.tem);

tem_helpers = tem_with_vals.helpers;
tem_spinup = tem_with_vals.spinup;
tem_models = tem_with_vals.models;
tem_variables = tem_with_vals.variables;
tem_optim = info.optim;
out_variables = output.variables;
forward = tem_with_vals.models.forward;



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


function reDoOneLocation(loc_land_init, approaches, tem_helpers, loc_forcing, f_one)
    land_prec = ForwardSindbad.runDefine!(loc_land_init, getForcingForTimeStep(loc_forcing, 1), approaches,
        tem_helpers)
    land = land_prec
    for ts = 1:tem_helpers.dates.size
        f = getForcingForTimeStep(loc_forcing, tem_helpers.vals.forc_vars, ts, f_one)
        land = runModels!(land, f, approaches, tem_helpers)
    end
    return land
end


site_location = loc_space_maps[1];
loc_forcing, loc_output, loc_obs =
    getLocDataObsN(output.data,
        forc, obs, site_location);

loc_space_ind = loc_space_inds[1];
loc_land_init = land_init_space[1];
loc_output = loc_outputs[1];
loc_forcing = loc_forcings[1];


@time big_land = ForwardSindbad.coreEcosystem(
    forward,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);

function get_loc_loss(
    new_apps,
    loc_obs,
    loc_forcing,
    loc_land_init, # now fixed arguments
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)
    big_land = ForwardSindbad.coreEcosystem(
        new_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        f_one)
    lossVec = getLossVectorArray(loc_obs, landWrapper(big_land), tem_optim)
    t_loss = combineLossArray(lossVec, Val{:sum}())
    return t_loss
end

function loc_loss(up_params, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    new_apps = Tuple(updateModelParametersType(tblParams, forward, up_params))
    return get_loc_loss(new_apps, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
end

function fdiff_grads(f_loss, v, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)
    gf(v) = f_loss(v, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    return ForwardDiff.gradient(gf, v)
end

kwargs_fixed = (;
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one
);

fdiff_grads(loc_loss, tblParams.default, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)

@time fdiff_grads(loc_loss, tblParams.default, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)

#=
function get_loc_loss(
    newApproaches,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    f_one)
    big_land = ForwardSindbad.coreEcosystem(
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        f_one)
    lossVec = getLossVectorArray(loc_obs, landWrapper(big_land), tem_optim)
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
    tem_optim,
    loc_land_init,
    f_one)


function loc_loss(upVector, forward, kwargs...)
    newApproaches = Tuple(updateModelParametersType(tblParams, forward, upVector))
    return get_loc_loss(newApproaches, kwargs...)
end

kwargs = (;
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    f_one
);

@time loc_loss(tblParams.default, forward, kwargs...)

s_loc(x) = loc_loss(x, forward, kwargs...)

CHUNK_SIZE = 8
cfg = ForwardDiff.GradientConfig(s_loc, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());
$
@time grad = ForwardDiff.gradient(s_loc, p_vec, cfg) # cfg
=#
