using ForwardDiff
using SindbadTEM
using SindbadData
using SindbadTEM.SindbadMetrics

toggleStackTraceNT()

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));

observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optim.cost_options);


run_helpers = prepTEM(forcing, info);


@time runTEM!(info.tem.models.forward,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)

# @time out_params = runExperimentOpti(experiment_json);  
tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

function getLoss2(
    param_vector::AbstractArray,
    base_models,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem,
    observations,
    tbl_params,
    cost_options,
    multi_constraint_method)
    updated_models = updateModelParametersType(tbl_params, base_models, param_vector)
    runTEM!(updated_models,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem)
    loss_vector = getLossVector(observations, output_array, cost_options)
    return combineLoss(loss_vector, multi_constraint_method)
end

# @time out_params = runExperimentOpti(experiment_json);  
function g_loss(x,
    mods,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    tem_with_types,
    observations,
    tbl_params,
    cost_options,
    multi_constraint_method)
    l = getLoss2(x,
        mods,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        tem_with_types,
        observations,
        tbl_params,
        cost_options,
        multi_constraint_method)
    return l
end

mods = info.tem.models.forward;
#mods = [m for m in mods];

@time g_loss(tbl_params.default,
    mods,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.output_array,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types,
    obs_array,
    tbl_params,
    cost_options,
    info.optim.multi_constraint_method)

function l1(p)
    return g_loss(p,
        mods,
        run_helpers.loc_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.output_array,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types,
        obs_array,
        tbl_params,
        cost_options,
        info.optim.multi_constraint_method)
end
l1(tbl_params.default)


p_vec = tbl_params.default;
CHUNK_SIZE = length(p_vec)
CHUNK_SIZE = 10

cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

# op = prepTEMOut(info, forcing.helpers);
# output_array = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}(undef, size(od)) for od in run_helpers.output_array];
output_array = [Array{Any}(undef, size(od)) for od in run_helpers.output_array];
# op = (; op..., data=op_dat);
# output_array = op_dat;

dualDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
mods = updateModelParametersType(tbl_params, mods, dualDefs);

@time g_loss(tbl_params.default,
    mods,
    run_helpers.forcing_nt_array,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.output_array,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.loc_space_inds,
    run_helpers.tem_with_types,
    obs_array,
    tbl_params,
    cost_options,
    info.optim.multi_constraint_method)


# op = prepTEMOut(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_types.helpers.numbers.num_type},tem_with_types.helpers.numbers.num_type,10}}(undef, size(od)) for od in run_helpers.output_array];
# op = (; op..., data=op_dat);


@time grad = ForwardDiff.gradient(l1, p_vec, cfg)

# @time grad = ForwardDiff.gradient(l1, p_vec, cfg)
