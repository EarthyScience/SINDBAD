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
function l2(p)
    return g_loss(p,
        newmods,
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


op = setupOutput(info);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,10}}(undef, size(od)) for od in op.data];
# op = (; op..., data=op_dat);

# @time grad = ForwardDiff.gradient(l1, tblParams.default)

l1(tblParams.default .* rand_m)
l2(tblParams.default .* rand_m)





@profview grad = ForwardDiff.gradient(l1, tblParams.default)
@time grad = ForwardDiff.gradient(l2, dualDefs)

a = 2

Random.seed!(122)
d = [rand(Float32, 4) for i ∈ 1:50]
NNmodel = Lux.Chain(Lux.Dense(4 => 5, relu), Lux.Dense(5 => 2, relu))
rng = Random.default_rng()
Random.seed!(rng, 0)
# Initialize Model
ps_NN, st = Lux.setup(rng, NNmodel)
# Parameters must be a ComponentArray or an Array,
# Zygote Jacobian won't loop through NamedTuple
ps_NN = ComponentArray(ps_NN)

# i.e. Input x  now should be 

x = rand(Float32, 4)
function reshape_weight(arr, weights)
    """
    Reshapes a flat array into a weights ComponentArray.
    This method is not mutating.
    Rudimentary implementation, uses an index counter to progressively
    fill the weights array.
    arr: Array to be reshaped
    weights: Sample array to reshape to
    """
    i = 1
    return_arr = similar(ps_NN)
    for layer ∈ keys(weights)
        weight = weights[layer][:weight]
        bias = weights[layer][:bias]
        new_weight = arr[i:(i+length(weight)-1)]
        i += length(weight)
        new_bias = arr[i:(i+length(bias)-1)]
        i += length(bias)
        return_arr[layer][:weight] = reshape(new_weight, size(weight))
        return_arr[layer][:bias] = reshape(new_bias, size(bias))
    end
    return return_arr
end
function full_gradient(x, y_real; NNmodel=NNmodel, g_loss=floss, ps_NN=ps_NN, st=st)
    """
    Function that outpus the full gradient of the g_loss w.r.t. the weights
    of the NNmodel.
    """
    # First pass through the NN to output the predicted parameters
    ps_phys_pred = NNmodel(x, ps_NN, st)[1]

    # Gradient of the g_loss w.r.t. the process-based model's parameters
    f_grad = ForwardDiff.gradient(ps -> g_loss(ps, y_real), ps_phys_pred)
    # Jacobian of the process-based model's parameters w.r.t. the
    # Weights of the NN
    NN_grad = Zygote.jacobian(ps -> NNmodel(x, ps, st)[1], ps_NN)[1]
    # Apply Chain rules to get ∂loss/∂NN_parameters
    full_grad = sum(f_grad .* NN_grad; dims=1)
    # Reshape output for the optimization
    return reshape_weight(full_grad, ps_NN)
end

y_real = y

# Example
dist_arr = []
predicted_vmax = []
loss_arr = []
# Optimization
st_opt = Optimisers.setup(Optimisers.ADAM(0.01), ps_NN)
for i ∈ 1:300
    global st_opt, ps_NN
    gs = full_gradient(x, y_real; ps_NN=ps_NN)
    st_opt, ps_NN = Optimisers.update(st_opt, ps_NN, gs)
    if i % 10 == 1 || i == 100
        dist = abs(NNmodel(x, ps_NN, st)[1][1] - 2.37e-1)
        println("Distance from real value: $dist")
        push!(dist_arr, dist)
        push!(predicted_vmax, NNmodel(x, ps_NN, st)[1][1])
        push!(loss_arr, floss(NNmodel(x, ps_NN, st)[1], y))
    end
end
