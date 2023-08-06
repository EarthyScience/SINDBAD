using Sindbad, ForwardSindbad, OptimizeSindbad
using ForwardDiff


experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);
forcing = getForcing(info);
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);

observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArrayWithNames(observations);
obsv = getKeyedArray(observations);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters)

loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepRunEcosystem(forcing, info);


# @profview runEcosystem!(output_array,
#     info.tem.models.forward,
#     forc,
#     tem_with_vals,
#     loc_space_inds,
#     loc_forcings,
#     loc_outputs,
#     land_init_space,
#     f_one)

@time runEcosystem!(output_array,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)


tem_helpers = tem_with_vals.helpers;
tem_spinup = tem_with_vals.spinup;
tem_models = tem_with_vals.models;
tem_variables = tem_with_vals.variables;
tem_optim = info.optim;
forward = tem_with_vals.models.forward;


getLoss(tbl_params.default,
    forward,
    forc,
    output,
    obs_array,
    tbl_params,
    tem_with_vals,
    tem_optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)


function getLocDataObsN(outcubes, forcing, obs_array, loc_space_map)
    loc_forcing = map(forcing) do a
        view(a; loc_space_map...)
    end
    loc_obs = map(obs) do a
        view(a; loc_space_map...)
    end
    ar_inds = last.(loc_space_map)

    loc_output = map(outcubes) do a
        getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output, loc_obs
end


function reDoOneLocation1(loc_land_init, selected_models, tem_helpers, loc_forcing, f_one)
    land = ForwardSindbad.runDefinePrecompute(loc_land_init, getForcingForTimeStep(loc_forcing, 1), selected_models,
        tem_helpers)
    land = runCompute(land, f_one, selected_models, tem_helpers)
    return land
end

function reDoOneLocation(loc_land_init, selected_models, tem_helpers, loc_forcing, f_one)
    land_prec = ForwardSindbad.runDefinePrecompute(loc_land_init, getForcingForTimeStep(loc_forcing, 1), selected_models,
        tem_helpers)
    land = land_prec
    for ts = 1:tem_helpers.dates.size
        f = getForcingForTimeStep(loc_forcing, tem_helpers.vals.forc_vars, ts, f_one)
        land = runCompute(land, f, selected_models, tem_helpers)
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

res_out = ForwardSindbad.coreEcosystem(
    forward,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);

@time ForwardSindbad.coreEcosystem(
    forward,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);


# res_vec = Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size);
res_vec = Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size);
# res_vec = Vector{Any}(undef, info.tem.helpers.dates.size);
# res_vec = SVector{typeof(land_init_space[1])}[land_init_space[1] for _ in info.tem.helpers.dates.range];
# res_vec = [land_init_space[1] for _ in info.tem.helpers.dates.range];
@time big_land = ForwardSindbad.coreEcosystem(
    forward,
    res_vec,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);

@time big_land = ForwardSindbad.coreEcosystem(
    forward,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);

function get_loc_loss(
    updated_models,
    res_vec,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    f_one)
    big_land = ForwardSindbad.coreEcosystem(
        updated_models,
        res_vec,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        f_one)

    lossVec = getLossVector(loc_obs, landWrapper(big_land), tem_optim)
    t_loss = combineLoss(lossVec, Val{:sum}())
    return t_loss
end

get_loc_loss(
    forward,
    res_vec,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    f_one)


function loc_loss(upVector, forward, kwargs...)
    updated_models = Tuple(updateModelParametersType(tbl_params, forward, upVector))
    return get_loc_loss(updated_models, kwargs...)
end

kwargs = (;
    res_vec,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init,
    f_one
);

loc_loss(tbl_params.default, forward, kwargs...)


function l1(p)
    return loc_loss(p,
        forward,
        res_vec,
        loc_obs,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_optim,
        loc_land_init,
        f_one)
end

p_vec = tbl_params.default;
l1(p_vec)
# CHUNK_SIZE = length(p_vec)
CHUNK_SIZE = 8
cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());


gradDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
mods = Tuple(updateModelParametersType(tbl_params, forward, gradDefs));
dual_land = reDoOneLocation1(loc_land_init, mods, tem_helpers, loc_forcing, f_one);

# @time big_land = ForwardSindbad.coreEcosystem(
#     mods,
#     loc_forcing,
#     tem_helpers,
#     tem_spinup,
#     tem_models,
#     loc_land_init,
#     f_one);

res_vec = Vector{typeof(dual_land)}(undef, info.tem.helpers.dates.size);

@time grad = ForwardDiff.gradient(l1, p_vec, cfg)

