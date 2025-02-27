using SindbadData
using SindbadData.DimensionalData
using SindbadData.AxisKeys
using SindbadData.YAXArrays

using SindbadTEM
using SindbadML
using ProgressMeter
include("load_covariates.jl")

experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"
# for remote node
replace_info = Dict()
if Sys.islinux()
    replace_info = Dict(
        "forcing.default_forcing.data_path" => "/Net/Groups/BGI/work_4/scratch/lalonso/FLUXNET_v2023_12_1D.zarr",
        "optimization.observations.default_observation.data_path" =>"/Net/Groups/BGI/work_4/scratch/lalonso/FLUXNET_v2023_12_1D.zarr"
        );
end

info = getExperimentInfo(experiment_json; replace_info=replace_info);
selected_models = info.models.forward

tbl_params = getParameters(
    selected_models,
    info.optimization.model_parameter_default,
    info.optimization.model_parameters_to_optimize,
    info.helpers.numbers.num_type,
    info.helpers.dates.temporal_resolution);

param_to_index = getParameterIndices(selected_models, tbl_params);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
run_helpers = prepTEM(selected_models, forcing, observations, info);
sites_forcing = forcing.data[1].site; # sites names

# ? all spaces
space_forcing = run_helpers.space_forcing;
space_observations = run_helpers.space_observation;
space_output = run_helpers.space_output;
space_spinup_forcing = run_helpers.space_spinup_forcing;
space_ind = run_helpers.space_ind;
# ? land_init and helpers
land_init = run_helpers.loc_land;
tem = (;
    tem_info = run_helpers.tem_info,
    tem_run_spinup = run_helpers.tem_info.run.spinup_TEM,
);
loc_forcing_t = run_helpers.loc_forcing_t;

# ? do one site
# site specific variables
site_location = space_ind[1][1];
loc_forcing = space_forcing[site_location];
loc_obs = space_observations[site_location];
loc_output = space_output[site_location];
loc_spinup_forcing = space_spinup_forcing[site_location];
# run the model
@time coreTEM!(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem...)

# ? optimization
# costs related
cost_options = [prepCostOptions(loc_obs, info.optimization.cost_options) for loc_obs in space_observations];
constraint_method = info.optimization.multi_constraint_method;

# ? load available covariates
xfeatures = loadCovariates(sites_forcing; kind="all")
nor_names_order = xfeatures.features
n_features = length(nor_names_order)

# ? initial neural network
n_neurons = 32;
n_params = sum(tbl_params.is_ml);
batch_seed = 123;
mlBaseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=2, seed=batch_seed * 2);
parameters_sites = mlBaseline(xfeatures);

## test for gradients in batch
sites_common = xfeatures.site.data
sites_training = shuffleList(sites_common; seed=batch_seed)
indices_sites_training = siteNameToID.(sites_training, Ref(sites_forcing));

grads_batch = zeros(Float32, n_params, length(sites_training));
sites_batch = sites_training;#[1:n_sites_train];
indices_sites_batch = indices_sites_training;
params_batch = parameters_sites(; site=sites_batch);
scaled_params_batch = getParamsAct(params_batch, tbl_params);

# TODO: debug and benchmark again, one site!
tem_info = run_helpers.tem_info;
tem_run_spinup = run_helpers.tem_info.run.spinup_TEM;

input_args = (
    scaled_params_batch,
    selected_models,
    space_forcing,
    space_spinup_forcing,
    loc_forcing_t,
    space_output,
    land_init,
    tem_info,
    tem_run_spinup,
    param_to_index,
    space_observations,
    cost_options,
    constraint_method,
    indices_sites_batch,
    sites_batch
);

grads_lib = ForwardDiffGrad();
loc_params, inner_args = getInnerArgs(1, grads_lib, input_args...);

@time gg = gradientPolyester(grads_lib, loc_params, 2, lossSite, inner_args...)


# ! full training
# get site splits

# train_split = 0.82;
# valid_split = 0.1;
# batch_size = 32;
# shuffle_opt = true;
# batch_size = min(batch_size, trunc(Int, 1/3*length(sites_common)));


# n_sites = length(sites_common);
# n_batches = trunc(Int, n_sites * train_split/batch_size);
# n_sites_train = n_batches * batch_size;
# n_sites_valid = trunc(Int, n_sites * valid_split);
# n_sites_test = n_sites - n_sites_valid - n_sites_train;

# # filter and shuffle sites and subset
# all_sites = shuffleList(sites_common; seed=batch_seed)
# sites_training = all_sites[1:n_sites_train];
# indices_sites_training = siteNameToID.(sites_training, Ref(sites_forcing));

# # TODO: validation and testing
# # ? validation
# nfsvalid = all_sites[n_sites_train+1:n_sites_train+n_sites_valid]
# sites_validation = shuffleList(nfsvalid; seed=batch_seed);
# indices_sites_validation = siteNameToID.(sites_validation, Ref(sites_forcing));

# # ? test
# nfstest =  all_sites[n_sites_train+n_sites_valid+1:end]
# sites_testing = shuffleList(nfstest; seed=batch_seed);
# indices_sites_testing = siteNameToID.(sites_testing, Ref(sites_forcing));
