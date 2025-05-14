using Revise
using SindbadExperiment
# using CairoMakie

using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "2000"
end_year = "2017"

domain = "US-SRM"
# domain = "MY-PSO"
path_variable = "$(getSindbadDataDepot())/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_variable
optimize_it = true
# optimize_it = false
path_output = nothing

parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "forcing.default_forcing.data_path" => path_variable,
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

which_function = :compute
which_field = [:input, :output]
which_field = :input
# which_field = :output

fig = plotIOModelStructure(info)

for model_func in (:define, :precompute, :compute,)                 
    plotIOModelStructure(info, model_func)
end

fig = plotIOModelStructure(info, which_function, which_field)



