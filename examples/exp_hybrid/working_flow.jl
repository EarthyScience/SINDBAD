
using Revise
using ForwardDiff

using Sindbad
using ForwardSindbad
using ForwardSindbad: timeLoopForward
using OptimizeSindbad
#using AxisKeys: KeyedArray as KA
#using Lux, Zygote, Optimisers, ComponentArrays, NNlib
#using Random
noStackTrace()
#Random.seed!(7)

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

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify info

info, forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
f_one = prepRunEcosystem(output, forc, info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time outcubes = runExperimentOpti(experiment_json);  
tblParams = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

# @time outcubes = runExperimentOpti(experiment_json);  
function og_loss(x,
    mods,
    forc,
    op,
    op_vars,
    obs,
    tblParams,
    info_tem,
    info_optim,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    l = getLossGradient(x,
        mods,
        forc,
        op,
        op_vars,
        obs,
        tblParams,
        info_tem,
        info_optim,
        loc_space_names,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    return l
end
rand_m = rand(info.tem.helpers.numbers.num_type);
op = setupOutput(info);

mods = info.tem.models.forward;
og_loss(tblParams.defaults,
    mods,
    forc,
    op,
    op.variables,
    obs,
    tblParams,
    info.tem,
    info.optim,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

function get_loc_loss(loc_obs,
    loc_output,
    newApproaches,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    loc_land_init,
    f_one)
    coreEcosystem!(loc_output,
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        Val(tem_variables),
        loc_land_init,
        f_one)
    @show out_variables
    model_data = (; Pair.(out_variables, loc_output)...)
    loss_vector = getLossVectorArray(loc_obs, model_data, tem_optim)
    @info "-------------------"
    l = combineLossArray(loss_vector, Val(tem_optim.multiConstraintMethod))
    return l
end
# loc_space_maps = Pair.([(loc_space_names, loc_space_inds)...])
site_location = loc_space_maps[1];
land_init_site = land_init_space[1];
loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location);
get_loc_loss(loc_obs,
    loc_output,
    mods,
    loc_forcing,
    info.tem.helpers,
    info.tem.spinup,
    info.tem.models,
    info.tem.variables,
    info.optim,
    output.variables,
    land_init_site,
    f_one)

for site ∈ 1:(info.tem.forcing.sizes.site)
    site_location = loc_space_maps[site]
    land_init_site = land_init_space[site]
    loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location)
    get_loc_loss(loc_obs,
        loc_output,
        mods,
        loc_forcing,
        info.tem.helpers,
        info.tem.spinup,
        info.tem.models,
        info.tem.variables,
        info.optim,
        output.variables,
        land_init_site,
        f_one)
end
