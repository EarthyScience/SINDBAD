using Revise
using SindbadTEM
toggleStackTraceNT()

domain = "africa";
optimize_it = true;
optimize_it = false;

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.spinup.run_spinup" => true);

experiment_json = "../exp_Africa/settings_Africa/experiment.json"

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

run_helpers = prepTEM(forcing, info);
@time runTEM!(info.tem.models.forward,
    run_helpers.forcing_nt_array,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.output_array,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.loc_space_inds,
    run_helpers.tem_with_types)

ds = forcing.data[1];
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

using Statistics
plotdat = run_helpers.output_array;
# pd = mean(plotdat[1], dims=1)
fig, ax, obj = heatmap(mean(plotdat[1]; dims=1)[1, 1, :, :])
Colorbar(fig[1, 2], obj)
save(joinpath(info.output.figure, "africa_gpp.png"), fig)
