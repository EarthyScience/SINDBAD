using SindbadData
using SindbadTEM

experiment_json = "../exp_repacking/settings_repacking/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

#obs_array = getKeyedArrayWithNames(observations);
#obsv = getKeyedArray(observations);

land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = prepTEMOut(info, forcing.helpers);

forcing_nt_array,
loc_forcings,
forcing_one_timestep,
output_array,
loc_outputs,
land_init_space,
loc_space_inds,
loc_space_maps,
loc_space_names,
tem_with_types = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_types)

    