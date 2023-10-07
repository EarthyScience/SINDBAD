using Revise
using SindbadTEM
toggleStackTraceNT()

domain = "Africa";
optimize_it = true;
optimize_it = false;

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.spinup_TEM" => true);

experiment_json = "../exp_Africa/settings_Africa/experiment.json"

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

run_helpers = prepTEM(forcing, info);
@time runTEM!(info.tem.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_with_types)

ds = forcing.data[1];
plotdat = run_helpers.output_array;
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
output_vars = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars)
for i ∈ eachindex(output_vars)
    v = output_vars[i]
    vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
    vname = vinfo["standard_name"]
    println("plot output-model => domain: $domain, variable: $vname")
    pd = plotdat[i]
    if size(pd, 2) == 1
        dt = mean(pd[:, 1, :, :], dims=1)[1, :, :]
        @show size(dt)
        heatmap(dt; title="$(vname)" , size=(2000, 1000))
        # Colorbar(fig[1, 2], obj)
        savefig(joinpath(info.output.figure, "glob_$(vname).png"))
    else
        foreach(axes(pd, 2)) do ll
            dt = mean(pd[:, ll, :, :], dims=1)[1, :, :]
            heatmap(dt; title="$(vname)" , size=(2000, 1000))
            # Colorbar(fig[1, 2], obj)
            savefig(joinpath(info.output.figure, "africa_spatial_$(vname)_$(ll).png"))
        end
    end
end