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

replace_info_spatial = Dict(
    "experiment.domain" => domain * "_spatial",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "modelRun.mapping.yaxarray" => [],
    "modelRun.mapping.runEcosystem" => ["time", "latitude", "longitude"],
    "modelRun.flags.runSpinup" => true,
    "spinup.flags.doSpinup" => true
    ); #one parameter set for whole domain


experiment_json = "../exp_Africa/settings_Africa/experiment.json"

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify info
# obs = ForwardSindbad.getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
output = setupOutput(info);


forc = getKeyedArrayFromYaxArray(forcing);

GC.gc()

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)

ds = forcing.data[1];
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

using Statistics
plotdat = output.data;
# pd = mean(plotdat[1], dims=1)
fig, ax, obj = heatmap(mean(plotdat[1], dims=1)[1, 1, :, :])
Colorbar(fig[1,2], obj)
save("afroca_gpp.png", fig)
