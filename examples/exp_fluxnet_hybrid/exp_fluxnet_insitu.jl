using SindbadData
using SindbadData.DimensionalData
using SindbadData.AxisKeys
using SindbadData.YAXArrays
using SindbadTEM
using SindbadML
using SindbadML.JLD2
using SindbadOptimization
using ProgressMeter

include("load_covariates.jl")

# load folds # $nfold $nlayer $neuron $batchsize
_nfold = 5 #B ase.parse(Int, ARGS[1])
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
site_location = space_ind[3][1];
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

#! yes?
loc_cost_options = cost_options[site_location]

lossVec = getLossVector(loc_output, loc_obs, loc_cost_options)
t_loss = combineLoss(lossVec, constraint_method)

function lossSite2(new_params, models, loc_forcing, loc_spinup_forcing,
    loc_forcing_t, loc_output, land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem)

    new_models = updateModelParameters(param_to_index, models, new_params)
    coreTEM!(new_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem...)
    lossVec = getLossVector(loc_output, loc_obs, loc_cost_options)
    t_loss = combineLoss(lossVec, constraint_method)
    return t_loss
end

default_values = tbl_params.default

lossSite2(default_values, selected_models, loc_forcing, loc_spinup_forcing,
    loc_forcing_t, loc_output, land_init, param_to_index, loc_obs,
    loc_cost_options, constraint_method, tem)

cost_function = x -> lossSite2(x, selected_models, loc_forcing, loc_spinup_forcing,
    loc_forcing_t, loc_output, land_init, param_to_index, loc_obs,
    loc_cost_options, constraint_method, tem)

@time cost_function(default_values)

#? run the optimizer
lower_bounds = tbl_params.lower
upper_bounds = tbl_params.upper

optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds,
    info.optimization.algorithm.options, info.optimization.algorithm.method)