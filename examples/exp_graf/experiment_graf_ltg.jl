using Revise
@time using SindbadExperiment
using Plots
toggleStackTraceNT()
domain = "africa";
optimize_it = true;
# optimize_it = false;

replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
    "experiment.basics.config_files.forcing" => "forcing.json",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => optimize_it,
    "experiment.flags.catch_model_errors" => true,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false);

experiment_json = "../exp_graf/settings_graf/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

GC.gc()

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward, run_helpers.loc_forcings, run_helpers.loc_spinup_forcings, run_helpers.forcing_one_timestep, run_helpers.loc_outputs, run_helpers.land_init_space, run_helpers.tem_with_types)

mods = makeLongTuple(info.tem.models.forward, 15);

@time runTEM!(mods,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)
for x ∈ 1:10
    @time runTEM!(info.tem.models.forward,
        run_helpers.loc_forcings,
        run_helpers.loc_spinup_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types)
    @time runTEM!(mods,
        run_helpers.loc_forcings,
        run_helpers.loc_spinup_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types)
    println("---------")
end

