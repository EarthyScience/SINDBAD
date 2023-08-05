using Revise
using Sindbad
using ForwardSindbad
noStackTrace()

domain = "africa";
optimize_it = true;
optimize_it = false;

# experiment_json = "./settings_distri/experimentW.json"
# info = getConfiguration(experiment_json);
# info = setupExperiment(info);

replace_info_spatial = Dict("experiment.domain" => domain * "_spatial",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => false,
    "model_run.mapping.yaxarray" => [],
    "model_run.mapping.run_ecosystem" => ["time", "latitude", "longitude"],
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.spinup.do_spinup" => true);

experiment_json = "../exp_Africa/settings_Africa/experiment.json"

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(forcing, info);
@time runEcosystem!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

ds = forcing.data[1];
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

using Statistics
plotdat = output_array;
# pd = mean(plotdat[1], dims=1)
fig, ax, obj = heatmap(mean(plotdat[1]; dims=1)[1, 1, :, :])
Colorbar(fig[1, 2], obj)
save(joinpath(info.output.figure, "africa_gpp.png"), fig)
