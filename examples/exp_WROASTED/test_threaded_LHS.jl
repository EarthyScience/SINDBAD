using Revise
using Sindbad
using SindbadExperiment
using Plots
using QuasiMonteCarlo
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "1999"
end_year = "2010"

domain = "CA-Obs"
path_input = nothing
forcing_config = nothing
optimization_config = nothing
mod_step = "day"
# mod_step = "hour"
# foreach(["day", "hour"]) do mod_step
if mod_step == "day"
    path_input = "../data/fn/$(domain).1979.2017.daily.nc"
    forcing_config = "forcing_erai.json"
    optimization_config = "optimization.json"
else
    mod_step
    path_input = "../data/fn/$(domain).1999.2010.hourly_for_Sindbad.nc"
    forcing_config = "forcing_hourly.json"
    optimization_config = "optimization_hourly.json"
end

path_observation = path_input
optimize_it = false
optimize_it = true
path_output = nothing

setLogLevel(:info)

parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.config_files.optimization" => optimization_config,
    "experiment.basics.domain" => domain,
    "experiment.basics.name" => "WROASTED_$mod_step",
    "experiment.basics.time.temporal_resolution" => mod_step,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.land_output_type" => "array_MT",
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm_optimization" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.subset_model_output" => false,
    "optimization.observations.default_observation.data_path" => path_observation)

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

run_helpers = prepTEM(forcing, info);
@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info);
# @time output_cost = runExperimentCost(experiment_json; replace_info=replace_info);
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because 

tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution);
defaults = tbl_params.default;

param_set_size = info.optimization.n_threads_cost
param_set_size = 200
param_samples = QuasiMonteCarlo.sample(param_set_size, tbl_params.lower, tbl_params.upper, LatinHypercubeSample());
cost_samples_c = Array{Float32}(undef, param_set_size) # serial
cost_samples_s = Array{Float32}(undef, param_set_size) # serial
cost_samples_t = Array{Float32}(undef, param_set_size) # threaded
# opti_helpers = prepOpti(forcing, obs_array, info, info.optimization.optimization_cost_method);



cost_options = prepCostOptions(obs_array, info.optimization.cost_options);
parameter_scaling_type = info.optimization.optimization_parameter_scaling
multi_constraint_method = info.optimization.multi_constraint_method
param_updater = tbl_params


space_index = 1

@time Threads.@threads for param_index in eachindex(1:param_set_size)
    idx = Threads.threadid()
    param_vector = param_samples[:, param_index]
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, info.models.forward)
    coreTEM!(updated_models, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.space_output_mt[idx], run_helpers.space_land[space_index], run_helpers.tem_info)
    cost_vector = metricVector(run_helpers.space_output_mt[idx], obs_array, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    cost_samples_t[param_index] = cost_metric
    @show idx, cost_metric
end


@time cost(param_samples, defaults, info.models.forward, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output_mt, run_helpers.space_land[space_index], run_helpers.tem_info, obs_array, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, cost_samples_c,  CostModelObsMT())



fig=plot(cost_samples_t, label="threads loop")
plot!(cost_samples_c, label="threaded cost")

cost_samples_t - cost_samples_c |> sum

do_serial = true
do_serial = false
if do_serial
    @time for param_index in eachindex(1:param_set_size)
        param_vector = param_samples[:, param_index]
        updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, info.models.forward)
        coreTEM!(updated_models, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.space_output[space_index], run_helpers.space_land[space_index], run_helpers.tem_info)
        cost_vector = metricVector(run_helpers.space_output[space_index], obs_array, cost_options)
        cost_metric = combineMetric(cost_vector, multi_constraint_method)
        cost_samples_s[param_index] = cost_metric
        @show param_index, cost_metric
    end

    plot!(cost_samples_s, label="serial call")
    @show cost_samples_t - cost_samples_s |> sum
end
fig