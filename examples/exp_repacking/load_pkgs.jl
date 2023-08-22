using SindbadData
using SindbadTEM
using YAXArrays
using HybridSindbad
using SindbadVisuals
using ForwardDiff
using PreallocationTools
using GLMakie

toggleStackTraceNT()
include("gen_obs.jl")
obs_synt = out_synt()

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

# @time runTEM!(info.tem.models.forward,
#     run_helpers.forcing_nt_array,
#     run_helpers.loc_forcings,
#     run_helpers.forcing_one_timestep,
#     run_helpers.output_array,
#     run_helpers.loc_outputs,
#     run_helpers.land_init_space,
#     run_helpers.loc_space_inds,
#     run_helpers.tem_with_types)


# o1 = run_helpers.output_array[1];
# out1 = reshape(o1, (:, size(o1,3)))
# heatmap(out1)

# lines(out1[:,2])

# notvalid = [sum(isnan.(out1[:,i])) for i in 1:205]
# rmindxs = findall(x->x>size(out1, 1)-2, notvalid)
# forc.Tair.site[rmindxs]
# # do not include
# nogood = [
#     "AR-SLu",
#     "CA-Obs",
#     "DE-Lkb",
#     "SJ-Blv",
#     "US-ORv"];

# #heatmap(out1)
# lines(forc.VPD(site = "CA-Obs"))
# forc.SILT(site = "CA-Obs")

# forc.VPD(site = "CA-Obs")


# argsTEM = (;
#      forcing_nt_array = run_helpers.forcing_nt_array,
#      loc_forcings = run_helpers.loc_forcing,
#      forcing_one_timestep = run_helpers.forcing_one_timestep,
#      output_array = run_helpers.output_array,
#      loc_outputs = run_helpers.loc_outputs,
#      land_init_space = run_helpers.land_init_space,
#      loc_space_inds = run_helpers.loc_space_inds,
#      tem_with_types = run_helpers.tem_with_types
#  );

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
    getLocDataObsN(op.data, forc, obs_synt, site_location);

land_init = land_init_space[site_location[1][2]];

data = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
    allocated_output = loc_output
);

inits = (;
    selected_models = info.tem.models.forward,
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

#lines(data.allocated_output[1][:,1])

@time getSiteLossTEM(inits, data, data_optim, tem, optim)

CHUNK_SIZE = 12;
data_cache = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
#    allocated_output = DiffCache.(loc_output, (CHUNK_SIZE,)),
    allocated_output = DiffCache.(loc_output)
);

@time siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, tbl_params, optim)

kwargs = (;
    inits, data_cache, data_optim, tem, tbl_params, optim
    );
    
@time ForwardDiffGrads(siteLossInner, tbl_params.default, kwargs...)

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
    xfeatures[site=1:8],
    info.tem.models.forward,
    sites_f,
    b_data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    optim
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