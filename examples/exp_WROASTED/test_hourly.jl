using Revise
using Sindbad
using SindbadExperiment
using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "1999"
end_year = "2010"

domain = "CA-Obs"
path_input = nothing
forcing_config = nothing
mod_step = "day"
mod_step = "hour"
# foreach(["day", "hour"]) do mod_step
if mod_step == "day"
    path_input = "../data/fn/$(domain).1979.2017.daily.nc"
    forcing_config = "forcing_erai.json"
else
    mod_step
    path_input = "../data/CA-Obs.1999.2010.hourly_for_Sindbad.nc"
    forcing_config = "forcing_hourly.json"
end

path_observation = path_input
optimize_it = false
# optimize_it = false
path_output = nothing


parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
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
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm_optimization" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.observations.default_observation.data_path" => path_observation)

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

tbl_params = getParameters(info.models.forward,
    info.optimization.model_parameter_default,
    info.optimization.model_parameters_to_optimize,
    info.helpers.numbers.num_type,
    info.helpers.dates.temporal_resolution)

forcing = getForcing(info);

run_helpers = prepTEM(forcing, info);
@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info);

@time output_all = runExperimentFullOutput(experiment_json; replace_info=replace_info);
output_data = values(output_all.output)
info = output_all.info
output_vars = info.output.variables
# plot the debug figures
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
fig_prefix = joinpath(info.output.dirs.figure, "debug_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)
for (o, v) in enumerate(output_vars)
    def_var = output_data[o][:, :, 1, 1]
    vinfo = getVariableInfo(v, info.experiment.basics.temporal_resolution)
    v = vinfo["standard_name"]
    println("plot debug::", v)
    xdata = [info.helpers.dates.range...]
    if size(def_var, 2) == 1
        plot(xdata, def_var[:, 1]; label="def ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
        ylabel!("$(vinfo["standard_name"])", font=(20, :green))
        savefig(fig_prefix * "_$(v).png")
    else
        foreach(axes(def_var, 2)) do ll
            plot(xdata, def_var[:, ll]; label="def ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
            ylabel!("$(vinfo["standard_name"])", font=(20, :green))
            savefig(fig_prefix * "_$(v)_$(ll).png")
        end
    end
end

default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
forc_vars = forcing.variables
for (o, v) in enumerate(forc_vars)
    println("plot forc-model => domain: $domain, variable: $v")
    def_var = forcing.data[o]
    plot_data = nothing
    xdata = [info.helpers.dates.range...]
    if size(def_var, 1) !== length(xdata)
        xdata = 1:size(def_var, 1)
        plot_data = def_var[:, 1, 1]
        # plot_data = reshape(plot_data, (1,length(plot_data)))
    else
        plot_data = def_var[:, 1, 1]
    end
    plot(xdata, plot_data; title="$(v):: mean = $(round(SindbadTEM.mean(plot_data), digits=2)), nans=$(sum(isnan.(plot_data)))", size=(2000, 1000))
    savefig(fig_prefix * "_forc_$(v).png")
end
