# dev ../.. ../../lib/SindbadUtils/ ../../lib/SindbadData/ ../../lib/SindbadMetrics/ ../../lib/SindbadSetup/ ../../lib/SindbadTEM ../../lib/SindbadML
using SindbadData
using SindbadTEM
using YAXArrays
using SindbadML
#using SindbadVisuals
using ForwardDiff
using PreallocationTools
#using CairoMakie

toggleStackTraceNT()
include("gen_obs.jl")

obs_synt, params_map = out_synt();

# cov_sites = get_sites_cov()
# ks = (:gpp, :transpiration, :evapotranspiration)
# cbars = (:viridis, :inferno, :magma)

# path = dirname(Base.active_project())

# for (i,k) in enumerate(ks)
#     data_sites = getproperty(obs_synt, k)
#     data_subset = data_sites(site = cov_sites)
#     ds_ar = data_subset |> Array
#     fig = Figure(; resolution = (2400,700))
#     ax = Axis(fig[1,1]; xlabel = "time", ylabel = "site")
#     obj = heatmap!(ax, ds_ar; colormap = cbars[i])
#     Colorbar(fig[1,2], obj)
#     fig
#     save(joinpath(path, "maps_synt/variable_$(k).png"), fig)
# end

# let 
#     params_scaled = params_map |> Array
#     fig = Figure(; resolution = (2400,700))
#     ax = Axis(fig[1,1]; xlabel = "paramer", ylabel = "site")
#     obj = heatmap!(ax, params_scaled; colormap = :tab20c,
#         colorrange=(-1,20), highclip=:yellow, lowclip=:black,)
#     Colorbar(fig[1,2], obj)
#     fig
#     save(joinpath(path, "maps_synt/parameters_map.png"), fig)
# end


experiment_json = "../exp_medium_reverse/settings_medium_reverse/experiment.json"
#info = getConfiguration(experiment_json);
#info = setupInfo(info);

info = getExperimentInfo(experiment_json);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

forc = (; Pair.(forcing.variables, forcing.data)...);
obs = (; Pair.(observations.variables, observations.data)...);

#obs_array = getKeyedArrayWithNames(observations);
#obsv = getKeyedArray(observations);

land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);


op = prepTEMOut(info, forcing.helpers);

run_helpers = prepTEM(forcing, info);

land_init_space = run_helpers.land_init_space;
tem_with_types = run_helpers.tem_with_types;

tem = (;
    tem_helpers = tem_with_types.helpers,
    tem_models = tem_with_types.models,
    tem_spinup = tem_with_types.spinup,
    tem_run_spinup = tem_with_types.helpers.run.spinup.spinup_TEM,
);

loc_space_maps = run_helpers.loc_space_maps;
land_init_space = run_helpers.land_init_space;

site_location = loc_space_maps[3]    
loc_land_init = land_init_space[3];

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(op.data, forc, obs_synt, site_location); # obs_synt

land_init = land_init_space[site_location[1][2]];
forcing_one_timestep =run_helpers.forcing_one_timestep;

models = info.tem.models.forward;
models = LongTuple(models...);

coreTEM!(
        models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem...)

# @profview_allocs coreTEM!(inits..., data..., tem...)

@time coreTEM!(
    models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem...)

@code_warntype coreTEM!(
    models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem...)

# setLogLevel()
# setLogLevel(:debug)


cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
new_cost_options = Tuple(cost_options);

new_options = [(; cost_metric= new_cost_options[i].cost_metric,
    obs_ind = new_cost_options[i].obs_ind,
    mod_ind = new_cost_options[i].mod_ind,
    valids = new_cost_options[i].valids,
    cost_weight = new_cost_options[i].cost_weight) for i in eachindex(new_cost_options)]

#cost_options= cost_options
constraint_method = info.optim.multi_constraint_method

@time  getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem,
    loc_obs, cost_options, constraint_method)

@code_warntype getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem,
    loc_obs, cost_options, constraint_method)


#CHUNK_SIZE = 13;

models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

models = LongTuple(models...);

@time siteLossInner(
    tbl_params.default,
    models,
    loc_forcing,
    forcing_one_timestep,
    DiffCache.(loc_output),
    land_init,
    tem,
    param_to_index,
    loc_obs,
    cost_options,
    constraint_method
    )

@code_warntype siteLossInner(
    tbl_params.default,
    models,
    loc_forcing,
    forcing_one_timestep,
    DiffCache.(loc_output),
    land_init,
    tem,
    param_to_index,
    loc_obs,
    cost_options,
    constraint_method
    )
    
println("Hola hola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

using TaylorDiff
#using ReverseDiff: GradientTape, GradientConfig, gradient, gradient!, compile, DiffResults

f(x) = siteLossInner(x, models,
    loc_forcing,
    forcing_one_timestep,
    DiffCache.(loc_output),
    land_init,
    tem,
    param_to_index,
    loc_obs,
    cost_options,
    constraint_method
    )