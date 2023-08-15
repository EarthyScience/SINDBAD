using Revise
using SindbadExperiment
toggleStackTraceNT()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

obs_array = [Array(_o) for _o in observations.data]; # TODO: neccessary now for performance because view of keyedarray is slow

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

@time output_default = runExperimentForward(experiment_json);
@time out_params = runExperimentOpti(experiment_json);
