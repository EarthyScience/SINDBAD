using Revise
@time using Sindbad
@time using ForwardSindbad
@time using OptimizeSindbad
using Plots
noStackTrace()
experiment_json = "../exp_landWrapper/settings_landWrapper/experiment.json"
sYear = "1979"
eYear = "2017"

domain = "DE-Hai"
# domain = "MY-PSO"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing


pl = "threads"
arraymethod = "staticarray"
replace_info = Dict("model_run.experiment_time.date_begin" => sYear * "-01-01",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "forcing.default_forcing.data_path" => path_input,
    "model_run.experiment_time.date_end" => eYear * "-12-31",
    "model_run.experiment_flags.run_optimization" => optimize_it,
    "model_run.experiment_flags.run_forward_and_cost" => true,
    "model_run.experiment_flags.spinup.save_spinup" => false,
    "model_run.experiment_flags.catch_model_errors" => false,
    "model_run.experiment_flags.spinup.run_spinup" => true,
    "model_run.experiment_flags.debug_model" => false,
    "model_run.experiment_rules.model_array_type" => arraymethod,
    "model_run.experiment_flags.spinup.do_spinup" => true,
    "model_run.output.path" => path_output,
    "model_run.output.format" => "nc",
    "model_run.output.save_single_file" => true,
    "model_run.mapping.parallelization" => pl,
    "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info);

@time TEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals)


@time lw_timeseries_prep = TEM(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem_with_vals);

@time lw_timeseries = TEM(forcing, info);

land_timeseries = Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size);

@time lw_timeseries_vec = TEM(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_timeseries, land_init_space[1], tem_with_vals);

# calculate the losses
observations = getObservation(info, forcing.helpers);
obs_array = getArray(observations);
@time getLossVector(obs_array, output_array, info.optim.cost_options) |> sum
@time getLossVector(obs_array, lw_timeseries_prep, info.optim.cost_options) |> sum
@time getLossVector(obs_array, lw_timeseries, info.optim.cost_options) |> sum
@time getLossVector(obs_array, lw_timeseries_vec, info.optim.cost_options) |> sum


tbl_params = Sindbad.getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize)

defaults = tbl_params.default

getLoss(defaults, info.tem.models.forward, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem_with_vals, obs_array, tbl_params, info.optim.cost_options, info.optim.multi_constraint_method)

getLoss(defaults, info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem_with_vals, obs_array, tbl_params, info.optim.cost_options, info.optim.multi_constraint_method)

getLoss(defaults, info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_timeseries, land_init_space[1], tem_with_vals, obs_array, tbl_params, info.optim.cost_options, info.optim.multi_constraint_method)


