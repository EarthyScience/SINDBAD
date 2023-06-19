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


experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify info

info, forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)

# @time outcubes = runExperimentOpti(experiment_json);  
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);

# @time outcubes = runExperimentOpti(experiment_json);  
function g_loss(x, mods, forc, op, op_vars, obs, tblParams, info_tem, info_optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
    l = getLossGradient(x, mods, forc, op, op_vars, obs, tblParams, info_tem, info_optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
    pprint("params:")
    @show " "
    pprint(x)
    @show " "
    pprint("g_loss")
    pprint(l)
    l
end
rand_m = rand(info.tem.helpers.numbers.numType);
op = setupOutput(info);

mods = info.tem.models.forward;
g_loss(tblParams.defaults .* rand_m, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,land_init_space, f_one)
g_loss(tblParams.defaults, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,land_init_space, f_one)
# g_loss(tblParams.defaults, info.tem.models.forward, forc, op, op.variables, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.numType}.(tblParams.defaults);
newmods = updateModelParametersType(tblParams, mods, dualDefs);


l1(p) = g_loss(p, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,land_init_space, f_one)
l2(p) = g_loss(p, newmods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,land_init_space, f_one)
l1(tblParams.defaults .* rand_m)
l2(tblParams.defaults .* rand_m)
@time grad = ForwardDiff.gradient(l1, tblParams.defaults)
@profview grad = ForwardDiff.gradient(l1, tblParams.defaults)
@time grad = ForwardDiff.gradient(l2, dualDefs)
