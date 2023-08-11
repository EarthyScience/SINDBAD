using Sindbad, SindbadTEM, SindbadOptimization
using ForwardDiff


experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);
forcing = getForcing(info);
land_init = createLandInit(info.pools, info.tem);

observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArrayWithNames(observations);
obsv = getKeyedArray(observations);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize)

loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_types,
forcing_one_timestep = prepTEM(forcing, info);

tem_helpers = tem_with_types.helpers;
tem_spinup = tem_with_types.spinup;
tem_models = tem_with_types.models;
tem_variables = tem_with_types.variables;
tem_optim = info.optim;
forward = tem_with_types.models.forward;



function getLocDataObsN(outcubes, forcing, obs_array, loc_space_map)
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


function reDoOneLocation(loc_land_init, selected_models, tem_helpers, loc_forcing, forcing_one_timestep)
    land_prec = SindbadTEM.definePrecomputeTEM(loc_land_init, getForcingForTimeStep(loc_forcing, 1), selected_models,
        tem_helpers)
    land = land_prec
    for ts = 1:tem_helpers.dates.size
        f = getForcingForTimeStep(loc_forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(land, f, selected_models, tem_helpers)
    end
    return land
end


site_location = loc_space_maps[1];
loc_forcing, loc_output, loc_obs =
    getLocDataObsN(output_array,
        forc, obs_array, site_location);

loc_space_ind = loc_space_inds[1];
loc_land_init = land_init_space[1];
loc_output = loc_outputs[1];
loc_forcing = loc_forcings[1];


@time big_land = SindbadTEM.coreEcosystem(
    forward,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    forcing_one_timestep);

function get_loc_loss(
    new_apps,
    loc_obs,
    loc_forcing,
    loc_land_init, # now fixed arguments
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    forcing_one_timestep)
    big_land = SindbadTEM.coreEcosystem(
        new_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        forcing_one_timestep)
    loss_vector = getLossVector(loc_obs, landWrapper(big_land), tem_optim)
    t_loss = combineLoss(loss_vector, Val{:sum}())
    return t_loss
end

function loc_loss(up_params, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    new_apps = Tuple(updateModelParametersType(tbl_params, forward, up_params))
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
    forcing_one_timestep
);

fdiff_grads(loc_loss, tbl_params.default, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)

@time fdiff_grads(loc_loss, tbl_params.default, forward, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)

#=
function get_loc_loss(
    updated_models,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    forcing_one_timestep)
    big_land = SindbadTEM.coreEcosystem(
        updated_models,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        forcing_one_timestep)
    loss_vector = getLossVector(loc_obs, landWrapper(big_land), tem_optim)
    t_loss = combineLoss(loss_vector, Val{:sum}())
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
    forcing_one_timestep)


function loc_loss(upVector, forward, kwargs...)
    updated_models = Tuple(updateModelParametersType(tbl_params, forward, upVector))
    return get_loc_loss(updated_models, kwargs...)
end

kwargs = (;
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    forcing_one_timestep
);

@time loc_loss(tbl_params.default, forward, kwargs...)

s_loc(x) = loc_loss(x, forward, kwargs...)

CHUNK_SIZE = 8
cfg = ForwardDiff.GradientConfig(s_loc, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());
$
@time grad = ForwardDiff.gradient(s_loc, p_vec, cfg) # cfg
=#
