using Revise
using Sindbad

noStackTrace()
experiment_json = "exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"
inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
obspath = inpath
forcingConfig = "forcing_erai.json"
optimize_it = true
outpath = nothing
domain = "DE-Hai"

replace_info = Dict(
    "modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "spinup.flags.saveSpinup" => false,
    # "forcing.defaultForcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    # "opti.constraints.oneDataPath" => obspath
);

output = setupOutput(info)

run_output=nothing

doitstepwise = true
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
run_output = runExperiment(experiment_json; replace_info=replace_info);
if doitstepwise
    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info
    # info = getExperimentInfo(experiment_json) # note that the modification will not work with this
    forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))
    # spinup_forcing = getSpinupForcing(forcing, info.tem);
    output = setupOutput(info)

    # forward run
    if optimize_it
        # optimization
        observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)))
        run_output = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
            ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
    else
        run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache)
    end
else
    run_output = runExperiment(experiment_json; replace_info=replace_info);
end