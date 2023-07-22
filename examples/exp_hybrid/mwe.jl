using Sindbad
using ForwardSindbad
using ForwardSindbad: timeLoopForward
#using HybridSindbad
using AxisKeys: KeyedArray as KA
#using Lux, Zygote, Optimisers, ComponentArrays, NNlib
using Random
Random.seed!(13)

experiment_json = "../settings_distri/experiment.json"
experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"

info = getConfiguration(experiment_json);
info = setupExperiment(info);
info, forcing = getForcing(info);
forc = getKeyedArrayWithNames(forcing);

forcing = (; Tair=forc.Tair, Rain=forc.Rain)

#forcing = (;
#    Rain =KA([5.0f0, 10.0f0, 7.0f0, 10.0f0, 2.0f0];  time=1:5),
#    Tair = KA([-2.0f0, 0.1f0, -1.0f0, 3.0f0, 10.0f0]; time=1:5),
#    )
#pprint(forcing)

# Instantiate land components
land = createLandInit(info.pools, info.tem.helpers, info.tem.models)
helpers = info.tem.helpers;
tem = info.tem;
# helpers = (; numbers =(; 𝟘 = 0.0f0),  # type that zero with \bbzero [TAB]
#     dates = (; timesteps_in_day=1),
#     run = (; output_all=true, runSpinup=false),
#     );
# tem = (;
#     helpers,
#     variables = (;),
#     );

function o_models(p1, p2)
    return (rainSnow_Tair_buffer(p1),
        snowFraction_HTESSEL(1.0f0),
        snowMelt_Tair_buffer(p2),
        wCycle_components())
end

#f = getForcingForTimeStep(forcing, 1)
#f = getForcingForTimeStep(forcing, 1)
f = ForwardSindbad.get_force_at_time_t(forcing, 1)

omods = o_models(0.0f0, 0.0f0)
land = runPrecompute(f, omods, land, helpers)

function sloss(m, data)
    x, y = data
    opt_ps = m(x)
    omods = o_models(opt_ps[1], opt_ps[2])

    out_land = timeLoopForward(omods, forcing, land, (;), helpers, 10)
    ŷ = [getproperty(getproperty(o, :rainSnow), :snow) for o ∈ out_land]

    #out_land = out_land |> landWrapper
    #ŷ = #out_land[:rainSnow][:snow]
    return Flux.mse(ŷ, y)
end

function floss(p, y)
    omods = o_models(p[1], p[2])
    out_land = timeLoopForward(omods, forcing, land, (;), helpers, 10000)
    ŷ = [getproperty(getproperty(o, :rainSnow), :snow) for o ∈ out_land]
    return sum((ŷ .- y) .^ 2)
end
y = rand(10000)

floss((0.5, 0.5), y)
floss(p) = floss(p, y)

using ForwardDiff

@time ForwardDiff.gradient(floss, [1.0, 1000.0])

# test_gradient(model, data, sloss; opt=Optimisers.Adam())

# https://github.com/mcabbott/AxisKeys.jl/issues/140

# training machine

# generate fake target parameters

# function get_target(m, x)
#     target_param = m(x)
#     omods = o_models(target_param[1], target_param[2])
#     out_land = timeLoopForward(omods, forcing, land, (; ), helpers, 100)
#     y = [getproperty(getproperty(o, :rainSnow), :snow) for o in out_land]
#     return (y, target_param)
# end

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
function full_gradient(x, y_real; NNmodel=NNmodel, loss=floss, ps_NN=ps_NN, st=st)
    """
    Function that outpus the full gradient of the loss w.r.t. the weights
    of the NNmodel.
    """
    # First pass through the NN to output the predicted parameters
    ps_phys_pred = NNmodel(x, ps_NN, st)[1]

    # Gradient of the loss w.r.t. the process-based model's parameters
    f_grad = ForwardDiff.gradient(ps -> loss(ps, y_real), ps_phys_pred)
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
