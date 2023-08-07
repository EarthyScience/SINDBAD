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
    "model_run.experiment_flags.run_optimization" => optimize_it,
    "model_run.experiment_flags.run_forward_and_cost" => true,
    "model_run.experiment_flags.spinup.do_spinup" => true);

@everywhere replace_info_site = Dict("experiment.domain" => domain * "_site",
    "model_run.experiment_flags.run_optimization" => optimize_it,
    "model_run.experiment_flags.run_forward_and_cost" => false,
    "model_run.experiment_flags.spinup.do_spinup" => true); #one parameter set per each site

@everywhere experiment_json = "../exp_graf/settings_graf/experiment.json";

@everywhere info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
@everywhere obs = ForwardSindbad.getObservation(info, forcing.helpers);
@everywhere info, forcing = ForwardSindbad.getForcing(info);
# chunkeddata = setchunks.(forcing.data, ((id=1,),));
# forcing = (; forcing..., data = (chunkeddata));


# TEM!(output_array, output.land_init, info.tem.models.forward, forcing_nt_array, info.tem);

# info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
# info = getExperimentInfo(experiment_json) # note that the modification will not work with this
# forcing = getForcing(info);

# 

# run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);

# run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
