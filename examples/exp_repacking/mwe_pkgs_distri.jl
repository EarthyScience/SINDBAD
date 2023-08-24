using Distributed
using SharedArrays
addprocs()

@everywhere begin
    using SindbadData
    using SindbadTEM
    using HybridSindbad
    using ForwardDiff
    using PreallocationTools
end


toggleStackTraceNT()
include("gen_obs.jl");

obs_synt_single = out_synt()

@everywhere obs_synt = $obs_synt_single

experiment_json = "../exp_repacking/settings_repacking/experiment.json"
#info = getConfiguration(experiment_json);
#info = setupInfo(info);

info = getExperimentInfo(experiment_json);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

forc = (; Pair.(forcing.variables, forcing.data)...);
obs = (; Pair.(observations.variables, observations.data)...);

land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = prepTEMOut(info, forcing.helpers);

run_helpers = prepTEM(forcing, info);

tem_with_types = run_helpers.tem_with_types;

tem = (;
    tem_helpers = tem_with_types.helpers,
    tem_models = tem_with_types.models,
    tem_spinup = tem_with_types.spinup,
    tem_run_spinup = tem_with_types.helpers.run.spinup.spinup_TEM,
);

data = (;
    forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
    allocated_output = run_helpers.output_array
    );
loc_space_maps = run_helpers.loc_space_maps;
land_init_space = run_helpers.land_init_space;

site_location = loc_space_maps[3]    
loc_land_init = land_init_space[3];

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(op.data, forc, obs_synt, site_location);

land_init = land_init_space[site_location[1][2]];

data = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
    allocated_output = loc_output
);

inits = (;
    selected_models = info.tem.models.forward,
    land_init
);

data_optim = (;
    site_obs = loc_obs,
);

cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
optim = (;
    cost_options= cost_options,
    multiconstraint_method = info.optim.multi_constraint_method
);

@time pixel_run!(inits, data, tem);


@time getSiteLossTEM(inits, data, data_optim, tem, optim)

@sync @distributed for i in 1:16
    r = getSiteLossTEM(inits, data, data_optim, tem, optim)
    @show r
end


CHUNK_SIZE = 12;
data_cache = (;
    loc_forcing,
    forcing_one_timestep =run_helpers.forcing_one_timestep,
#    allocated_output = DiffCache.(loc_output, (CHUNK_SIZE,)),
    allocated_output = DiffCache.(loc_output)
);

@time siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, tbl_params, optim)

@sync @distributed for i in 1:16
    r_in = siteLossInner(tbl_params.default, inits, data_cache, data_optim, tem, tbl_params, optim)
    @show r_in
end


kwargs = (;
    inits, data_cache, data_optim, tem, tbl_params, optim
    );
    
@time ForwardDiffGrads(siteLossInner, tbl_params.default, kwargs...)
