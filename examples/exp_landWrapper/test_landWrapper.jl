using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
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
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "forcing.default_forcing.data_path" => path_input,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.catch_model_errors" => false,
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.rules.model_array_type" => arraymethod,
    "model_run.flags.spinup.do_spinup" => true,
    "model_run.output.path" => path_output,
    "model_run.output.format" => "nc",
    "model_run.output.save_single_file" => true,
    "model_run.mapping.parallelization" => pl,
    "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.constraints.default_constraint.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one = prepTEM(forcing, info);

@time TEM!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    tem_with_vals)

@time lw_timeseries_prep = TEM(info.tem.models.forward, loc_forcings[1], land_init_space[1], f_one, tem_with_vals);

@time lw_timeseries = TEM(forcing, info);

land_timeseries = Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size);

@time lw_timeseries_vec = TEM(land_timeseries, info.tem.models.forward, loc_forcings[1], land_init_space[1], f_one, tem_with_vals);

observations = getObservation(info, forcing.helpers);
obs_array = getArray(observations);
@time getLossVector(obs_array, output_default, info.optim.cost_options) |> sum
@time getLossVector(obs_array, lw_timeseries_prep, info.optim.cost_options) |> sum
@time getLossVector(obs_array, lw_timeseries, info.optim.cost_options) |> sum
@time getLossVector(obs_array, lw_timeseries_vec, info.optim.cost_options) |> sum
