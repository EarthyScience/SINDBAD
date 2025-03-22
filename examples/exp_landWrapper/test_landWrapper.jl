using Revise
using SindbadData
using SindbadTEM
using SindbadMetrics
using SindbadExperiment
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
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# calculate the losses
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

info = dropFields(info, (:settings,));

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

@time land_stacked_ts = runTEM(info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, deepcopy(run_helpers.loc_land), run_helpers.tem_info);

land_stacked_prealloc = Vector{typeof(run_helpers.loc_land)}(undef, info.helpers.dates.size);

@time land_stacked_prealloc = runTEM(info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, land_stacked_prealloc, run_helpers.loc_land, run_helpers.tem_info);
runTEM(info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, land_stacked_prealloc, run_helpers.loc_land, run_helpers.tem_info);

tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution);


cost_options = prepCostOptions(obs_array, info.optimization.cost_options);

@time metricVector(run_helpers.output_array, obs_array, cost_options)  |> sum
@time metricVector(land_stacked_ts, obs_array, cost_options)  |> sum
@time metricVector(land_stacked_prealloc, obs_array, cost_options) |> sum


tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution)
defaults = tbl_params.default;

@time cost(defaults, defaults, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, obs_array, tbl_params, cost_options, info.optimization.multi_constraint_method, info.optimization.optimization_parameter_scaling, info.optimization.optimization_cost_method)

@time costLand(defaults, info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, nothing, run_helpers.loc_land, run_helpers.tem_info, obs_array, tbl_params, cost_options, info.optimization.multi_constraint_method, info.optimization.optimization_parameter_scaling)

@time costLand(defaults, info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, land_stacked_prealloc, run_helpers.loc_land, run_helpers.tem_info, obs_array, tbl_params, cost_options, info.optimization.multi_constraint_method, info.optimization.optimization_parameter_scaling)