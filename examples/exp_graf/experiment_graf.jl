using Revise 
using YAXArrays
using Sindbad
using ForwardSindbad
# using HybridSindbad
using ThreadPools
using AxisKeys
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
using Zarr
using BenchmarkTools
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
    "modelRun.flags.calcCost" => false,
    "modelRun.mapping.yaxarray" => [],
    "modelRun.mapping.runEcosystem" => ["time", "id"],
    "spinup.flags.doSpinup" => true
    ); #one parameter set for whole domain


replace_info_site = Dict(
    "experiment.domain" => domain * "_site",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "modelRun.mapping.yaxarray" => ["id"],
    "modelRun.mapping.runEcosystem" => ["time"],
    "spinup.flags.doSpinup" => true
); #one parameter set per each site

experiment_json = "../exp_graf/settings_graf/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify info
# obs = ForwardSindbad.getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
forcing = ForwardSindbad.getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# chunkeddata = setchunks.(forcing.data, ((id=1,),));
# forcing = (; forcing..., data = (chunkeddata));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

forc, out = getDataUsingMapCube(forcing, output, info.tem; max_cache=1e12);
# @code_warntype runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);

# info = getExperimentInfo(experiment_json) # note that the modification will not work with this
# forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
# output = setupOutput(info);



run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);

# run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
