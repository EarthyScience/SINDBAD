using Revise
@time using Sindbad
@time using SindbadTEM
@time using SindbadExperiment
using Plots
toggleStackTraceNT()
domain = "Global";
optimize_it = true;
optimize_it = false;

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.flags.spinup.run_spinup" => true);

experiment_json = "../exp_Trautmann2022/settings_Trautmann2022/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)

for x ∈ 1:10
    @time runTEM!(info.tem.models.forward,
        run_helpers.loc_forcings,
        run_helpers.loc_spinup_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types)
end

@time output_default = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  


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
        savefig(joinpath(info.output.figure, "glob_$(vname).png"))
    else
        foreach(axes(pd, 2)) do ll
            heatmap(pd[:, ll, :]; title="$(vname)" , size=(2000, 1000))
            # Colorbar(fig[1, 2], obj)
            savefig(joinpath(info.output.figure, "glob_$(vname)_$(ll).png"))
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
    heatmap(plot_data; title="$(v):: mean = $(round(SindbadTEM.mean(def_var), digits=2)), nans=$(sum(isnan.(plot_data)))", size=(2000, 1000))
    savefig(joinpath(info.output.figure, "forc_glob_$v.png"))
end


# @time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);
# opt_params = out_opti.out_params;
# out_model = out_opti.out_forward;
