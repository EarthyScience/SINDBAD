using Revise
using Sindbad
using SindbadExperiment
using Plots
using QuasiMonteCarlo
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
param_set_size = 2000

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
    "optimization.subset_model_output" => false,
    "optimization.optimization_cost_threaded" => param_set_size,
    "optimization.observations.default_observation.data_path" => path_observation)

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

run_helpers = prepTEM(forcing, info);
# @time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info);

observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because 

table_parameters = info.optimization.table_parameters;
defaults = table_parameters.default;

param_samples = QuasiMonteCarlo.sample(param_set_size, table_parameters.lower, table_parameters.upper, LatinHypercubeSample());
cost_samples_c = Array{Float32}(undef, param_set_size) # cost_func
cost_samples_b = Array{Float32}(undef, param_set_size) # brute/serial
cost_samples_s = Array{Float32}(undef, param_set_size) # spawn
cost_samples_t = Array{Float32}(undef, param_set_size) # threaded


cost_options = prepCostOptions(obs_array, info.optimization.cost_options);
parameter_scaling_type = info.optimization.optimization_parameter_scaling
multi_constraint_method = info.optimization.multi_constraint_method
param_updater = table_parameters


space_index = 1

p_indices = eachindex(1:param_set_size)
@time cost_samples_q = qbmap(p_indices) do param_index 
    idx = Threads.threadid()
    vector_parameters = param_samples[:, param_index]
    updated_models = updateModels(vector_parameters, param_updater, parameter_scaling_type, info.models.forward)
    coreTEM!(updated_models, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.space_output_mt[idx], run_helpers.space_land[space_index], run_helpers.tem_info)
    cost_vector = metricVector(run_helpers.space_output_mt[idx], obs_array, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    # cost_samples_t[param_index] = cost_metric
    @info "qbmap: idx: $(idx), param_index: $(param_index), cost: $(cost_metric)"
    cost_metric
end

@time Threads.@threads for param_index in eachindex(1:param_set_size)
    idx = Threads.threadid()
    vector_parameters = param_samples[:, param_index]
    updated_models = updateModels(vector_parameters, param_updater, parameter_scaling_type, info.models.forward)
    coreTEM!(updated_models, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.space_output_mt[idx], run_helpers.space_land[space_index], run_helpers.tem_info)
    cost_vector = metricVector(run_helpers.space_output_mt[idx], obs_array, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    cost_samples_t[param_index] = cost_metric
    @info "@threads: idx: $(idx), param_index: $(param_index), cost: $(cost_metric)"
end

param_indices = 1:param_set_size

@sync begin
    for idx in eachindex(param_indices)
        Threads.@spawn begin
            param_index = param_indices[idx]
            vector_parameters = param_samples[:, param_index]
            updated_models = updateModels(vector_parameters, param_updater, parameter_scaling_type, info.models.forward)
            coreTEM!(updated_models, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.space_output_mt[param_index], run_helpers.space_land[space_index], run_helpers.tem_info)
            cost_vector = metricVector(run_helpers.space_output_mt[param_index], obs_array, cost_options)
            cost_metric = combineMetric(cost_vector, multi_constraint_method)
            @info "@spawn: idx: $(idx), param_index: $(param_index), cost: $(cost_metric)"
            cost_samples_s[param_index] = cost_metric
        end
    end
end


@time cost(param_samples, defaults, info.models.forward, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output_mt, run_helpers.space_land[space_index], run_helpers.tem_info, obs_array, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, cost_samples_c,  CostModelObsMT())
for idx in eachindex(cost_samples_c) 
    cost_metric = cost_samples_c[idx]
    @info "@costfunction: idx: $(idx), cost: $(cost_metric)"
    idx += 1
end



fig=plot(cost_samples_t, label="threads loop : diff-threads = $(sum(cost_samples_t - cost_samples_t))", size=(2000, 1000))
plot!(cost_samples_c, label="threaded cost : diff-threads = $(sum(cost_samples_t - cost_samples_c))")
plot!(cost_samples_q, label="qbmap cost : diff-threads = $(sum(cost_samples_t - cost_samples_q))")
plot!(cost_samples_s, label="spawn cost : diff-threads = $(sum(cost_samples_t - cost_samples_s))")

cost_samples_t - cost_samples_c |> sum

do_serial = true
# do_serial = false
if do_serial
    @time for param_index in param_indices
        idx = param_index
        vector_parameters = param_samples[:, param_index]
        updated_models = updateModels(vector_parameters, param_updater, parameter_scaling_type, info.models.forward)
        coreTEM!(updated_models, run_helpers.space_forcing[space_index], run_helpers.space_spinup_forcing[space_index], run_helpers.loc_forcing_t, run_helpers.space_output_mt[idx], run_helpers.space_land[space_index], run_helpers.tem_info)
        cost_vector = metricVector(run_helpers.space_output_mt[idx], obs_array, cost_options)
        cost_metric = combineMetric(cost_vector, multi_constraint_method)
        cost_samples_b[param_index] = cost_metric
        @info "serial: idx: $(idx), param_index: $(param_index), cost: $(cost_metric)"
    end
    plot!(cost_samples_b, label="serial cost : diff-threads = $(sum(cost_samples_t - cost_samples_b))")
end
savefig(joinpath(info.output.dirs.figure, "comparison_threads_$(param_set_size).png"))

fig