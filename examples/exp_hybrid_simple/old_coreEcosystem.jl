using Sindbad, ForwardSindbad, OptimizeSindbad
using ForwardDiff


experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);
info, forcing = getForcing(info, Val{:zarr}());
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
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
tem_vals,
f_one = prepRunEcosystem(output,
    forc,
    info.tem);


# @profview runEcosystem!(output.data,
#     info.tem.models.forward,
#     forc,
#     tem_vals,
#     loc_space_inds,
#     loc_forcings,
#     loc_outputs,
#     land_init_space,
#     f_one)

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)


tem_helpers = tem_vals.helpers;
tem_spinup = tem_vals.spinup;
tem_models = tem_vals.models;
tem_variables = tem_vals.variables;
tem_optim = info.optim;
out_variables = output.variables;
forward = tem_vals.models.forward;


getLossGradient(tblParams.defaults,
    forward,
    forc,
    output,
    obs,
    tblParams,
    tem_vals,
    tem_optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)


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


function reDoOneLocation1(loc_land_init, approaches, tem_helpers, loc_forcing, f_one)
    land = ForwardSindbad.runDefine!(loc_land_init, getForcingForTimeStep(loc_forcing, 1), approaches,
        tem_helpers)
    land = runModels!(land, f_one, approaches, tem_helpers)
    return land
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
# res_vec = SVector{typeof(land_init_space[1])}[land_init_space[1] for _ in info.tem.helpers.dates.vector];
# res_vec = [land_init_space[1] for _ in info.tem.helpers.dates.vector];
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
    newApproaches,
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
        newApproaches,
        res_vec,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        f_one)
    # model_data = (; gpp = gpp)
    lossVec = getLossVectorArray(loc_obs, landWrapper(big_land), tem_optim)
    t_loss = combineLossArray(lossVec, Val{:sum}())
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
    newApproaches = Tuple(updateModelParametersType(tblParams, forward, upVector))
    return get_loc_loss(newApproaches, kwargs...)
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

loc_loss(tblParams.defaults, forward, kwargs...)


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

p_vec = tblParams.defaults;
l1(p_vec)
# CHUNK_SIZE = length(p_vec)
CHUNK_SIZE = 8
cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());


gradDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_vals.helpers.numbers.num_type},tem_vals.helpers.numbers.num_type,CHUNK_SIZE}.(tblParams.defaults);
mods = Tuple(updateModelParametersType(tblParams, forward, gradDefs));
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

@time ForwardSindbad.coreEcosystem(
    mods,
    res_vec,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);

