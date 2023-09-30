using Distributed
using SharedArrays
addprocs(9)

@everywhere begin
    using SindbadData
    using SindbadTEM
    using SindbadML
    using ForwardDiff
    using PreallocationTools
    using ProgressMeter
end
using PreallocationTools


toggleStackTraceNT()
include("gen_obs.jl")
obs_synt = out_synt();


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
    getLocDataObsN(op.data, forc, obs_synt, site_location); # obs_synt

land_init = land_init_space[site_location[1][2]];

data = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
    allocated_output = loc_output
);

models = info.tem.models.forward;
models = LongTuple(models...);

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

pixel_run!(inits, data, tem);

# @profview_allocs coreTEM!(inits..., data..., tem...)
@time coreTEM!(inits..., data..., tem...)

@time  getSiteLossTEM(inits, data, data_optim, tem, optim)

CHUNK_SIZE = 13;
data_cache = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
#    allocated_output = DiffCache.(loc_output, (CHUNK_SIZE,)),
    allocated_output = DiffCache.(loc_output)
);

models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

models = LongTuple(models...);

@time siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, param_to_index, optim)

kwargs = (;
    inits, data_cache, data_optim, tem, param_to_index, optim
    );
    
println("Hola hola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

@time gradientSite(siteLossInner, tbl_params.default, kwargs...)

# load available covariates

# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_covariates.zarr"));
xfeatures = cube_to_KA(c)

# RU-Ha1, IT-PT1, US-Me5
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

forcing_one_timestep =run_helpers.forcing_one_timestep

#sites_parameters .= tbl_params.default

op = prepTEMOut(info, forcing.helpers);

b_data = (; allocated_output = op.data, forcing=forc);

data_optim = (;
    obs = obs_synt,
);

xbatch = cov_sites[1:8]

f_grads = SharedArray{Float32}(n_params, length(xbatch))
x_feat = xfeatures(; site=xbatch) 

gradsBatchDistributed!(siteLossInner,
    f_grads,
    sites_parameters,
    models,
    xbatch,
    sites_f,
    b_data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=true
)

f_grads_seq = zeros(Float32, n_params, length(xbatch))
x_feat = xfeatures(; site=xbatch) 

gradientBatch!(
    siteLossInner,
    f_grads_seq,
    sites_parameters,
    models,
    xbatch,
    sites_f,
    b_data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=true)


