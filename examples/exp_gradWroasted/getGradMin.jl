using Revise
using ForwardDiff

using Sindbad
using ForwardSindbad
using OptimizeSindbad

noStackTrace()

experiment_json = "../exp_gradWroastedsettings_gradWroastedexperiment.json"
info = getExperimentInfo(experiment_json);

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = setupOutput(info, forcing.helpers);
observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArray(observations);

@time _,
_,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepTEM(op, forcing_nt_array, info.tem);


@time TEM!(op.data,
    info.tem.models.forward,
    forcing_nt_array,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    tem_with_vals)

# @time out_params = runExperimentOpti(experiment_json);  
tbl_params = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

# @time out_params = runExperimentOpti(experiment_json);  
function g_loss(x,
    mods,
    forcing_nt_array,
    op,
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
        op,
        obs_array,
        tbl_params,
        info_tem,
        info_optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    return l
end
rand_m = rand(info.tem.helpers.numbers.num_type);
# op = setupOutput(info, forcing.helpers);

mods = info.tem.models.forward;
for _ in 1:10
    lo_ss = g_loss(tbl_params.default,
        mods,
        forcing_nt_array,
        op,
        obs_array,
        tbl_params,
        tem_with_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    @show lo_ss
end

dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.num_type}.(tbl_params.default);
newmods = updateModelParametersType(tbl_params, mods, dualDefs);

function l1(p)
    return g_loss(p,
        mods,
        forcing_nt_array,
        op,
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

# CHUNK_SIZE = 20
p_vec = tbl_params.default;
CHUNK_SIZE = 10#length(p_vec)
cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

op = setupOutput(info, forcing.helpers);
op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}(undef, size(od)) for od in op.data];
op = (; op..., data=op_dat);

# op = setupOutput(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,10}}(undef, size(od)) for od in op.data];
# op = (; op..., data=op_dat);

@time _,
_,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepTEM(op, forcing_nt_array, info.tem);


@time grad = ForwardDiff.gradient(l1, p_vec, cfg)
# @profview grad = ForwardDiff.gradient(l1, p_vec, cfg)
