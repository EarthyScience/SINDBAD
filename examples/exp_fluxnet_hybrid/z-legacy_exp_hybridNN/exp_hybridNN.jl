# install dependencies by running the following line first:
# dev ../.. ../../lib/SindbadUtils/ ../../lib/SindbadData/ ../../lib/SindbadMetrics/ ../../lib/SindbadSetup/ ../../lib/SindbadTEM ../../lib/SindbadML
# dev ../.. ../../lib/SindbadUtils/ ../../lib/SindbadData/ ../../lib/SindbadMetrics/ ../../lib/SindbadSetup/ ../../lib/SindbadTEM ../../lib/SindbadOptimization ../../lib/SindbadML
using Revise
using SindbadData
using SindbadTEM
using YAXArrays
using SindbadML
using ForwardDiff
using Zygote
using Optimisers
using PreallocationTools
using JLD2

toggleStackTraceNT()

experiment_json = "../exp_hybridNN/settings_hybridNN/experiment.json"

info = getExperimentInfo(experiment_json);

table_parameters = info.optimization.table_parameters;

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

selected_models = info.models.forward;
param_to_index = getParameterIndices(selected_models, table_parameters);

run_helpers = prepTEM(selected_models, forcing, observations, info);

loc_forcing_t = run_helpers.loc_forcing_t;
land_init = run_helpers.loc_land;
tem = (;
    tem_info = run_helpers.tem_info
    );

# site specific variables
space_forcing = run_helpers.space_forcing;
loc_observations = run_helpers.loc_observations;
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


# ForwardDiff.gradient(f, x)
# load available covariates
# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_forcing = forcing.data[1].site;
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr")); #"/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr"
xfeatures_o = yaxCubeToKeyedArray(c);
to_rm = findall(x->x>0, occursin.("VIF", xfeatures_o.features));
to_rm_names = xfeatures_o.features[to_rm];
new_features = setdiff(xfeatures_o.features, to_rm_names);
xfeatures_all = xfeatures_o(; features = new_features);

sites_feature_all = [s for s in xfeatures_all.site];
sites_common_all = intersect(sites_feature_all, sites_forcing);

test_grads = 32;
test_grads = 0;
if test_grads !== 0
    sites_common = sites_common_all[1:test_grads];
else
    sites_common = sites_common_all;
end;

xfeatures = xfeatures_all(; site=sites_common);
n_features = length(xfeatures.features);

# remove bad sites
# sites_common = setdiff(sites_common, ["CA-NS6", "SD-Dem", "US-WCr", "ZM-Mon"])


# get site splits 
train_split = 0.8;
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
sites_training = shuffleList(sites_common; seed=batch_seed)[1:n_sites_train];
indices_sites_training = siteNameToID.(sites_training, Ref(sites_forcing));


# NN 
n_epochs = 25;
n_neurons = 32;
n_params = sum(table_parameters.is_ml);
shuffle_opt = true;
ml_baseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=2, seed=batch_seed * 2);
parameters_sites = ml_baseline(xfeatures);

## test for gradients in batch
grads_batch = zeros(Float32, n_params, length(sites_training));
sites_batch = sites_training;#[1:n_sites_train];
indices_sites_batch = indices_sites_training;
params_batch = parameters_sites(; site=sites_batch);
scaled_params_batch = getParamsAct(params_batch, table_parameters);

gradient_lib = ForwardDiffGrad();
gradient_lib = FiniteDiffGrad();
# gradient_lib = FiniteDifferencesGrad();

@time gradientBatch!(gradient_lib, lossSite, grads_batch, scaled_params_batch, selected_models, sites_batch, indices_sites_batch, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, land_init, loc_observations, tem, param_to_index, cost_options, constraint_method)

# machine learning parameters baseline
@time sites_loss, re, flat = trainSindbadML(gradient_lib, ml_baseline, lossSite, xfeatures, selected_models, sites_training, indices_sites_training, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, land_init, loc_observations, table_parameters, tem, param_to_index, cost_options, constraint_method; n_epochs=n_epochs, optimizer=Optimisers.Adam(), batch_seed=batch_seed, batch_size=batch_size, shuffle=shuffle_opt, local_root=info.output.dirs.data,name="seq_training_output")

f_suffix = "_epoch-$(n_epochs)_batch-size-$(batch_size)-seed-$(batch_seed)_$(nameof(typeof(gradient_lib)))"
using CairoMakie
fig = Figure(; resolution = (2400,1200))
ax = Axis(fig[1,1]; xlabel = "epoch", ylabel = "site")
obj = plot!(ax, sites_loss';
    colorrange=(0,5))
Colorbar(fig[1,2], obj)
fig
save(joinpath(info.output.dirs.figure, "epoch_loss$(f_suffix).png"), fig)

fig = Figure(; resolution = (2400,1200))
ax = Axis(fig[1,1]; xlabel = "epoch", ylabel = "site loss")
foreach(axes(sites_loss,1)) do _cl
    obj = lines!(ax, sites_loss[_cl,:])
    fig
    obj = lines!(ax, mean(sites_loss, dims=1)[1,:], linewidth = 5, color = "black")
end
save(joinpath(info.output.dirs.figure, "epoch_lines$(f_suffix).png"), fig)

loss_array_sites = fill(zero(Float32), length(sites_training), n_epochs);

@time getLossForSites(gradient_lib, lossSite, loss_array_sites, 2, parameters_sites, selected_models, sites_training, indices_sites_training, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, land_init, loc_observations, tem, param_to_index, cost_options, constraint_method; logging=false)