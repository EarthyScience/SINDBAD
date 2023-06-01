using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Cthulhu
using BenchmarkTools
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# inpath = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
inpath = "../data/DE-2.1979.2017.daily.nc"
forcingConfig = "forcing_DE-2.json"
# inpath = "/Net/Groups/BGI/scratch/skoirala/sindbad.jl/examples/data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
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
    "modelRun.flags.debugit" => false,
    "modelRun.flags.runSpinup" => true,
    "modelRun.flags.debugit" => false,
    "spinup.flags.doSpinup" => true,
    "forcing.defaultForcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl,
    "opti.constraints.oneDataPath" => obspath
);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
linit= createLandInit(info.pools, info.tem);

Sindbad.eval(:(error_catcher = []))    
loc_space_maps, land_init_space, f_one  = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, info.tem);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one)
@time outcubes = runExperimentOpti(experiment_json; replace_info=replace_info);  

forcing, output, output_variables, observations, tblParams, tem, optim, loc_space_maps, land_init_space, f_one = Sindbad.error_catcher[1];
a