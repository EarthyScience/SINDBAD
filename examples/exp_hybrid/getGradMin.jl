using Revise
using ForwardDiff

using Sindbad
using ForwardSindbad
using ForwardSindbad: timeLoopForward
using OptimizeSindbad
using AxisKeys: KeyedArray as KA
using Lux, Zygote, Optimisers, ComponentArrays, NNlib
using Random
noStackTrace()
Random.seed!(7)

experiment_json = "../exp_hybrid/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify info

info, forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)));
obs = getObsKeyedArrayFromYaxArray(observations);

@time _,
_,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepRunEcosystem(op, forc, info.tem);


@time runEcosystem!(op.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time outcubes = runExperimentOpti(experiment_json);  
tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

# @time outcubes = runExperimentOpti(experiment_json);  
function g_loss(x,
    mods,
    forc,
    op,
    obs,
    tblParams,
    info_tem,
    info_optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    l = getLossGradient(x,
        mods,
        forc,
        op,
        obs,
        tblParams,
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
# op = setupOutput(info);

mods = info.tem.models.forward;
for _ in 1:10
    lo_ss = g_loss(tblParams.default,
        mods,
        forc,
        op,
        obs,
        tblParams,
        tem_with_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    @show lo_ss
end

dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.num_type}.(tblParams.default);
newmods = updateModelParametersType(tblParams, mods, dualDefs);

function l1(p)
    return g_loss(p,
        mods,
        forc,
        op,
        obs,
        tblParams,
        tem_with_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end

# CHUNK_SIZE = 20
p_vec = tblParams.default;
CHUNK_SIZE = 10#length(p_vec)
cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

op = setupOutput(info);
op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}(undef, size(od)) for od in op.data];
op = (; op..., data=op_dat);

# op = setupOutput(info);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,10}}(undef, size(od)) for od in op.data];
# op = (; op..., data=op_dat);

@time _,
_,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepRunEcosystem(op, forc, info.tem);


@time grad = ForwardDiff.gradient(l1, p_vec, cfg)
# @profview grad = ForwardDiff.gradient(l1, p_vec, cfg)
