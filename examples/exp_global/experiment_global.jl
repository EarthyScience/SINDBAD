using Revise
@time using Sindbad
@time using SindbadTEM
@time using SindbadExperiment
toggleStackTraceNT()
domain = "global";
optimize_it = true;
optimize_it = false;

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.flags.spinup.run_spinup" => true);

experiment_json = "../exp_global/settings_global/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);

GC.gc()

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    run_helpers.forcing_nt_array,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.output_array,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.loc_space_inds,
    run_helpers.tem_with_types)

for x ∈ 1:10
    @time runTEM!(info.tem.models.forward,
        run_helpers.forcing_nt_array,
        run_helpers.loc_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.output_array,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.loc_space_inds,
        run_helpers.tem_with_types)
end

@profview runTEM!(info.tem.models.forward,
    run_helpers.forcing_nt_array,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.output_array,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.loc_space_inds,
    run_helpers.tem_with_types)

# @time output_default = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  
@time out_params = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);
