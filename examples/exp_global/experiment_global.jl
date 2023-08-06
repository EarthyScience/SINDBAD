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

replace_info_spatial = Dict("experiment.domain" => domain * "_spatial",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.mapping.yaxarray" => [],
    "model_run.mapping.run_ecosystem" => ["time", "id"],
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.flags.spinup.do_spinup" => true);

experiment_json = "../exp_global/settings_global/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepSimulation(forcing, info);

@time simulateEcosystem!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

for x ∈ 1:10
    @time simulateEcosystem!(output_array,
        info.tem.models.forward,
        forcing_nt_array,
        tem_with_vals,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end

@profview simulateEcosystem!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time output_default = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  
@time out_params = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);
