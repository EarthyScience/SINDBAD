using Revise
@time using SindbadExperiment
using Plots
toggleStackTraceNT()
domain = "africa";
optimize_it = true;
# optimize_it = false;

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.basics.config_files.forcing" => "forcing.json",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => optimize_it,
    "experiment.flags.catch_model_errors" => true,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.flags.spinup.run_spinup" => true);

experiment_json = "../exp_graf/settings_graf/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

GC.gc()

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)

for x ∈ 1:10
    @time runTEM!(info.tem.models.forward,
        run_helpers.loc_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types)
end

# setLogLevel(:debug)
# getLossVector(obs_array, run_helpers.output_array, prepCostOptions(obs_array, info.optim.cost_options))

@time output_default = runExperimentForward(experiment_json; replace_info=replace_info_spatial);
@time out_params = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);
# @time out_cost = runExperimentCost(experiment_json; replace_info=replace_info_spatial);


ds = forcing.data[1];
plotdat = run_helpers.output_array;
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
out_vars = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars)
for i ∈ eachindex(out_vars)
    v = out_vars[i]
    vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
    vname = vinfo["standard_name"]
    println("plot output-model => domain: $domain, variable: $vname")
    pd = plotdat[i]
    if size(pd, 2) == 1
        heatmap(pd[:, 1, :]; title="$(vname)" , size=(2000, 1000))
        # Colorbar(fig[1, 2], obj)
        savefig(joinpath(info.output.figure, "afr2d_$(vname).png"))
    else
        foreach(axes(pd, 2)) do ll
            heatmap(pd[:, ll, :]; title="$(vname)" , size=(2000, 1000))
            # Colorbar(fig[1, 2], obj)
            savefig(joinpath(info.output.figure, "afr2d_$(vname)_$(ll).png"))
        end
    end
end

default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
forc_vars = forcing.variables
for (o, v) in enumerate(forc_vars)
    println("plot forc-model => domain: $domain, variable: $v")
    def_var = forcing.data[o]
    plot_data=nothing
    xdata = [info.tem.helpers.dates.range...]
    if size(def_var, 1) !== length(xdata)
        xdata = 1:size(def_var, 1)
        plot_data =  def_var[:]
        plot_data = reshape(plot_data, (1,length(plot_data)))
    else
        plot_data =  def_var[:,:]
    end
    heatmap(plot_data; title="$(v):: mean = $(round(SindbadTEM.mean(def_var), digits=2)), nans=$(sum(isInvalid.(plot_data)))", size=(2000, 1000))
    savefig(joinpath(info.output.figure, "forc_afr2d_$v.png"))
end
