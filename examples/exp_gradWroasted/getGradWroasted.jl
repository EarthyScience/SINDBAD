using Revise
using ForwardDiff

using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));

observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArray(observations);

forcing_nt_array, output_array, _, _, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one = prepTEM(forcing, info);


@time TEM!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    tem_with_vals)

# @time out_params = runExperimentOpti(experiment_json);  
tbl_params = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

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
    f_one)
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
        f_one)
    return l
end

mods = info.tem.models.forward;
g_loss(tbl_params.default,
    mods,
    forcing_nt_array,
    output_array,
    obs_array,
    tbl_params,
    tem_with_vals,
    info.optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

function l1(p)
    return g_loss(p,
        mods,
        forcing_nt_array,
        output_array,
        obs_array,
        tbl_params,
        tem_with_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end
l1(tbl_params.default)


p_vec = tbl_params.default;
CHUNK_SIZE = length(p_vec)
CHUNK_SIZE = 10

cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

# op = setupOutput(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}(undef, size(od)) for od in op.data];
# op = (; op..., data=op_dat);
# output_array = op_dat;

dualDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
mods = updateModelParametersType(tbl_params, mods, dualDefs);


# op = setupOutput(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,10}}(undef, size(od)) for od in op.data];
# op = (; op..., data=op_dat);


@time grad = ForwardDiff.gradient(l1, p_vec, cfg)

# @time grad = ForwardDiff.gradient(l1, p_vec, cfg)
