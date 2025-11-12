using SindbadTEM
using SindbadSetup
using SindbadData
using SindbadData.DimensionalData
using SindbadData.AxisKeys
using SindbadData.YAXArrays
using SindbadML
using SindbadML.JLD2
using ProgressMeter
# using SindbadOptimization
using SindbadML.Zygote
# import AbstractDifferentiation as AD, Zygote


# extra includes for covariate and activation functions
# extra includes for covariate and activation functions
include(joinpath(@__DIR__, "../../examples/exp_fluxnet_hybrid/load_covariates.jl"))
include(joinpath(@__DIR__, "../../examples/exp_fluxnet_hybrid/test_activation_functions.jl"))


## paths
file_folds = load(joinpath(@__DIR__, "nfolds_sites_indices.jld2"))
experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"

# for remote node
path_input = "$(getSindbadDataDepot())/FLUXNET_v2023_12_1D.zarr"

path_covariates = "$(getSindbadDataDepot())/CovariatesFLUXNET_3.zarr"
replace_info = Dict()

replace_info = Dict(
      "forcing.default_forcing.data_path" => path_input,
      "optimization.observations.default_observation.data_path" => path_input,
      "optimization.optimization_cost_threaded" => false,
      );

info = getExperimentInfo(experiment_json; replace_info=replace_info);


selected_models = info.models.forward;
parameter_scaling_type = info.optimization.run_options.parameter_scaling

## parameters
tbl_params = info.optimization.parameter_table;
param_to_index = getParameterIndices(selected_models, tbl_params);

## forcing and obs
forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

## helpers
run_helpers = prepTEM(selected_models, forcing, observations, info);

space_forcing = run_helpers.space_forcing;
space_observations = run_helpers.space_observation;
space_output = run_helpers.space_output;
space_spinup_forcing = run_helpers.space_spinup_forcing;
space_ind = run_helpers.space_ind;
land_init = run_helpers.loc_land;
loc_forcing_t = run_helpers.loc_forcing_t;

space_cost_options = [prepCostOptions(loc_obs, info.optimization.cost_options) for loc_obs in space_observations];
constraint_method = info.optimization.run_options.multi_constraint_method;

tem_info = run_helpers.tem_info;
## do example site
##

site_example_1 = space_ind[1][1];
@time coreTEM!(selected_models, space_forcing[site_example_1], space_spinup_forcing[site_example_1], loc_forcing_t, space_output[site_example_1], land_init, tem_info)

##

## features 
sites_forcing = forcing.data[1].site; # sites names


# ! selection and batching
_nfold = 5 #Base.parse(Int, ARGS[1]) # select the fold
xtrain, xval, xtest = file_folds["unfold_training"][_nfold], file_folds["unfold_validation"][_nfold], file_folds["unfold_tests"][_nfold]

# ? training
sites_training = sites_forcing[xtrain];
indices_sites_training = siteNameToID.(sites_training, Ref(sites_forcing));
# # ? validation
sites_validation = sites_forcing[xval];
indices_sites_validation = siteNameToID.(sites_validation, Ref(sites_forcing));
# # ? test
sites_testing = sites_forcing[xtest];
indices_sites_testing = siteNameToID.(sites_testing, Ref(sites_forcing));

indices_sites_batch = indices_sites_training;

xfeatures = loadCovariates(sites_forcing; kind="all", cube_path=path_covariates);
@info "xfeatures: [$(minimum(xfeatures)), $(maximum(xfeatures))]"

nor_names_order = xfeatures.features;
n_features = length(nor_names_order)

## Build ML method
n_params = sum(tbl_params.is_ml);
nlayers = 3 # Base.parse(Int, ARGS[2])
n_neurons = 32 # Base.parse(Int, ARGS[3])
batch_size = 32 # Base.parse(Int, ARGS[4])
batch_seed = 123 * batch_size * 2
n_epochs = 2
k_σ = 1.f0
# custom_activation = CustomSigmoid(k_σ)
# custom_activation = sigmoid_3
mlBaseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=nlayers, seed=batch_seed);

# Initialize params and grads
params_sites = mlBaseline(xfeatures);
@info "params_sites: [$(minimum(params_sites)), $(maximum(params_sites))]"

grads_batch = zeros(Float32, n_params, length(sites_training))[:,1:batch_size];
sites_batch = sites_training;#[1:n_sites_train];
params_batch = params_sites(; site=sites_batch);
@info "params_batch: [$(minimum(params_batch)), $(maximum(params_batch))]"
scaled_params_batch = getParamsAct(params_batch, tbl_params);
@info "scaled_params_batch: [$(minimum(scaled_params_batch)), $(maximum(scaled_params_batch))]"

forward_args = (
    selected_models,
    space_forcing,
    space_spinup_forcing,
    loc_forcing_t,
    space_output,
    land_init,
    tem_info,
    param_to_index,
    parameter_scaling_type,
    space_observations,
    space_cost_options,
    constraint_method
    );


input_args = (
        scaled_params_batch, 
        forward_args..., 
        indices_sites_batch,
        sites_batch
);

grads_lib = ForwardDiffGrad();
grads_lib = FiniteDifferencesGrad();
grads_lib = FiniteDiffGrad();
grads_lib = PolyesterForwardDiffGrad();
# grads_lib = ZygoteGrad();
# grads_lib = EnzymeGrad();
# backend = AD.ZygoteBackend();

loc_params, inner_args = getInnerArgs(1, grads_lib, input_args...);

loss_tmp(x) = lossSite(x, grads_lib, inner_args...)

# AD.gradient(backend, loss_tmp, collect(loc_params))

@time gg = gradientSite(grads_lib, loc_params, 2, lossSite, inner_args...)

gradientBatch!(grads_lib, grads_batch, 2, lossSite, getInnerArgs,input_args...; showprog=true)


# ? training arguments
chunk_size = 2
metadata_global = info.output.file_info.global_metadata

in_gargs=(;
    train_refs = (; sites_training, indices_sites_training, xfeatures, tbl_params, batch_size, chunk_size, metadata_global),
    test_val_refs = (; sites_validation, indices_sites_validation, sites_testing, indices_sites_testing),
    total_constraints = length(info.optimization.cost_options.variable),
    forward_args,
    loss_fargs = (lossSite, getInnerArgs)
);

checkpoint_path = "$(info.output.dirs.data)/HyALL_ALL_kσ_$(k_σ)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size)/"

mkpath(checkpoint_path)

@info checkpoint_path
mixedGradientTraining(grads_lib, mlBaseline, in_gargs.train_refs, in_gargs.test_val_refs, in_gargs.total_constraints, in_gargs.loss_fargs, in_gargs.forward_args; n_epochs=n_epochs, path_experiment=checkpoint_path)
