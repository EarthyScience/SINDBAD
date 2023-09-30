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

land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = prepTEMOut(info, forcing.helpers);

run_helpers = prepTEM(forcing, info);

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

@everywhere begin
    inits_d = $inits
    data_d = $data
    tem_d = $tem
    data_optim_d = $data_optim
    optim_d = $optim
end

@time pixel_run!(inits_d, data_d, tem_d);


@time getSiteLossTEM(inits_d, data_d, data_optim_d, tem_d, optim_d)

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(SharedArray.(op.data), forc, obs_synt, site_location);

CHUNK_SIZE = 12;
data_cache = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
#    allocated_output = DiffCache.(loc_output, (CHUNK_SIZE,)),
    allocated_output = DiffCache.(loc_output)
);

@time siteLossInner(tbl_params.default, inits_d, data_cache, data_optim_d, tem_d, tbl_params, optim_d)

kwargs = (;
    inits_d, data_cache, data_optim_d, tem_d, tbl_params, optim_d
    );

@everywhere begin
    kwargs_d = $ kwargs
end
    
@time gradientSite(siteLossInner, tbl_params.default, kwargs...)

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

f_grads = SharedArray{Float32}(n_params, length(xbatch))

x_feat = xfeatures(; site=xbatch) 

gradsBatchDistributed!(
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


