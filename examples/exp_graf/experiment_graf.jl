using Revise 
@time using Sindbad
@time using ForwardSindbad
# @time using OptimizeSindbad
# @time using HybridSindbad
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
output = setupOutput(info);


forc = getKeyedArrayFromYaxArray(forcing);

GC.gc()

loc_space_maps, land_init_space, f_one, loc_forcing, loc_output  = prepRunEcosystem(output.data, info.tem.models.forward, forc, info.tem);
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one, loc_forcing, loc_output)
for x=1:10
    @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one, loc_forcing, loc_output)
end
@profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one, loc_forcing, loc_output)
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);



# @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  
@time outcubes = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);  
# @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info_site);  
