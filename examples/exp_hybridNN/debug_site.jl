using SindbadTEM
using JLD2
using SindbadML

toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "2000"
end_year = "2017"

domain = "US-WCr"

# load neural network and covariates in order to predict the new BAD? parameters
re_structure, flat_weights = load("./output_FLUXNET_Hybrid/train_sujan/seq_training_output_epoch_2.jld2", "re", "flat")

nn_model = re_structure(flat_weights)

c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr")); #"/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr"
xfeatures = yaxCubeToKeyedArray(c)

new_nn_parameters = nn_model(xfeatures)
new_params = new_nn_parameters(; site = domain) # unbounded, see later the scaling

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

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type)

# new_params = tbl_params.default;
new_params = getParamsAct(new_params, tbl_params)

models = info.models.forward;
param_to_index = getParameterIndices(models, tbl_params);

new_models = updateModelParameters(param_to_index, models, new_params)

@time runTEM!(new_models, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)


op = run_helpers.space_output[1];
ov = valToSymbol(run_helpers.tem_info.vals.output_vars)

lines(op[6][:,1])