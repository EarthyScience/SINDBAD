using Revise
using Sindbad
using ProgressMeter
noStackTrace()
domain = "DE-2";
optimize_it = true;
optimize_it = false;

replace_info_spatial = Dict(
    "experiment.domain" => domain * "_spatial",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "modelRun.mapping.yaxarray" => [],
    "modelRun.mapping.runEcosystem" => ["time", "latitude", "longitude"],
    "spinup.flags.doSpinup" => true
    ); #one parameter set for whole domain


replace_info_site = Dict(
    "experiment.domain" => domain * "_site",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
    "modelRun.mapping.yaxarray" => ["latitude", "longitude"],
    "modelRun.mapping.runEcosystem" => ["time"],
    "spinup.flags.doSpinup" => true
); #one parameter set per each site

experiment_json = "exp_optiSpace/settings_optiSpace/experiment.json";

run_output_spatial = runExperiment(experiment_json; replace_info=replace_info_spatial);

run_output_site = runExperiment(experiment_json; replace_info=replace_info_site);
