using Revise
using SindbadData
using SindbadTEM
using SindbadMetrics
using Plots
toggleStackTraceNT()
experiment_json = "../exp_landWrapper/settings_landWrapper/experiment.json"
begin_year = "1979"
end_year = "2017"

domain = "DE-Hai"
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
    "experiment.basics.domain" => domain,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.spinup.save_spinup" => false,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.flags.spinup.run_spinup" => true,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
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


@time lw_timeseries_prep = runTEM(info.tem.models.forward, run_helpers.loc_forcings[1], run_helpers.forcing_one_timestep, run_helpers.land_one, run_helpers.tem_with_types);

@time lw_timeseries = runTEM(forcing, info);

land_timeseries = Vector{typeof(run_helpers.land_one)}(undef, info.tem.helpers.dates.size);

@time lw_timeseries_vec = runTEM(info.tem.models.forward, run_helpers.loc_forcings[1], run_helpers.forcing_one_timestep, land_timeseries, run_helpers.land_one, run_helpers.tem_with_types);

# calculate the losses
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optim.cost_options);

# setLogLevel(:debug)
# @profview getLossVector(obs_array, run_helpers.output_array, cost_options) # |> sum
@time getLossVector(obs_array, run_helpers.output_array, cost_options) # |> sum
@time getLossVector(obs_array, lw_timeseries_prep, cost_options) # |> sum
@time getLossVector(obs_array, lw_timeseries, cost_options) # |> sum
@time getLossVector(obs_array, lw_timeseries_vec, cost_options) #|> sum


tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize)

defaults = tbl_params.default;

@time getLoss(defaults, info.tem.models.forward, run_helpers.loc_forcings, run_helpers.forcing_one_timestep, run_helpers.output_array, run_helpers.loc_outputs, run_helpers.land_init_space, run_helpers.tem_with_types, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)

@time getLoss(defaults, info.tem.models.forward, run_helpers.loc_forcings[1], run_helpers.forcing_one_timestep, run_helpers.land_one, run_helpers.tem_with_types, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)

@time getLoss(defaults, info.tem.models.forward, run_helpers.loc_forcings[1], run_helpers.forcing_one_timestep, land_timeseries, run_helpers.land_one, run_helpers.tem_with_types, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)


