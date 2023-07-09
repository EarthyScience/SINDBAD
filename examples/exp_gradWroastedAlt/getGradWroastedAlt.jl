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

experiment_json = "../exp_gradWroastedAlt/settings_gradWroastedALt/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify info

info, forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, tem_vals.helpers, tem_vals.models);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time _, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one =
    prepRunEcosystem(output, forc, tem_vals);

@time runEcosystem!(output.data,
    tem_vals.models.forward,
    forc,
    tem_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time outcubes = runExperimentOpti(experiment_json);  
tblParams = Sindbad.getParameters(tem_vals.models.forward,
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
rand_m = rand(tem_vals.helpers.numbers.num_type);
op = setupOutput(info);

mods = tem_vals.models.forward;
params = tblParams.default;
selParam = :constant_frac_max_root_depth
selIndex = findall(tblParams.name .== selParam)[1]
for pr ∈ collect(0.0:50:1000.0)
    pc = copy(params)
    pc[selIndex] = pc[selIndex] * pr
    l = g_loss(pc,
        mods,
        forc,
        op,
        obs,
        tblParams,
        tem_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    @show l
end
g_loss(tblParams.default .* rand_m,
    mods,
    forc,
    op,
    obs,
    tblParams,
    tem_vals,
    info.optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
g_loss(tblParams.default,
    mods,
    forc,
    op,
    obs,
    tblParams,
    tem_vals,
    info.optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
# g_loss(tblParams.default, tem_vals.models.forward, forc, op, op.variables, tem_vals, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one)
dualDefs = ForwardDiff.Dual{tem_vals.helpers.numbers.num_type}.(tblParams.default);
newmods = updateModelParametersType(tblParams, mods, dualDefs);

function l1(p)
    return g_loss(p,
        mods,
        forc,
        op,
        obs,
        tblParams,
        tem_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end
function l2(p)
    return g_loss(p,
        newmods,
        forc,
        op,
        obs,
        tblParams,
        tem_vals,
        info.optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end
l1(tblParams.default .* rand_m)
l2(tblParams.default .* rand_m)
@time grad = ForwardDiff.gradient(l1, tblParams.default .* rand_m)
@profview grad = ForwardDiff.gradient(l1, tblParams.default)
@time grad = ForwardDiff.gradient(l2, dualDefs)
