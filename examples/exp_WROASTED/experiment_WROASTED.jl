using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "2000"
eYear = "2017"

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# inpath = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
inpath = "../data/BE-Vie.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
obspath = inpath
optimize_it = true
optimize_it = false
outpath = nothing

domain = "DE-Hai"
pl = "threads"
replace_info = Dict(
    "modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "spinup.flags.saveSpinup" => false,
    "modelRun.flags.catchErrors" => true,
    "modelRun.flags.runSpinup" => true,
    "modelRun.flags.debugit" => false,
    "spinup.flags.doSpinup" => true,
    "forcing.default_forcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl,
    "opti.constraints.oneDataPath" => obspath
);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);

info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
linit= createLandInit(info.pools, info.tem);

loc_space_maps, land_init_space, f_one  = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one)


@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info);  


@time outparams = runExperimentOpti(experiment_json; replace_info=replace_info);  

tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);
new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams);
output = setupOutput(info);
@time runEcosystem!(output.data, new_models, forc, info.tem, loc_space_maps, land_init_space, f_one)



# some plots
ds = forcing.data[1];
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
site = 1


plotdat = output.data;
fig, ax, obj = plot(plotdat[2][:,1,1,1])
plot!(obs.gpp[:,1,1,1])
# Colorbar(fig[1,2], obj)
save("gpp.png", fig)