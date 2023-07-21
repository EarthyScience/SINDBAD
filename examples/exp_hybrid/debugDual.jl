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

sYear = "2002"
eYear = "2017"
domain = "FN"
pl = "threads"
data_type = "Float32"
# data_type = "Float32"
arraymethod = "staticarray"
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.domain" => domain,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.spinup.run_spinup" => false,
    "model_run.flags.debug_model" => false,
    "model_run.rules.model_array_type" => arraymethod,
    "model_run.rules.data_type" => data_type,
    "model_run.mapping.parallelization" => pl,
);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info

info, forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.model_run.rules.input_data_backend)));
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

# res_vec_space = [Vector{typeof(land_init_space[1])}(undef, tem_with_vals.helpers.dates.size) for _ ∈ 1:length(loc_space_inds)];


# @time big_land = runEcosystem(info.tem.models.forward,
#     forc,
#     tem_with_vals,
#     loc_space_inds,
#     loc_forcings,
#     land_init_space,
#     res_vec_space,
#     f_one);

tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

# newDtype = ForwardDiff.Dual{info.tem.helpers.numbers.num_type}
# ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,CHUNK_SIZE}
# op_dat = [Array{newDtype}(undef, size(od)) for od in op.data];
# op = (; op..., data=op_dat);

mods = info.tem.models.forward;
@time _,
_,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepRunEcosystem(op, forc, info.tem);

@time runEcosystem!(op.data,
    mods,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time outcubes = runExperimentOpti(experiment_json);  

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
rand_m = info.tem.helpers.numbers.sNT(rand());
# op = setupOutput(info);

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

new_dtype = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),Float32},Float32,10}


updated_tem_helpers = (; info.tem.helpers..., numbers=prepNumericHelpers(info, new_dtype));
op = setupOutput(info, updated_tem_helpers);

# dualDefs = tblParams.default;
new_params = new_dtype.(tblParams.default);
updated_mods = updateModelParametersType(tblParams, mods, new_params);

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
f_one = prepRunEcosystem(op, updated_mods, forc, info.tem, updated_tem_helpers);


@time runEcosystem!(op.data,
    updated_mods,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

@time grad = ForwardDiff.gradient(l1, p_vec, cfg)
@profview grad = ForwardDiff.gradient(l1, p_vec, cfg)
