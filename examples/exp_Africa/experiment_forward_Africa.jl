using Revise
using SindbadTEM
noStackTrace()

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

ds = forcing.data[1];
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

using Statistics
plotdat = output_array;
# pd = mean(plotdat[1], dims=1)
fig, ax, obj = heatmap(mean(plotdat[1]; dims=1)[1, 1, :, :])
Colorbar(fig[1, 2], obj)
save(joinpath(info.output.figure, "africa_gpp.png"), fig)
