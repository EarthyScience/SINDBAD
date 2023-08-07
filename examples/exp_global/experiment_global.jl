using Revise
@time using Sindbad
@time using ForwardSindbad
# @time using OptimizeSindbad
noStackTrace()
domain = "global";
optimize_it = true;
optimize_it = false;

# experiment_json = "./settings_distri/experimentW.json"
# info = getConfiguration(experiment_json);
# info = setupExperiment(info);

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.run_forward_and_cost" => true,
    "experiment.flags.spinup.run_spinup" => true,
    "experiment.flags.debug_model" => false,
    "experiment.flags.spinup.do_spinup" => true);

experiment_json = "../exp_global/settings_global/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals)

for x ∈ 1:10
    @time runTEM!(info.tem.models.forward,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem_with_vals)
end

@profview runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals)

# @time output_default = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  
@time out_params = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);
