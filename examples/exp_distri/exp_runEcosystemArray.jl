using Revise
using Sindbad.Simulation
using Sindbad.Simulation
using Sindbad.DataLoaders
toggleStackTraceNT()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

# @time run_helpers = prepTEM(info.models.forward, forcing, observations, info);
@time run_helpers = prepTEM(forcing, info);

@time runTEM!(run_helpers.space_selected_models, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

@time output_default = runExperimentForward(experiment_json);
@time out_opti = runExperimentOpti(experiment_json);
opt_params = out_opti.parameters;
out_model = out_opti.output.forward;
