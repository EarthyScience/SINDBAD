using Sindbad, ForwardSindbad, OptimizeSindbad

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


tem_helpers = tem_vals.helpers;
tem_spinup = tem_vals.spinup;
tem_models = tem_vals.models;
tem_variables = tem_vals.variables;
tem_optim = info.optim;
out_variables = output.variables;
forward = tem_vals.models.forward;



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

# res_vec = Vector{typeof(loc_land_init)}(undef, info.tem.helpers.dates.size);
res_vec = Vector{typeof(loc_land_init)}(undef, info.tem.helpers.dates.size);
# res_vec = [loc_land_init for _ in info.tem.helpers.dates.vector];
@time big_land = ForwardSindbad.coreEcosystem(
    forward,
    res_vec,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    f_one);


function get_loc_loss(
    newApproaches,
    res_vec,
    new_land,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)

    big_land = ForwardSindbad.coreEcosystem(
        newApproaches,
        res_vec,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        new_land,
        f_one)
    # model_data = (; gpp = gpp)
    lossVec = getLossVectorArray(loc_obs, big_land, tem_optim)
    t_loss = combineLossArray(lossVec, tem_optim.multiConstraintMethod)
    return t_loss
end


get_loc_loss(
    forward,
    res_vec,
    loc_land_init,
    loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)

function loc_loss(upVector, forward, res_vec, loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init_a,
    f_one,
    upVectType
)
    newApproaches = Tuple(updateModelParametersType(tblParams, forward, upVector))
    if typeof(upVector) !== upVectType[1]
        @show "goingin", upVectType[1]
        upVectType[1] = typeof(upVector)
        @show "goingout", upVectType[1]
        new_land = reDoOneLocation(loc_land_init_a[1], newApproaches, tem_helpers, loc_forcing, f_one)
        loc_land_init_a[1] = new_land
        res_vec .= Vector{typeof(new_land)}(undef, tem_helpers.dates.size)
    end
    return get_loc_loss(newApproaches, res_vec, loc_land_init_a[1], loc_obs,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_optim,
        f_one)
end


upVectType = [typeof(tblParams.defaults)];
loc_land_init_a = [loc_land_init];
res_vec = Vector{Any}(undef, info.tem.helpers.dates.size);
loc_loss(ForwardDiff.Dual.(tblParams.defaults), forward, res_vec, loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init_a,
    f_one, upVectType)

using ForwardDiff

fg(x) = loc_loss(x, forward, res_vec, loc_obs,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    loc_land_init_a,
    f_one, upVectType)
@time grad = ForwardDiff.gradient(fg, tblParams.defaults)
