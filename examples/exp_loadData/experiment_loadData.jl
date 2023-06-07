using Revise
using Sindbad

noStackTrace()
experiment_json = "exp_loadData/settings_loadData/experiment.json"
sYear = "1979"
eYear = "2017"
inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
obspath = inpath
forcingConfig = "forcing_erai.json"
optimize_it = false
outpath = nothing
domain = "DE-Hai"

replace_info = Dict(
    "modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "spinup.flags.saveSpinup" => true,
    "spinup.flags.loadSpinup" => true,
    "forcing.default_forcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "opti.constraints.oneDataPath" => obspath
);

run_output = runExperiment(experiment_json; replace_info=replace_info);


# run with saved jld2 file
experiment_jld2 = "exp_loadData/info.jld2"
replace_info["outpath"]="jld2"
run_output = runExperiment(experiment_jld2); #this one will only work if the replace fields are not passed because of isses with merging namedtuple and dict, and/or conversion of named tuple to dictionary

# one can load info directly from file and run the experiment by skipping the get configuration by continuing with
info=Sindbad.load("info.jld2")["info"];
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info, forcing.sizes)

