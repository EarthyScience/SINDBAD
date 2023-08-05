using SlurmClusterManager
using Distributed
addprocs(SlurmManager())
addprocs(16)
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__, "../exp_distri/"))

@everywhere using Sindbad
@everywhere using ForwardSindbad
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

noStackTrace()
@everywhere domain = "africa";
# @everywhere optimize_it = true;
@everywhere optimize_it = false;

@everywhere replace_info_spatial = Dict("experiment.domain" => domain * "_spatial",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.mapping.yaxarray" => [],
    "model_run.mapping.run_ecosystem" => ["time", "id"],
    "model_run.flags.spinup.do_spinup" => true);

@everywhere replace_info_site = Dict("experiment.domain" => domain * "_site",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => false,
    "model_run.mapping.yaxarray" => ["id"],
    "model_run.mapping.run_ecosystem" => ["time"],
    "model_run.flags.spinup.do_spinup" => true); #one parameter set per each site

@everywhere experiment_json = "../exp_graf/settings_graf/experiment.json";

@everywhere info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
@everywhere obs = ForwardSindbad.getObservation(info, forcing.helpers);
@everywhere info, forcing = ForwardSindbad.getForcing(info);
# chunkeddata = setchunks.(forcing.data, ((id=1,),));
# forcing = (; forcing..., data = (chunkeddata));

@everywhere output = setupOutput(info, forcing.helpers);

@everywhere forc = getKeyedArrayWithNames(forcing);
# @code_warntype runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
# @profview runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
# @benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);
@time runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);

# runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);

# info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
# info = getExperimentInfo(experiment_json) # note that the modification will not work with this
# forcing = getForcing(info);

# output = setupOutput(info, forcing.helpers);

# run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);

# run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
