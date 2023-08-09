using SlurmClusterManager
using Distributed
addprocs(SlurmManager())
addprocs(16)
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__, "../exp_distri/"))

@everywhere using Sindbad
@everywhere using SindbadTEM
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

noStackTrace()
@everywhere domain = "africa";
# @everywhere optimize_it = true;
@everywhere optimize_it = false;

@everywhere replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.spinup.run_spinup" => true);

@everywhere replace_info_site = Dict("experiment.basics.domain" => domain * "_site",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.spinup.run_spinup" => true); #one parameter set per each site

@everywhere experiment_json = "../exp_graf/settings_graf/experiment.json";

@everywhere info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
@everywhere obs = SindbadTEM.getObservation(info, forcing.helpers);
@everywhere info, forcing = SindbadTEM.getForcing(info);
# chunkeddata = setchunks.(forcing.data, ((id=1,),));
# forcing = (; forcing..., data = (chunkeddata));


# runTEM!(output_array, output.land_init, info.tem.models.forward, forcing_nt_array, info.tem);

# info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
# info = getExperimentInfo(experiment_json) # note that the modification will not work with this
# forcing = getForcing(info);

# 

# run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);

# run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
