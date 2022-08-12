using Revise
using Sindbad

noStackTrace()

site_index = 1
site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
# site_index = Base.parse(Int, ARGS[1])
forcing="erai"
site_info=Sindbad.CSV.File("/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/fluxnet_sites_info/site_info_$(forcing).csv", header=false);
domain=site_info[site_index][2]

experiment_json = "exp_WROASTED/settings_WROASTED/experiment.json";
inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/$(domain).1979.2017.daily.nc";
obspath = inpath;
forcingConfig="forcing_$(forcing).json";
optimize_it = true;
outpath="/Net/Groups/BGI/scratch/skoirala/wroasted_sjindbad";


replace_info = Dict(
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "experiment.name" => "WROASTED_T1",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "spinup.flags.saveSpinup" => false,
    "forcing.defaultForcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "opti.constraints.oneDataPath" => obspath
    );


run_output = runExperiment(experiment_json; replace_info=replace_info);

doitstepwise = false
if doitstepwise
    info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
    # info = getExperimentInfo(experiment_json) # note that the modification will not work with this
    forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))
    # spinup_forcing = getSpinupForcing(forcing, info.tem);
    output = setupOutput(info)

    # forward run
    outcubes = mapRunEcosystem(forcing, output, info.tem, info.models.forward; max_cache=info.modelRun.rules.yax_max_cache)

    # optimization
    observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)))
    res = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
        ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
end