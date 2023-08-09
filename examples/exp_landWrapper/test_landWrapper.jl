using Revise
@time using SindbadOptimization
using Plots
noStackTrace()
experiment_json = "../exp_landWrapper/settings_landWrapper/experiment.json"
sYear = "1979"
eYear = "2017"

domain = "DE-Hai"
# domain = "MY-PSO"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing


parallelization_lib = "threads"
model_array_type = "staticarray"
replace_info = Dict("experiment.basics.time.date_begin" => sYear * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.basics.time.date_end" => eYear * "-12-31",
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

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals)

@time land_spin_now = runSpinup(info.tem.models.forward,
loc_forcings[1],
forcing_one_timestep,
land_init_space[1],
tem_with_vals.helpers,
tem_with_vals.models,
tem_with_vals.spinup, Val(:true));


@time land_spin_now = runSpinup(info.tem.models.forward,
loc_forcings[1],
forcing_one_timestep,
land_init_space[1],
tem_with_vals.helpers,
tem_with_vals.models,
tem_with_vals.spinup, DoRunSpinup());


@time land_spin_now = runSpinup(info.tem.models.forward,
loc_forcings[1],
forcing_one_timestep,
land_init_space[1],
tem_with_vals.helpers,
tem_with_vals.models,
tem_with_vals.spinup, DontRunSpinup());


@time lw_timeseries_prep = runTEM(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem_with_vals);

# function nanmean(a;dims=:)
#     init = (0,0.0)
#     r = foldl(a;init,dims) do (n,s),b
#         isnan(b) ? (n,s) : (n+1,s+b)
#     end
#     @show r
#     last.(r)/first.(r)
# end


@time lw_timeseries = runTEM(forcing, info);

land_timeseries = Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size);

@time lw_timeseries_vec = runTEM(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_timeseries, land_init_space[1], tem_with_vals);

# calculate the losses
observations = getObservation(info, forcing.helpers);
obs_array = getArray(observations);
cost_options = filterConstraintMinimumDatapoints(obs_array, info.optim.cost_options);

# @profview getLossVector(obs_array, output_array, cost_options) # |> sum
@time getLossVector(obs_array, output_array, cost_options) # |> sum
@time getLossVector(obs_array, lw_timeseries_prep, cost_options) # |> sum
@time getLossVector(obs_array, lw_timeseries, cost_options) # |> sum
@time getLossVector(obs_array, lw_timeseries_vec, cost_options) #|> sum


tbl_params = Sindbad.getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize)

defaults = tbl_params.default;

@time getLoss(defaults, info.tem.models.forward, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem_with_vals, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)

@time getLoss(defaults, info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem_with_vals, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)

@time getLoss(defaults, info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_timeseries, land_init_space[1], tem_with_vals, obs_array, tbl_params, cost_options, info.optim.multi_constraint_method)


