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
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time _, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one =
    prepRunEcosystem(output, forc, info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    info.tem,
    loc_space_names,
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
    op_vars,
    obs,
    tblParams,
    info_tem,
    info_optim,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    l = getLossGradient(x,
        mods,
        forc,
        op,
        op_vars,
        obs,
        tblParams,
        info_tem,
        info_optim,
        loc_space_names,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    return l
end
rand_m = rand(info.tem.helpers.numbers.num_type);
op = setupOutput(info);

mods = info.tem.models.forward;
params = tblParams.defaults;
selParam = :fracRootD2SoilD
selIndex = findall(tblParams.names .== selParam)[1]
for pr ∈ collect(0.0:50:1000.0)
    pc = copy(params)
    pc[selIndex] = pc[selIndex] * pr
    l = g_loss(pc,
        mods,
        forc,
        op,
        op.variables,
        obs,
        tblParams,
        info.tem,
        info.optim,
        loc_space_names,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    @show l
end
g_loss(tblParams.defaults .* rand_m,
    mods,
    forc,
    op,
    op.variables,
    obs,
    tblParams,
    info.tem,
    info.optim,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
g_loss(tblParams.defaults,
    mods,
    forc,
    op,
    op.variables,
    obs,
    tblParams,
    info.tem,
    info.optim,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
# g_loss(tblParams.defaults, info.tem.models.forward, forc, op, op.variables, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.num_type}.(tblParams.defaults);
newmods = updateModelParametersType(tblParams, mods, dualDefs);

function l1(p)
    return g_loss(p,
        mods,
        forc,
        op,
        op.variables,
        obs,
        tblParams,
        info.tem,
        info.optim,
        loc_space_names,
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
        op.variables,
        obs,
        tblParams,
        info.tem,
        info.optim,
        loc_space_names,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end
l1(tblParams.defaults .* rand_m)
l2(tblParams.defaults .* rand_m)
@time grad = ForwardDiff.gradient(l1, tblParams.defaults .* rand_m)
@profview grad = ForwardDiff.gradient(l1, tblParams.defaults)
@time grad = ForwardDiff.gradient(l2, dualDefs)
