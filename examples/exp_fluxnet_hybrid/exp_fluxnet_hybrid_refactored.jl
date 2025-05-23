using SindbadExperiment
using SindbadML
using SindbadML.JLD2
using ProgressMeter
using SindbadML.Zygote

include(joinpath(@__DIR__, "../../examples/exp_fluxnet_hybrid/load_covariates.jl"))
include(joinpath(@__DIR__, "../../examples/exp_fluxnet_hybrid/test_activation_functions.jl"))

function setup_folds_replace(folds_path, forcing_path, observation_path)
    data_folds = load(folds_path)
    replace_info = Dict(
        "forcing.default_forcing.data_path" => forcing_path,
        "optimization.observations.default_observation.data_path" => observation_path,
        "optimization.optimization_cost_threaded" => false,
    )
    return data_folds, replace_info
end

function load_experiment_info(experiment_json, replace_info)
    info = getExperimentInfo(experiment_json; replace_info=replace_info)
    selected_models = info.models.forward
    parameter_scaling_type = info.optimization.run_options.parameter_scaling
    tbl_params = info.optimization.parameter_table
    param_to_index = getParameterIndices(selected_models, tbl_params)
    return info, selected_models, parameter_scaling_type, tbl_params, param_to_index
end

function load_forcing_obs(info)
    forcing = getForcing(info)
    observations = getObservation(info, forcing.helpers)
    return forcing, observations
end

function prepare_helpers(selected_models, forcing, observations, info)
    run_helpers = prepTEM(selected_models, forcing, observations, info)
    return run_helpers
end

function select_folds(data_folds, _nfold)
    xtrain = data_folds["unfold_training"][_nfold]
    xval = data_folds["unfold_validation"][_nfold]
    xtest = data_folds["unfold_tests"][_nfold]
    return xtrain, xval, xtest
end

function get_site_indices(sites_forcing, xfold)
    sites = sites_forcing[xfold]
    indices = siteNameToID.(sites, Ref(sites_forcing))
    return sites, indices
end

function build_ml(n_features, n_params, nlayers, n_neurons, batch_seed)
    mlBaseline = denseNN(n_features, n_neurons, n_params; extra_hlayers=nlayers, seed=batch_seed)
    return mlBaseline
end

function prepare_training(params_sites, sites_training, tbl_params, batch_size)
    params_batch = params_sites(; site=sites_training)
    scaled_params_batch = getParamsAct(params_batch, tbl_params)
    grads_batch = zeros(Float32, size(scaled_params_batch, 1), length(sites_training))[:, 1:batch_size]
    return params_batch, scaled_params_batch, grads_batch
end

function build_forward_args(selected_models, run_helpers, param_to_index, parameter_scaling_type, info)
    return (
        selected_models,
        run_helpers.space_forcing,
        run_helpers.space_spinup_forcing,
        run_helpers.loc_forcing_t,
        run_helpers.space_output,
        run_helpers.loc_land,
        run_helpers.tem_info,
        param_to_index,
        parameter_scaling_type,
        run_helpers.space_observation,
        [prepCostOptions(loc_obs, info.optimization.cost_options) for loc_obs in run_helpers.space_observation],
        info.optimization.run_options.multi_constraint_method
    )
end


path_data_folds = joinpath(@__DIR__, "nfolds_sites_indices.jld2")
path_experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"
path_input = "$(getSindbadDataDepot())/FLUXNET_v2023_12_1D.zarr"
path_observation = path_input
path_covariates = "$(getSindbadDataDepot())/CovariatesFLUXNET_3.zarr"

nfold=5
nlayers=3
n_neurons=32
batch_size=32
n_epochs=2
k_σ=1.f0

data_folds, replace_info = setup_folds_replace(path_data_folds, path_input, path_observation);
info, selected_models, parameter_scaling_type, tbl_params, param_to_index = load_experiment_info(path_experiment_json, replace_info);
forcing, observations = load_forcing_obs(info);
run_helpers = prepare_helpers(selected_models, forcing, observations, info);

sites_forcing = forcing.data[1].site;
xtrain, xval, xtest = select_folds(data_folds, nfold);
sites_training, indices_sites_training = get_site_indices(sites_forcing, xtrain);
sites_validation, indices_sites_validation = get_site_indices(sites_forcing, xval);
sites_testing, indices_sites_testing = get_site_indices(sites_forcing, xtest);
indices_sites_batch = indices_sites_training;

xfeatures = loadCovariates(sites_forcing; kind="all", cube_path=path_covariates);
@info "xfeatures: [$(minimum(xfeatures)), $(maximum(xfeatures))]"
nor_names_order = xfeatures.features;
n_features = length(nor_names_order);
n_params = sum(tbl_params.is_ml);
batch_seed = 123 * batch_size * 2

mlBaseline = build_ml(n_features, n_params, nlayers, n_neurons, batch_seed)

params_sites = mlBaseline(xfeatures)

params_batch, scaled_params_batch, grads_batch = prepare_training(params_sites, sites_training, tbl_params, batch_size)
@info "params_sites: [$(minimum(params_sites)), $(maximum(params_sites))]"
@info "params_batch: [$(minimum(params_batch)), $(maximum(params_batch))]"
@info "scaled_params_batch: [$(minimum(scaled_params_batch)), $(maximum(scaled_params_batch))]"

forward_args = build_forward_args(selected_models, run_helpers, param_to_index, parameter_scaling_type, info);
input_args = (scaled_params_batch, forward_args..., indices_sites_batch, sites_training);

grads_lib = ForwardDiffGrad()
grads_lib = FiniteDifferencesGrad()
grads_lib = FiniteDiffGrad()
grads_lib = PolyesterForwardDiffGrad()
# grads_lib = ZygoteGrad()
# grads_lib = EnzymeGrad()

loc_params, inner_args = getInnerArgs(1, grads_lib, input_args...);

@time gg = gradientSite(grads_lib, loc_params, 2, lossSite, inner_args...)
gradientBatch!(grads_lib, grads_batch, 2, lossSite, getInnerArgs, input_args...; showprog=true)

chunk_size = 2
metadata_global = info.output.file_info.global_metadata

in_gargs = (; 
    train_refs = (; sites_training, indices_sites_training, xfeatures, tbl_params, batch_size, chunk_size, metadata_global),
    test_val_refs = (; sites_validation, indices_sites_validation, sites_testing, indices_sites_testing),
    total_constraints = length(info.optimization.cost_options.variable),
    forward_args,
    loss_fargs = (lossSite, getInnerArgs)
)

checkpoint_path = "$(info.output.dirs.data)/HyALL_ALL_kσ_$(k_σ)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size)/"
mkpath(checkpoint_path)
@info checkpoint_path

mixedGradientTraining(grads_lib, mlBaseline, in_gargs.train_refs, in_gargs.test_val_refs, in_gargs.total_constraints, in_gargs.loss_fargs, in_gargs.forward_args; n_epochs=n_epochs, path_experiment=checkpoint_path)


