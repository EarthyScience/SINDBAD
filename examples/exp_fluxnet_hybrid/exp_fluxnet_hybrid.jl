using Sindbad.DataLoaders
using Sindbad.DataLoaders.DimensionalData
using Sindbad.DataLoaders.AxisKeys
using Sindbad.DataLoaders.YAXArrays
using Sindbad
using Sindbad.MachineLearning
using Sindbad.MachineLearning.JLD2
using ProgressMeter
using Sindbad.Optimization
include("load_covariates.jl")

# load folds # $nfold $nlayer $neuron $batchsize
_nfold = 5 #Base.parse(Int, ARGS[1])
nlayers = 3 # Base.parse(Int, ARGS[2])
n_neurons = 32 # Base.parse(Int, ARGS[3])
batch_size = 32 # Base.parse(Int, ARGS[4])

batch_seed = 123 * batch_size

file_folds = load(joinpath(@__DIR__, "nfolds_sites_indices.jld2"))

xtrain, xval, xtest = file_folds["unfold_training"][_nfold], file_folds["unfold_validation"][_nfold], file_folds["unfold_tests"][_nfold]

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
selected_models = info.models.forward;
parameter_scaling_type = info.optimization.run_options.parameter_scaling



parameter_table = info.optimization.parameter_table;

parameter_to_index = getParameterIndices(selected_models, parameter_table);

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
    tem_info = run_helpers.tem_info
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
constraint_method = info.optimization.run_options.multi_constraint_method;

# ? load available covariates
xfeatures = loadCovariates(sites_forcing; kind="all")
nor_names_order = xfeatures.features
n_features = length(nor_names_order)

# ? initial neural network
n_neurons = 32;
n_params = sum(parameter_table.is_ml);
batch_seed = 123;

# encode-decode architecture!
mlBaseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=2, seed=batch_seed * 2);
# 
parameters_sites = mlBaseline(xfeatures);

tem_info = run_helpers.tem_info;

## test for gradients in batch
sites_common = xfeatures.site.data;

# TODO: debug and benchmark again, one site!

# ! full training
# ? training
sites_training = sites_forcing[xtrain];
indices_sites_training = siteNameToID.(sites_training, Ref(sites_forcing));

# # ? validation
sites_validation = sites_forcing[xval];
indices_sites_validation = siteNameToID.(sites_validation, Ref(sites_forcing));

# # ? test
sites_testing = sites_forcing[xtest];
indices_sites_testing = siteNameToID.(sites_testing, Ref(sites_forcing));

# NN 
n_params = sum(parameter_table.is_ml);
shuffle_opt = true;
mlBaseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=nlayers, seed=batch_seed * 2);
parameters_sites = mlBaseline(xfeatures);

## test for gradients in batch
grads_batch = zeros(Float32, n_params, length(sites_training));
sites_batch = sites_training;#[1:n_sites_train];
indices_sites_batch = indices_sites_training;
params_batch = parameters_sites(; site=sites_batch);
# scaled_params_batch = params_batch;
scaled_params_batch = getParamsAct(params_batch, parameter_table);

input_args = (
    scaled_params_batch,
    selected_models,
    space_forcing,
    space_spinup_forcing,
    loc_forcing_t,
    space_output,
    land_init,
    tem_info,
    parameter_to_index,
    parameter_scaling_type,
    space_observations,
    cost_options,
    constraint_method,
    indices_sites_batch,
    sites_batch
);

grads_lib = ForwardDiffGrad();
loc_params, inner_args = getInnerArgs(1, grads_lib, input_args...);

@time gg = gradientSite(grads_lib, loc_params, 2, lossSite, inner_args...)

gradientBatch!(grads_lib, grads_batch, 2, lossSite, getInnerArgs, input_args...; showprog=true)

# ? training arguments
chunk_size = 2
metadata_global = info.output.file_info.global_metadata

in_gargs=(;
    train_refs = (; sites_training, indices_sites_training, xfeatures, parameter_table, batch_size, chunk_size, metadata_global),
    test_val_refs = (; sites_validation, indices_sites_validation, sites_testing, indices_sites_testing),
    total_constraints = length(info.optimization.cost_options.variable),
    forward_args = (selected_models,
        space_forcing,
        space_spinup_forcing,
        loc_forcing_t,
        space_output,
        land_init,
        tem_info,
        parameter_to_index,
        parameter_scaling_type,
        space_observations,
        cost_options,
        constraint_method
        ),
    loss_fargs = (lossSite, getInnerArgs)
);

# ? now, this should take ~ 60 minutes(multi-threaded + multi-process). Before it was ~ 33 hrs (sequential).
# checkpoint_path = joinpath(@__DIR__, "../analysis/training_all_features/")
remote_raven = "/ptmp/lalonso/HybridOutput/HyALL_ALL_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(batch_size)/"
mkpath(remote_raven)
checkpoint_path = remote_raven

checkpoint_path = "$(info.output.dirs.data)/HyALL_ALL_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(batch_size)/"

mkpath(checkpoint_path)


mixedGradientTraining(grads_lib, mlBaseline, in_gargs.train_refs, in_gargs.test_val_refs,
    in_gargs.total_constraints, in_gargs.loss_fargs, in_gargs.forward_args;
    n_epochs=5, path_experiment=checkpoint_path)