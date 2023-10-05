using Revise
using SindbadData
using SindbadTEM
using SindbadMetrics
using SindbadOptimization
#using Plots
toggleStackTraceNT()
experiment_json = "../exp_hack_gradient/settings_gradient/experiment.json"
begin_year = "2000"
end_year = "2017"

domain = "SD-Dem"
# domain = "MY-PSO"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
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
    "experiment.flags.spinup.save_spinup" => false,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.input_data_backend" => "netcdf",
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.exe_rules.land_output_type" => "array",
    "experiment.flags.spinup.run_spinup" => true,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

run_helpers = prepTEM(forcing, info);


@time runTEM!(info.tem.models.forward,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)



# calculate the losses
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optim.cost_options);

# setLogLevel(:debug)
# @profview getLossVector(run_helpers.output_array, obs_array, cost_options) # |> sum
@time getLossVector(run_helpers.output_array, obs_array, cost_options) # |> sum


tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT)

p_vec_tmp = Float32[0.57369316, 0.13665639, 0.021589328, 0.50214106, 5.8623033, 2.1876655, 2.9647522, 0.011739467, 1.5292873, 0.51821816, 1.9409876, 1.7648233, 0.4014304, 2.3504229, 0.5153693, 23.362156, 0.1913932, 0.3269863, 0.33425146, -15.749779, 2519.0886, 2.4048617, 0.5802649, 8.400246, 0.27925783, 1.2340356, 4.2097607, 25.068245, 78.582146, 0.813389, 0.024356516, 48.658554, 40.451153, 1.9116166, 78.221016, 2.258912, 0.055475786, 0.57011855, 0.4737399, 0.57703143, 0.46451482, 0.48786408]

@time getLossVector(run_helpers.output_array, obs_array, cost_options) # |> sum

@time getLoss(tbl_params.default, info.tem.models.forward, run_helpers.loc_forcings, run_helpers.loc_spinup_forcings, run_helpers.forcing_one_timestep, run_helpers.output_array, run_helpers.loc_outputs, run_helpers.land_init_space, run_helpers.tem_with_types, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)

@time getLoss(p_vec_tmp, info.tem.models.forward, run_helpers.loc_forcings, run_helpers.loc_spinup_forcings, run_helpers.forcing_one_timestep, run_helpers.output_array, run_helpers.loc_outputs, run_helpers.land_init_space, run_helpers.tem_with_types, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)

