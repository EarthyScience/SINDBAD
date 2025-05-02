using Revise
using SindbadExperiment
using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "2000"
end_year = "2017"

domain = "DE-Hai"
# domain = "MY-PSO"
path_input = "$(getSindbadDataDepot())/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_input
optimize_it = true
# optimize_it = false
path_output = nothing

parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.name" => "readparameter_bounds",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.config_files.parameters" => "test_params.csv",
    "experiment.basics.domain" => domain,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm_optimization" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.observations.default_observation.data_path" => path_observation);
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info
    
full_table = info.models.parameter_table;
optim_table = info.optimization.parameter_table

forcing = getForcing(info);
run_helpers = prepTEM(forcing, info);
@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

@time output_default = runExperimentForward(experiment_json; replace_info=replace_info);
@time output_cost = runExperimentCost(experiment_json; replace_info=replace_info);
@time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info);
