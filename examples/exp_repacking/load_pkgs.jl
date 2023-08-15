using SindbadData
using SindbadTEM
using YAXArrays
using HybridSindbad
using SindbadVisuals
using ForwardDiff
using PreallocationTools

experiment_json = "../exp_repacking/settings_repacking/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

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

forcing_nt_array,
loc_forcings,
forcing_one_timestep,
output_array,
loc_outputs,
land_init_space,
loc_space_inds,
loc_space_maps,
loc_space_names,
tem_with_types = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_types)

tem = (;
    tem_helpers = tem_with_types.helpers,
    tem_models = tem_with_types.models,
    tem_spinup = tem_with_types.spinup,
    tem_run_spinup = tem_with_types.helpers.run.spinup.spinup_TEM,
);

data = (;
    forcing,
    forcing_one_timestep,
    allocated_output = output_array
    );

site_location = loc_space_maps[1]    
loc_land_init = land_init_space[1];

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(op.data, forc, obs, site_location);

land_init = land_init_space[site_location[1][2]];

data = (;
    loc_forcing,
    forcing_one_timestep,
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

@time getSiteLossTEM(inits, data, data_optim, tem, optim)

data_cache = (;
    loc_forcing,
    forcing_one_timestep,
    allocated_output = DiffCache.(loc_output)
);

@time siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, tbl_params, optim)

kwargs = (;
    inits, data_cache, data_optim, tem, tbl_params, optim
    );
    
ForwardDiffGrads(siteLossInner, tbl_params.default, kwargs...)


b_data = (; allocated_output = op.data, forc, obs);

# load available covariates

# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr"));
xfeatures = cube_to_KA(c)

# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]
sites = setdiff!(sites, ["AR-SLu"])

# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)
sites_parameters = ml_baseline(xfeatures)
#params_bounded = getParamsAct.(sites_parameters, tbl_params)
cov_sites = xfeatures.site
cov_sites = setdiff!(cov_sites, ["AR-SLiu"])

space_run!(
    info.tem.models.forward,
    sites_parameters,
    tbl_params,
    sites_f,
    land_init_space,
    b_data,
    cov_sites,
    forcing_one_timestep,
    tem
)


# tempo = string.(forc.Tair.time);
# out_names = info.optimization.observational_constraints
# plot_output(op, obs, out_names, cov_sites, sites_f, tempo)




# optim



# optim = (;
#     cost_options,
#     multiconstraint_method
# )