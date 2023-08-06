using Revise
using ForwardDiff

using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()

experiment_json = "../exp_gradWroastedsettings_gradWroastedexperiment.json"

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

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

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
f_one = prepRunEcosystem(op, forcing_nt_array, info.tem);


@time runEcosystem!(op.data,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

res_vec_space = [Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size) for _ ∈ 1:length(loc_space_inds)];

# @time runEcosystem(info.tem.models.forward,
#     res_vec_space,
#     forcing_nt_array,
#     tem_with_vals,
#     loc_space_inds,
#     loc_forcings,
#     land_init_space,
#     f_one);

#     big_land = landWrapper(res_vec_space);

tbl_params = Sindbad.getParameters(info.tem.models.forward,
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
f_one = prepRunEcosystem(op, forcing_nt_array, info.tem);

@time runEcosystem!(op.data,
    mods,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time out_params = runExperimentOpti(experiment_json);  

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
rand_m = info.tem.helpers.numbers.sNT(rand());
# op = setupOutput(info, forcing.helpers);

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

new_dtype = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),Float32},Float32,10}


updated_tem_helpers = (; info.tem.helpers..., numbers=prepNumericHelpers(info, new_dtype));
op = setupOutput(info, updated_tem_helpers);

# dualDefs = tbl_params.default;
new_params = new_dtype.(tbl_params.default);
updated_mods = updateModelParametersType(tbl_params, mods, new_params);

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
f_one = prepRunEcosystem(op, updated_mods, forcing_nt_array, info.tem, updated_tem_helpers);


@time runEcosystem!(op.data,
    updated_mods,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

@time grad = ForwardDiff.gradient(l1, p_vec, cfg)
@profview grad = ForwardDiff.gradient(l1, p_vec, cfg)
