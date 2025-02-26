using SindbadData
using SindbadData.DimensionalData
using SindbadData.AxisKeys
using SindbadData.YAXArrays

using SindbadTEM
using SindbadML
using ProgressMeter

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

tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
selected_models = info.models.forward
param_to_index = getParameterIndices(selected_models, tbl_params);
run_helpers = prepTEM(selected_models, forcing, observations, info);


loc_forcing_t = run_helpers.loc_forcing_t;
land_init = run_helpers.loc_land;
tem = (;
    tem_info = run_helpers.tem_info,
    tem_run_spinup = run_helpers.tem_info.run.spinup_TEM,
);

tem_info = run_helpers.tem_info
tem_run_spinup = run_helpers.tem_info.run.spinup_TEM

# site specific variables
space_forcing = run_helpers.space_forcing;
loc_observations = run_helpers.space_observation;
space_output = run_helpers.space_output;
space_spinup_forcing = run_helpers.space_spinup_forcing;
space_ind = run_helpers.space_ind;
site_location = space_ind[1][1];
loc_forcing = space_forcing[site_location];

loc_obs = loc_observations[site_location];

loc_output = space_output[site_location];
loc_spinup_forcing = space_spinup_forcing[site_location];

# run the model
@time coreTEM!(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem...)

# cost related
cost_options = [prepCostOptions(loc_obs, info.optimization.cost_options) for loc_obs in loc_observations];

constraint_method = info.optimization.multi_constraint_method;

# load available covariates
sites_forcing = forcing.data[1].site;

# c_read = Cube("/Net/Groups/BGI/work_5/scratch/lalonso/CovariatesFLUXNET_3.zarr");
c_read = Cube("examples/data/CovariatesFLUXNET_3.zarr");
# select features
# do first only nor
only_nor = occursin.(r"nor", c_read.features)
nor_sel = c_read.features[only_nor].val
nor_sel = [string.(s) for s in nor_sel] |> sort

# remove sites (with NaNs and duplicates)
to_remove = [
    "CA-NS3",
    # "CA-NS4",
    "IT-CA1",
    # "IT-CA2",
    "IT-SR2",
    # "IT-SRo",
    "US-ARb",
    # "US-ARc",
    "US-GBT",
    # "US-GLE",
    "US-Tw1",
    # "US-Tw2"
    ]
not_these = ["RU-Tks", "US-Atq", "US-UMd"]
not_these = vcat(not_these, to_remove)
new_sites = setdiff(c_read.site, not_these)

old_c = c_read[features = At(nor_sel)]

xfeat_all = yaxCubeToKeyedArray(old_c);
kg_data = c_read[features=At("KG")][:].data
oneHot_KG = lcKAoneHotbatch(kg_data, 32, "KG", string.(c_read.site))

pft_data = c_read[features=At("PFT")][:].data
oneHot_pft = lcKAoneHotbatch(pft_data, 17, "PFT", string.(c_read.site))

oneHot_veg = vegKAoneHotbatch(pft_data, string.(c_read.site))

stackedFeatures = reduce(vcat, [oneHot_KG, oneHot_pft, xfeat_all])
# stackedFeatures = reduce(vcat, [oneHot_KG, oneHot_pft, xfeat_all])
stackedFeatures = stackedFeatures(; site=new_sites)

sites_feature_all = [s for s in stackedFeatures.site];

sites_common_all = intersect(sites_feature_all, sites_forcing);

test_grads = 32;
test_grads = 0;
if test_grads !== 0
    sites_common = sites_common_all[1:test_grads];
else
    sites_common = sites_common_all;
end;

xfeatures = Float32.(stackedFeatures(; site=sites_common));
n_features = length(xfeatures.features);

# get site splits 
train_split = 0.82;
valid_split = 0.1;
batch_size = 32;
batch_size = min(batch_size, trunc(Int, 1/3*length(sites_common)));
batch_seed = 123;


n_sites = length(sites_common);
n_batches = trunc(Int, n_sites * train_split/batch_size);
n_sites_train = n_batches * batch_size;
n_sites_valid = trunc(Int, n_sites * valid_split);
n_sites_test = n_sites - n_sites_valid - n_sites_train;

# filter and shuffle sites and subset
all_sites = shuffleList(sites_common; seed=batch_seed)
sites_training = all_sites[1:n_sites_train];
indices_sites_training = siteNameToID.(sites_training, Ref(sites_forcing));

# TODO: validation and testing
# ? validation
nfsvalid = all_sites[n_sites_train+1:n_sites_train+n_sites_valid]
sites_validation = shuffleList(nfsvalid; seed=batch_seed);
indices_sites_validation = siteNameToID.(sites_validation, Ref(sites_forcing));

# ? test
nfstest =  all_sites[n_sites_train+n_sites_valid+1:end]
sites_testing = shuffleList(nfstest; seed=batch_seed);
indices_sites_testing = siteNameToID.(sites_testing, Ref(sites_forcing));

# NN 
n_epochs = 1;
n_neurons = 32;
n_params = sum(tbl_params.is_ml);
shuffle_opt = true;
ml_baseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=2, seed=batch_seed * 2);
parameters_sites = ml_baseline(xfeatures);

## test for gradients in batch
grads_batch = zeros(Float32, n_params, length(sites_training));
sites_batch = sites_training;#[1:n_sites_train];
indices_sites_batch = indices_sites_training;
params_batch = parameters_sites(; site=sites_batch);
scaled_params_batch = getParamsAct(params_batch, tbl_params);

# TODO: debug and benchmark again, one site!
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
    loc_observations,
    cost_options,
    constraint_method,
    indices_sites_batch,
    sites_batch
);

grads_lib = ForwardDiffGrad();
loc_params, inner_args = getInnerArgs(1, grads_lib, input_args...);

@time gg = gradientPolyester(grads_lib, loc_params, 2, lossSite, inner_args...)