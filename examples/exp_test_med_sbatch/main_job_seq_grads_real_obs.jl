
using Dates
println(now())

using SindbadData
using SindbadTEM
using SindbadML
using ForwardDiff
using PreallocationTools

using CairoMakie
using JLD2
using Dates

toggleStackTraceNT()
#include("gen_obs.jl");
#obs_synt_single, params_map = out_synt()

println(now())

#cov_sites = get_sites_cov()

ks = (:gpp, :nee, :reco, :transpiration, :evapotranspiration, :agb, :ndvi)
cbars = (:viridis, :seaborn_icefire_gradient, :batlow100, :inferno, :magma, :thermal, :fastie)
#obs_synt_single.ndvi
name_exp = "seq_grads_real_obs"
#path = dirname(Base.active_project())
path = joinpath("/Net/Groups/BGI/scratch/lalonso/SindbadRuns/", name_exp)
mkpath(path)

# mkpath(joinpath(path, "maps_local/"))

# for (i,k) in enumerate(ks)
#     data_sites = getproperty(obs_synt_single, k)
#     data_subset = data_sites(site = cov_sites)
#     ds_ar = data_subset |> Array
#     fig = Figure(; resolution = (2400,700))
#     ax = Axis(fig[1,1]; xlabel = "time", ylabel = "site")
#     obj = heatmap!(ax, ds_ar; colormap = cbars[i])
#     Colorbar(fig[1,2], obj)
#     fig
#     save(joinpath(path, "maps_local/variable_$(k).png"), fig)
# end

# let 
#     params_scaled = params_map |> Array
#     fig = Figure(; resolution = (2400,700))
#     ax = Axis(fig[1,1]; xlabel = "paramer", ylabel = "site")
#     obj = heatmap!(ax, params_scaled; colormap = :tab20c,
#         colorrange=(-1,20), highclip=:yellow, lowclip=:black,)
#     Colorbar(fig[1,2], obj)
#     fig
#     save(joinpath(path, "maps_local/parameters_map.png"), fig)
# end


#obs_synt = obs_synt_single

experiment_json = "../exp_test_med_sbatch/settings_test_med_sbatch/experiment.json"

info = getExperimentInfo(experiment_json);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

forc = (; Pair.(forcing.variables, forcing.data)...);
obs = (; Pair.(observations.variables, observations.data)...);

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
    getLocDataObsN(op.data, forc, obs, site_location); # obs_synt

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

# setLogLevel()
# setLogLevel(:debug)


cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
new_cost_options = Tuple(cost_options);

new_options = [(; cost_metric= new_cost_options[i].cost_metric,
    obs_ind = new_cost_options[i].obs_ind,
    mod_ind = new_cost_options[i].mod_ind,
    valids = new_cost_options[i].valids,
    cost_weight = new_cost_options[i].cost_weight) for i in eachindex(new_cost_options)]

constraint_method = info.optim.multi_constraint_method

getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem,
    loc_obs, cost_options, constraint_method)

#CHUNK_SIZE = 13;

models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

models = LongTuple(models...);

siteLossInner(
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

println("one gradient: ", now())

ForwardDiffGrads(
    siteLossInner,
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

println("one gradient, second run: ", now())

@time ForwardDiffGrads(
        siteLossInner,
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

# load available covariates
# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr"));
xfeatures = cube_to_KA(c)

sites = xfeatures.site
sites = [s for s ∈ sites]

# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)
sites_parameters = ml_baseline(xfeatures)
#params_bounded = getParamsAct.(sites_parameters, tbl_params)
cov_sites = xfeatures.site

#sites_parameters .= tbl_params.default
op = prepTEMOut(info, forcing.helpers);

xbatch = cov_sites

f_grads = SharedArray{Float32}(n_params, length(xbatch)) # zeros(Float32, n_params, length(xbatch))
x_feat = xfeatures(; site=xbatch) 

println("full batch gradient: ", now())

gradsBatch!(
    siteLossInner,
    f_grads,
    sites_parameters,
    models,
    xbatch,
    sites_f,
    op.data,
    forc,
    obs,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=true)

jldsave(joinpath(path, "test_gradients.jld2"); grads = f_grads)

# #isnan.(∇params) |> sum
# println("start training: ", now())

# history_loss_par = trainDistributed(
#     ml_baseline,
#     siteLossInner,
#     xfeatures,
#     models,
#     sites_f,
#     op.data,
#     forc,
#     obs_synt,
#     tbl_params, 
#     land_init_space,
#     forcing_one_timestep,
#     tem,
#     param_to_index,
#     cost_options,
#     constraint_method;
#     nepochs=10,
#     bs = 8,
#     local_root=path,
#     )

# println("end training: ", now())
