using Revise
using SindbadExperiment
using SindbadTEM
using SindbadData
toggleStackTraceNT()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_with_types)

@time output_default = runExperimentForward(experiment_json);
@time out_opti = runExperimentOpti(experiment_json);
opt_params = out_opti.out_params;
out_model = out_opti.out_forward;
