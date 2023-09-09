using Distributed
using SharedArrays
addprocs()

@everywhere begin
    using SindbadData
    using SindbadTEM
    using SindbadML
    using ForwardDiff
    using PreallocationTools
end


toggleStackTraceNT()
include("gen_obs.jl");

obs_synt_single = out_synt()

@everywhere obs_synt = $obs_synt_single

experiment_json = "../exp_medium/settings_medium/experiment.json"
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

println("Hola hola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

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


# ForwardDiff.gradient(f, x)
# load available covariates
# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr"));
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
# b_data = (; allocated_output = op.data, forcing=forc);

# data_optim = (;
#     obs = obs_synt,
# );
xbatch = cov_sites[1:8]

f_grads = SharedArray{Float32}(n_params, length(xbatch)) # zeros(Float32, n_params, length(xbatch))
x_feat = xfeatures(; site=xbatch) 

gradsBatchDistributed!(
    siteLossInner,
    f_grads,
    sites_parameters,
    models,
    xbatch,
    sites_f,
    op.data,
    forc,
    obs_synt,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=false)
    
#isnan.(∇params) |> sum
history_loss_seq = train(
    ml_baseline,
    siteLossInner,
    xfeatures[site=1:16],
    models,
    sites_f,
    op.data,
    forc,
    obs_synt,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    nepochs=3,
    bs = 4
    )

history_loss_par = trainDistributed(
    ml_baseline,
    siteLossInner,
    xfeatures[site=1:16],
    models,
    sites_f,
    op.data,
    forc,
    obs_synt,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    nepochs=3,
    bs = 4
    )
