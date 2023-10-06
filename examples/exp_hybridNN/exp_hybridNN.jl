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

tbl_params = getParameters(info.tem.models.forward, info.optim.model_parameter_default, info.optim.model_parameters_to_optimize, info.tem.helpers.numbers.sNT);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

models = info.tem.models.forward;
param_to_index = getParameterIndices(models, tbl_params);
models_lt = makeLongTuple(models, 10);

run_helpers = prepTEM(models_lt, forcing, observations, info);

forcing_one_timestep = run_helpers.forcing_one_timestep;
land_init = run_helpers.land_one;
tem = (;
    tem_helpers = run_helpers.tem_with_types.helpers,
    tem_spinup = run_helpers.tem_with_types.spinup,
    tem_run_spinup = run_helpers.tem_with_types.helpers.run.spinup_TEM,
);

# site specific variables
loc_forcings = run_helpers.loc_forcings;
loc_observations = run_helpers.loc_observations;
loc_outputs = run_helpers.loc_outputs;
loc_spinup_forcings = run_helpers.loc_spinup_forcings;
loc_space_inds = run_helpers.loc_space_inds;
site_location = loc_space_inds[1][1];
loc_forcing = loc_forcings[site_location];

loc_obs = loc_observations[site_location];

loc_output = loc_outputs[site_location];
loc_spinup_forcing = loc_spinup_forcings[site_location];


# run the model
@time coreTEM!(models_lt, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem...)

# cost related

cost_options = [prepCostOptions(loc_obs, info.optim.cost_options) for loc_obs in loc_observations];

constraint_method = info.optim.multi_constraint_method;


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
n_epochs = 5;
n_neurons = 32;
n_params = sum(tbl_params.is_ml);
shuffle_opt = true;
ml_baseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=2, seed=523);
parameters_sites = ml_baseline(xfeatures);

## test for gradients in batch
grads_batch = zeros(Float32, n_params, length(sites_training));
sites_batch = sites_training;#[1:n_sites_train];
indices_sites_batch = indices_sites_training;
params_batch = parameters_sites(; site=sites_batch);
scaled_params_batch = getParamsAct(params_batch, tbl_params);

gradient_lib = ForwardDiffGrad();
gradient_lib = FiniteDiffGrad();
# gradient_lib = FiniteDifferencesGrad();

@time gradientBatch!(gradient_lib, lossSite, grads_batch, scaled_params_batch, models_lt, sites_batch, indices_sites_batch, loc_forcings, loc_spinup_forcings, forcing_one_timestep, loc_outputs, land_init, loc_observations, tem, param_to_index, cost_options, constraint_method)

# machine learning parameters baseline
@time sites_loss, re, flat = trainSindbadML(gradient_lib, ml_baseline, lossSite, xfeatures, models_lt, sites_training, indices_sites_training, loc_forcings, loc_spinup_forcings, forcing_one_timestep, loc_outputs, land_init, loc_observations, tbl_params, tem, param_to_index, cost_options, constraint_method; n_epochs=n_epochs, optimizer=Optimisers.Adam(), batch_seed=batch_seed, batch_size=batch_size, shuffle=shuffle_opt, local_root=info.output.data,name="seq_training_output")

f_suffix = "_epoch-$(n_epochs)_batch-size-$(batch_size)-seed-$(batch_seed)_$(nameof(typeof(gradient_lib)))"
using CairoMakie
fig = Figure(; resolution = (2400,1200))
ax = Axis(fig[1,1]; xlabel = "epoch", ylabel = "site")
obj = plot!(ax, sites_loss';
    colorrange=(0,5))
Colorbar(fig[1,2], obj)
fig
save(joinpath(info.output.figure, "epoch_loss$(f_suffix).png"), fig)

fig = Figure(; resolution = (2400,1200))
ax = Axis(fig[1,1]; xlabel = "epoch", ylabel = "site loss")
foreach(axes(sites_loss,1)) do _cl
    obj = lines!(ax, sites_loss[_cl,:])
    fig
    obj = lines!(ax, mean(sites_loss, dims=1)[1,:], linewidth = 5, color = "black")
end
save(joinpath(info.output.figure, "epoch_lines$(f_suffix).png"), fig)

loss_array_sites = fill(zero(Float32), length(sites_training), n_epochs);

@time getLossForSites(gradient_lib, lossSite, loss_array_sites, 2, parameters_sites, models_lt, sites_training, indices_sites_training, loc_forcings, loc_spinup_forcings, forcing_one_timestep, loc_outputs, land_init, loc_observations, tem, param_to_index, cost_options, constraint_method; logging=false)