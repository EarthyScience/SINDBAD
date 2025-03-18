using Revise
using ForwardDiff
using SindbadTEM
using SindbadMetrics
using Random
toggleStackTraceNT()


experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));
op = prepTEMOut(info, forcing.helpers);
observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optimization.cost_options);

run_helpers = prepTEM(forcing, info);


@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution);

function g_loss(x,
    mods,
    space_forcing,
    space_spinup_forcing,
    loc_forcing_t,
    output_array,
    space_output,
    space_land,
    tem_info,
    observations,
    tbl_params,
    cost_options,
    multi_constraint_method)
    l = loss(x,
        mods,
        forcing_nt_array,
        space_forcing,
        space_spinup_forcing,
        loc_forcing_t,
        output_array,
        space_output,
        space_land,
        space_ind,
        tem_info,
        observations,
        tbl_params,
        cost_options,
        multi_constraint_method)
    return l
end

mods = info.models.forward;
g_loss(tbl_params.default,
    mods,
    run_helpers.space_forcing,
    run_helpers.space_spinup_forcing,
    run_helpers.loc_forcing_t,
    run_helpers.output_array,
    run_helpers.space_output,
    run_helpers.space_land,
    run_helpers.tem_info,
    obs_array,
    tbl_params,
    cost_options,
    info.optimization.multi_constraint_method)

function l1(p)
    return g_loss(p,
        mods,
        run_helpers.space_forcing,
        run_helpers.space_spinup_forcing,
        run_helpers.loc_forcing_t,
        run_helpers.output_array,
        run_helpers.space_output,
        run_helpers.space_land,
        run_helpers.tem_info,
        obs_array,
        tbl_params,
        cost_options,
        info.optimization.multi_constraint_method)
end
l1(tbl_params.default)
rand_m = rand()
dualDefs = ForwardDiff.Dual{info.helpers.numbers.num_type}.(tbl_params.default);
newmods = updateModelParameters(tbl_params, mods, dualDefs);

function l2(p)
    return g_loss(p,
        newmods,
        run_helpers.space_forcing,
        run_helpers.space_spinup_forcing,
        run_helpers.loc_forcing_t,
        run_helpers.output_array,
        run_helpers.space_output,
        run_helpers.space_land,
        run_helpers.tem_info,
        obs_array,
        tbl_params,
        cost_options,
        info.optimization.multi_constraint_method)

end


# op = prepTEMOut(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_info.model_helpers.numbers.num_type},tem_info.model_helpers.numbers.num_type,10}}(undef, size(od)) for od in run_helpers.output_array];
# op = (; op..., data=op_dat);

# @time grad = ForwardDiff.gradient(l1, tbl_params.default)

l1(tbl_params.default .* rand_m)
l2(tbl_params.default .* rand_m)





@profview grad = ForwardDiff.gradient(l1, tbl_params.default)
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
    # Apply Chain experiment_rules to get ∂loss/∂NN_parameters
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
