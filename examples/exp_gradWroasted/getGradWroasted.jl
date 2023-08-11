using Revise
using ForwardDiff

using SindbadExperiment
toggleStackTraceNT()

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));

observations = getObservation(info, forcing.helpers);
obs_array = observations.data;

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_types = prepTEM(forcing, info);


@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_types)

# @time out_params = runExperimentOpti(experiment_json);  
tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

# @time out_params = runExperimentOpti(experiment_json);  
function g_loss(x,
    mods,
    forcing_nt_array,
    output_array,
    obs_array,
    tbl_params,
    info_tem,
    info_optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    forcing_one_timestep)
    l = getLoss(x,
        mods,
        forcing_nt_array,
        output_array,
        obs_array,
        tbl_params,
        info_tem,
        info_optim.cost_options,
        info_optim.multi_constraint_method,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        forcing_one_timestep)
    return l
end

mods = info.tem.models.forward;
g_loss(tbl_params.default,
    mods,
    forcing_nt_array,
    output_array,
    obs_array,
    tbl_params,
    tem_with_types,
    info.optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    forcing_one_timestep)

function l1(p)
    return g_loss(p,
        mods,
        forcing_nt_array,
        output_array,
        obs_array,
        tbl_params,
        tem_with_types,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        forcing_one_timestep)
end
l1(tbl_params.default)


p_vec = tbl_params.default;
CHUNK_SIZE = length(p_vec)
CHUNK_SIZE = 10

cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

# op = prepTEMOut(info, forcing.helpers);
# output_array = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}(undef, size(od)) for od in output_array];
output_array = [Array{Any}(undef, size(od)) for od in output_array];
# op = (; op..., data=op_dat);
# output_array = op_dat;

dualDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
mods = updateModelParametersType(tbl_params, mods, dualDefs);


# op = prepTEMOut(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_types.helpers.numbers.num_type},tem_with_types.helpers.numbers.num_type,10}}(undef, size(od)) for od in output_array];
# op = (; op..., data=op_dat);


@time grad = ForwardDiff.gradient(l1, p_vec, cfg)

# @time grad = ForwardDiff.gradient(l1, p_vec, cfg)
