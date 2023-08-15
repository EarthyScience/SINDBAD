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

tem = (;
    tem_helpers = tem_with_types.helpers,
    tem_models = tem_with_types.models,
    tem_spinup = tem_with_types.spinup,
    tem_run_spinup = tem_with_types.helpers.run.spinup.spinup_TEM,
);

data = (;
    forcing,
    forcing_one_timestep,
    allocated_output = output_array
    );

site_location = loc_space_maps[1]    
loc_land_init = land_init_space[1];

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(op.data, forcing.data, observations.data, site_location)

land_init = land_init_space[site_location[1][2]]

data = (;
    loc_forcing,
    forcing_one_timestep,
    allocated_output = loc_output
)

inits = (;
    selected_models,
    land_init
)

pixel_run!(inits, data, tem)




optim = (;
    cost_options,
    multiconstraint_method
)