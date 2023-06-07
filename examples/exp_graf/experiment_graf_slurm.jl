using SlurmClusterManager
using Distributed
addprocs(SlurmManager())
addprocs(16)
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__,"../exp_distri/"))

@everywhere using Sindbad
@everywhere using ForwardSindbad
# using HybridSindbad
@everywhere using ThreadPools
@everywhere using Zarr
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

noStackTrace()
@everywhere domain = "africa";
# @everywhere optimize_it = true;
@everywhere optimize_it = false;

@everywhere replace_info_spatial = Dict(
    "experiment.domain" => domain * "_spatial",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "modelRun.mapping.yaxarray" => [],
    "modelRun.mapping.runEcosystem" => ["time", "id"],
    "spinup.flags.doSpinup" => true
    ); #one parameter set for whole domain


@everywhere replace_info_site = Dict(
    "experiment.domain" => domain * "_site",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "modelRun.mapping.yaxarray" => ["id"],
    "modelRun.mapping.runEcosystem" => ["time"],
    "spinup.flags.doSpinup" => true
); #one parameter set per each site

@everywhere experiment_json = "../exp_graf/settings_graf/experiment.json";

@everywhere info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify info
@everywhere obs = ForwardSindbad.getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
@everywhere forcing = ForwardSindbad.getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# chunkeddata = setchunks.(forcing.data, ((id=1,),));
# forcing = (; forcing..., data = (chunkeddata));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
@everywhere output = setupOutput(info, forcing.sizes);

@everywhere forc = getKeyedArrayFromYaxArray(forcing);
# @code_warntype runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
# @profview runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
# @benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);
@time runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);

# runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);

# info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify info
# info = getExperimentInfo(experiment_json) # note that the modification will not work with this
# forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
# output = setupOutput(info, forcing.sizes);


# run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);

# run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
