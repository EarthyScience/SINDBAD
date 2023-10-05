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

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT)

# new_params = tbl_params.default;
new_params = getParamsAct(new_params, tbl_params)

models = info.tem.models.forward;
param_to_index = getParameterIndices(models, tbl_params);

models = LongTuple{10}(models...);
new_models = updateModelParameters(param_to_index, models, new_params)

@time runTEM!(new_models,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)


op = run_helpers.loc_outputs[1];
ov = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars)

lines(op[6][:,1])