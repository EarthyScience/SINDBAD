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
path_output = nothing

parallelization_lib = "threads"
model_array_type = "static_array"

replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => false,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm_optimization" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.observations.default_observation.data_path" => path_observation,
    );

use_preloaded_table = true
use_preloaded_table = false
if use_preloaded_table
    # create a new parameter table and perturb the parameters
    param_local = "/Users/skoirala/research/RnD/SINDBAD-RnD/examples/exp_WROASTED/settings_WROASTED/test_params.csv"
    prm = Table(CSV.File(param_local));
    prm_optimized = prm.optimized;
    prm_optimized = perturbParameters(prm_optimized, prm.lower, prm.upper);
    prm.optimized .= prm_optimized;
    replace_info["experiment.basics.name"] = "load_params_table";
    replace_info["model_structure.parameter_table"] = prm;
else
    replace_info["experiment.basics.name"] = "read_params_table";
    replace_info["experiment.basics.config_files.parameters"] = "test_params.csv";
end
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

full_table = info.models.parameter_table;
optim_table = info.optimization.parameter_table


@time output_cost = runExperimentCost(experiment_json; replace_info=replace_info);

# table
# (:gpp => :NSEInv) => 0.47613645f0
# (:nee => :NSEInv) => 0.9576179f0
# (:reco => :NSEInv) => 1.0997446f0
# (:transpiration => :NSEInv) => 0.30825257f0
# (:evapotranspiration => :NSEInv) => 0.19294018f0
# (:agb => :NMAE1R) => 0.83479637f0
# (:ndvi => :NSEInv) => 0.9943638f0

# from file
# (:gpp => :NSEInv) => 0.50048655f0
# (:nee => :NSEInv) => 0.9677489f0
# (:reco => :NSEInv) => 0.9784876f0
# (:transpiration => :NSEInv) => 0.31356382f0
# (:evapotranspiration => :NSEInv) => 0.19330722f0
# (:agb => :NMAE1R) => 0.8624811f0
# (:ndvi => :NSEInv) => 0.98948f0