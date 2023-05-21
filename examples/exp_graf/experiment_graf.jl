using Revise 
# using YAXArrays
@time using Sindbad
@time using ForwardSindbad
# @time using OptimizeSindbad
# @time using HybridSindbad
using ThreadPools
using AxisKeys
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
using Zarr
using BenchmarkTools
# noStackTrace()
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
    "modelRun.mapping.runEcosystem" => ["time", "id"],
    "modelRun.flags.runSpinup" => true,
    "spinup.flags.doSpinup" => true
    ); #one parameter set for whole domain


replace_info_site = Dict(
    "experiment.domain" => domain * "_site",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "modelRun.mapping.yaxarray" => ["id"],
    "modelRun.mapping.runEcosystem" => ["time"],
    "modelRun.flags.runSpinup" => true,
    "spinup.flags.doSpinup" => true
); #one parameter set per each site

experiment_json = "../exp_graf/settings_graf/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify info
# obs = ForwardSindbad.getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# chunkeddata = setchunks.(forcing.data, ((id=1,),));
# forcing = (; forcing..., data = (chunkeddata));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);


forc = getKeyedArrayFromYaxArray(forcing);
# @code_warntype runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);

GC.gc()

additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list = prepRunEcosystem(output.data, info.tem.models.forward, forc, info.tem);
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list)
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);


@benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list)


@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
@benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem)
@profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);

a=1
# info = getExperimentInfo(experiment_json) # note that the modification will not work with this
# forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
# output = setupOutput(info);
# obs = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));


# @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  
@time outcubes = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);  
# @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info_site);  

# run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);


# run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
