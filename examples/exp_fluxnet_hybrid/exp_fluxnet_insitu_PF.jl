using Sindbad.Simulation
using Sindbad.SetupSimulation
using Utils
using Sindbad.DataLoaders
using Sindbad.DataLoaders.DimensionalData
using Sindbad.DataLoaders.AxisKeys
using Sindbad.DataLoaders.YAXArrays
using Sindbad.Simulation
using Sindbad.MachineLearning
using Sindbad.MachineLearning.JLD2
using Sindbad.Optimization
using SindbadTEM.Metrics
using ProgressMeter

experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"
# for remote node
replace_info = Dict()
if Sys.islinux()
    replace_info = Dict(
        "forcing.default_forcing.data_path" => "$(getSindbadDataDepot())/FLUXNET_v2023_12_1D.zarr",
        "optimization.observations.default_observation.data_path" => "$(getSindbadDataDepot())/FLUXNET_v2023_12_1D.zarr"
    )
end

replace_info["experiment.basics.config_files.model_structure"] = "model_structure_PF.json"
replace_info["experiment.basics.config_files.optimization"] = "optimization_PF.json"

info = getExperimentInfo(experiment_json; replace_info=replace_info);
selected_models = info.models.forward;

tbl_params = info.optimization.parameter_table;

param_to_index = getParameterIndices(selected_models, tbl_params);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
run_helpers = prepTEM(selected_models, forcing, observations, info);
land = run_helpers.loc_land;
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
    tem_info=run_helpers.tem_info,
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
constraint_method = info.optimization.run_options.multi_constraint_method;

#! yes?
loc_cost_options = cost_options[site_location]

lossVec = metricVector(loc_output, loc_obs, loc_cost_options)
t_loss = combineMetric(lossVec, constraint_method)

function lossSite2(new_params, models, loc_forcing, loc_spinup_forcing,
    loc_forcing_t, loc_output, land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem)

    new_models = updateModelParameters(param_to_index, models, new_params)
    coreTEM!(new_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem...)
    lossVec = metricVector(loc_output, loc_obs, loc_cost_options)
    t_loss = combineMetric(lossVec, constraint_method)
    return t_loss
end

function lossSiteFD(new_params, models, loc_forcing, loc_spinup_forcing,
    loc_forcing_t, loc_output, land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem)

    new_models = updateModelParameters(param_to_index, models, new_params)

    out_data = SindbadML.getOutputFromCache(loc_output, new_params, ForwardDiffGrad())

    coreTEM!(new_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, out_data, land_init, tem...)
    lossVec = metricVector(out_data, loc_obs, loc_cost_options)
    t_loss = combineMetric(lossVec, constraint_method)
    return t_loss
end

default_values = Float32.(tbl_params.default)

lossSiteFD(default_values, selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, SindbadML.getCacheFromOutput(loc_output, ForwardDiffGrad()), land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem)

lossSite2(default_values, selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem)

cost_function = x -> lossSite2(x, selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem) 

cost_functionFD = x -> lossSiteFD(x, selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, SindbadML.getCacheFromOutput(loc_output, ForwardDiffGrad()), land_init, param_to_index, loc_obs, loc_cost_options, constraint_method, tem) 

@time cost_function(default_values)
@time cost_functionFD(default_values)

#? run the optimizer
lower_bounds = tbl_params.lower
upper_bounds = tbl_params.upper

# optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds,
#     info.optimization.optimizer.options, info.optimization.optimizer.method)


# ? https://github.com/jbrea/CMAEvolutionStrategy.jl
# and compare output and performance
# use: (go for parallel/threaded approaches)

# using Sindbad.Optimization.CMAEvolutionStrategy

results = SindbadOptimization.minimize(cost_function,
    default_values,
    1;
    lower=lower_bounds,
    upper=upper_bounds,
    maxiter=100,
    multi_threading=true,
)

optim_para = SindbadOptimization.xbest(results)

# ? https://github.com/AStupidBear/GCMAES.jl

using GCMAES
x0 = default_values
σ0 = 0.2
lo = lower_bounds
hi = upper_bounds
maxiter = 5

xmin, fmin, status = GCMAES.minimize(cost_function, x0, σ0, lo, hi, maxiter=maxiter)

# ? now speedup convergence with some gradient information
using Sindbad.Optimization.ForwardDiff
∇loss(x) = ForwardDiff.gradient(cost_functionFD, x)

xmin, fmin, status = GCMAES.minimize((cost_functionFD, ∇loss), x0, σ0, lo, hi, maxiter=100);
