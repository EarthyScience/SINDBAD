using SindbadData
using SindbadTEM
using YAXArrays
using HybridSindbad
using SindbadVisuals
using ForwardDiff
using PreallocationTools
using GLMakie

toggleStackTraceNT()
# include("gen_obs.jl")
# obs_synt = out_synt();


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

inits = (;
    selected_models = models,
    land_init
);

data_optim = (;
    site_obs = loc_obs,
);


cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
optim = (;
    cost_options= cost_options,
    multiconstraint_method = info.optim.multi_constraint_method
);

@time pixel_run!(inits, data, tem);

@time coreTEM!(inits..., data..., tem...)

#@code_warntype coreTEM!(inits..., data..., tem...)
# setLogLevel()
# setLogLevel(:debug)

#lines(data.allocated_output[1][:,1])


# type unstable 
# land_spin
# loss_vector

@time getSiteLossTEM(inits, data, data_optim, tem, optim)

CHUNK_SIZE = 13;
data_cache = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
#    allocated_output = DiffCache.(loc_output, (CHUNK_SIZE,)),
    allocated_output = DiffCache.(loc_output)
);

param_to_index = param_indices(models, tbl_params)

@time siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, param_to_index, optim);

#siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, param_to_index, optim)

kwargs = (;
    inits, data_cache, data_optim, tem, param_to_index, optim
    );
    
println("Hola hola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

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