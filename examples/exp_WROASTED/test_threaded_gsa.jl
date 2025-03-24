using Revise
using Sindbad
using SindbadExperiment
using Plots
using QuasiMonteCarlo
using GlobalSensitivity
using StableRNGs
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
    "optimization.algorithm_sensitivity_analysis" => "sa_methods/GSA_Morris.json",
    "optimization.subset_model_output" => false,
    "optimization.optimization_cost_method" => "CostModelObsMT",
    "optimization.optimization_cost_threaded"  => true,
    "optimization.observations.default_observation.data_path" => path_observation)


out_sensitivity = runExperimentSensitivity(experiment_json; replace_info=replace_info);

# calls to look at inner objects in the experiment for dev purposes
info, forcing = prepExperiment(experiment_json; replace_info=replace_info);
observations = getObservation(info, forcing.helpers);

obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

opti_helpers = prepOpti(forcing, obs_array, info, info.optimization.optimization_cost_method; algorithm_info_field=:algorithm_sensitivity_analysis);

cost_function = opti_helpers.cost_function
p_bounds=Tuple.(Pair.(opti_helpers.lower_bounds,opti_helpers.upper_bounds));
method_options = info.optimization.algorithm_sensitivity_analysis.options;

sampler = getproperty(SindbadOptimization.GlobalSensitivity, Symbol(method_options.sampler))(; method_options.sampler_options..., method_options.method_options... )
results = gsa(cost_function, sampler, p_bounds; method_options..., batch=true)

