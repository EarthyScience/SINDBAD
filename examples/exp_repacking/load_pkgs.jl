using SindbadData
using SindbadTEM
using YAXArrays
using SindbadML
using SindbadVisuals
using ForwardDiff
using PreallocationTools
using GLMakie

toggleStackTraceNT()
# include("gen_obs.jl")
# obs_synt = out_synt();


experiment_json = "../exp_repacking/settings_repacking/experiment.json"
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

data = (;
    forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
    allocated_output = run_helpers.output_array
    );
loc_space_maps = run_helpers.loc_space_maps;
land_init_space = run_helpers.land_init_space;

site_location = loc_space_maps[3]    
loc_land_init = land_init_space[3];

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(op.data, forc, obs, site_location); # obs_synt

land_init = land_init_space[site_location[1][2]];

data = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
    allocated_output = loc_output
);

models = info.tem.models.forward;
#models = [m for m in models];
models = LongTuple(models...);


inits = (;
    selected_models = models,
    land_init
);

loc_obs_2 = [loc_obs[i] for i in eachindex(loc_obs)]

data_optim = (;
    site_obs = loc_obs,
);


cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
new_cost_options = Tuple(cost_options);

new_options = Tuple([(; cost_metric= new_cost_options[i].cost_metric, obs_ind = new_cost_options[i].obs_ind, mod_ind = new_cost_options[i].mod_ind, valids = new_cost_options[i].valids, cost_weight = new_cost_options[i].cost_weight)
    for i in eachindex(new_cost_options)])

optim = (;
    cost_options= new_options,
    multiconstraint_method = info.optim.multi_constraint_method
);

# function get_metric_debug(cost_option)
#     return getfield(cost_option, :cost_metric)
# end

# @code_warntype get_metric_debug(new_options[1])


pixel_run!(inits, data, tem);

@time pixel_run!(inits, data, tem);

@time coreTEM!(inits..., data..., tem...)

@code_warntype coreTEM!(inits..., data..., tem...)
# # setLogLevel()
# # setLogLevel(:debug)

# #lines(data.allocated_output[1][:,1])


# # type unstable 
# # land_spin
# # loss_vector

@time getSiteLossTEM(inits, data, data_optim, tem, optim)


@code_warntype getSiteLossTEM(inits, data, data_optim, tem, optim)

# cost_option = new_options[1];

# _lossMetric = SindbadTEM.SindbadSetup.SindbadMetrics.get_metric(cost_option) #cost_option.cost_metric # bad
# _obs_ind = cost_option.obs_ind
# _mod_ind = cost_option.mod_ind
# _valids = cost_option.valids
# _weight = cost_option.cost_weight

# function innner_loss2(_lossMetric, _obs_ind, _mod_ind, _valids, _weight, model_output, observations)
#     ŷ = model_output[_mod_ind]
#     #if size(ŷ, 2) == 1
#     ŷ = getModelOutputView(ŷ)
#     #end
#     y = observations[_obs_ind]
#     yσ = observations[_obs_ind+1]
#     (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ, _valids)
#     #@code_warntype loss(y, yσ, ŷ, _lossMetric)
#     metr = loss(y, yσ, ŷ, _lossMetric) # * _weight
#     if isnan(metr)
#         metr = oftype(metr, 1e19)
#     end
#     return metr
# end

# function get_valids(y, _valids)
#     return y[_valids]
# end

# function base_ys(observations, _obs_ind)
#     y = observations[_obs_ind]
#     return y
# end

# function apply_valids(y, _valids)
#     return y[_valids]
# end

# function combo_base(observations, _obs_ind, _valids)
#     y_new = apply_valids(observations[_obs_ind], _valids)
#     return y_new
# end


# @code_warntype apply_valids(loc_obs[_obs_ind], _valids)

# @code_warntype combo_base(loc_obss, _obs_ind, _valids)

# @code_warntype select_ar(loc_obs_2, indx, _valids)

# innner_loss2(_lossMetric, _obs_ind, _mod_ind, _valids, _weight, loc_output, loc_obs)

# @code_warntype innner_loss2(_lossMetric, _obs_ind, _mod_ind, _valids, _weight, loc_output, loc_obs)


# function get_ŷ2(model_output, _mod_ind)
#     ŷ = model_output[_mod_ind]
#     if size(ŷ, 2) == 1
#         ŷ_new = getModelOutputView(ŷ)
#     end
#     return ŷ_new
# end

# @inline function get_ŷ4(ŷ)
#     if size(ŷ, 2) == 1
#         return @view ŷ[:,1]
#     else
#         return ŷ
#     end
# end

# @code_warntype get_ŷ2(loc_output, _mod_ind)

# @code_warntype get_ŷ4(loc_output[_mod_ind])


# @code_warntype getModelOutputView(loc_output[1])

# getModelOutputView(loc_output[1])

# tw = loc_output[1]
# @view tw[:,1]

CHUNK_SIZE = 12;
data_cache = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
#    allocated_output = DiffCache.(loc_output, (CHUNK_SIZE,)),
    allocated_output = DiffCache.(loc_output)
);
models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

@time siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, param_to_index, optim);

siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, param_to_index, optim)

#siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, param_to_index, optim)

kwargs = (;
    inits, data_cache, data_optim, tem, param_to_index, optim
    );
    
println("Hola hola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

@time ForwardDiffGrads(siteLossInner, tbl_params.default, kwargs...)

@time ForwardDiffGrads(siteLossInner, tbl_params.default, kwargs...)

# ForwardDiff.gradient(f, x)

# load available covariates

# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr"));
xfeatures = cube_to_KA(c)

# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]
nogood = [
    "AR-SLu",
    "CA-Obs",
    "DE-Lkb",
    "SJ-Blv",
    "US-ORv"];
sites = setdiff(sites, nogood)

# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)
sites_parameters = ml_baseline(xfeatures)
#params_bounded = getParamsAct.(sites_parameters, tbl_params)
cov_sites = xfeatures.site

forcing_one_timestep =run_helpers.forcing_one_timestep

#sites_parameters .= tbl_params.default

op = prepTEMOut(info, forcing.helpers);

b_data = (; allocated_output = op.data, forcing=forc);

data_optim = (;
    obs = obs_synt,
);

xbatch = cov_sites[1:4]

f_grads = zeros(Float32, n_params, length(xbatch))
x_feat = xfeatures(; site=xbatch) 

gradsBatch!(
    siteLossInner,
    f_grads,
    sites_parameters,
    info.tem.models.forward,
    xbatch,
    sites_f,
    b_data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    optim;
    logging=true)


#sites = xfeatures.site
flat, re, opt_state = destructureNN(ml_baseline)
n_params = length(ml_baseline[end].bias)

∇params =  get∇params(siteLossInner,
    xfeatures,
    n_params,
    re,
    flat,
    info.tem.models.forward,
    xbatch,
    sites_f,
    b_data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    optim;
    logging=true);
    
#isnan.(∇params) |> sum

history_loss = train(
    ml_baseline,
    siteLossInner,
    xfeatures,
    info.tem.models.forward,
    sites_f,
    b_data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    optim;
    nepochs=10,
    bs = 8,
    );


# new_params = getParamsAct(up_params(; site=site_name), tbl_params)

# space_run!(
#     info.tem.models.forward,
#     sites_parameters,
#     tbl_params,
#     sites_f,
#     land_init_space,
#     b_data,
#     cov_sites,
#     forcing_one_timestep,
#     tem
# )


# tempo = string.(forc.Tair.time);
# out_names = info.optimization.observational_constraints
# plot_output(op, obs, out_names, cov_sites, sites_f, tempo)

