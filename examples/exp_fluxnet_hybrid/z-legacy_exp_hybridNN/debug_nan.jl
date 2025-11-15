using Revise
using SindbadData
using SindbadTEM
using SindbadOptimization
#using Plots
toggleStackTraceNT()
experiment_json = "../exp_hack_gradient/settings_gradient/experiment.json"
begin_year = "2000"
end_year = "2017"

domain = "SD-Dem"
# domain = "MY-PSO"
path_input = "$(getSindbadDataDepot())/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing


parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.input_data_backend" => "netcdf",
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.exe_rules.land_output_type" => "array",
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

run_helpers = prepTEM(forcing, info);


@time runTEM!(run_helpers.space_selected_models, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)


# calculate the losses
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optimization.cost_options);

# setLogLevel(:debug)
# @profview metricVector(run_helpers.output_array, obs_array, cost_options) # |> sum
@time metricVector(run_helpers.output_array, obs_array, cost_options) # |> sum


parameter_table = info.optimization.parameter_table;

p_vec_tmp = Float32[0.57369316, 0.13665639, 0.021589328, 0.50214106, 5.8623033, 2.1876655, 2.9647522, 0.011739467, 1.5292873, 0.51821816, 1.9409876, 1.7648233, 0.4014304, 2.3504229, 0.5153693, 23.362156, 0.1913932, 0.3269863, 0.33425146, -15.749779, 2519.0886, 2.4048617, 0.5802649, 8.400246, 0.27925783, 1.2340356, 4.2097607, 25.068245, 78.582146, 0.813389, 0.024356516, 48.658554, 40.451153, 1.9116166, 78.221016, 2.258912, 0.055475786, 0.57011855, 0.4737399, 0.57703143, 0.46451482, 0.48786408]

@time metricVector(run_helpers.output_array, obs_array, cost_options) # |> sum

@time cost(parameter_table.initial, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, obs_array, parameter_table, cost_options, info.optimization.run_options.multi_constraint_method)

@time cost(p_vec_tmp, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, obs_array, parameter_table, cost_options, info.optimization.run_options.multi_constraint_method)

