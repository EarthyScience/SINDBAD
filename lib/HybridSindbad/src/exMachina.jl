export destructureNN
export get∇params
export exMachina

"""
    destructureNN(model; nn_opt=Optimisers.Adam())
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end

"""
    get∇params(loss_function::Function, xfeatures, re, flat, xbatch, bs, n_params, kwargs...)
"""
function get∇params(loss_function::Function, xfeatures, re, flat, xbatch, n_params, kwargs...; logging=true)
    f_grads = zeros(Float32, n_params, length(xbatch))
    x_feat = xfeatures(; site=xbatch)
    inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)
    gradsBatch!(loss_function, f_grads, inst_params, xbatch, kwargs...; logging=logging)
    _, ∇params = pb(f_grads)
    return ∇params
end

"""
exMachina(init_model::Flux.Chain, kwargs...; nepochs=10, opt = Optimisers.Adam())
    - nn_args = (; bs, shuffle)
"""
function exMachina(init_model::Flux.Chain, loss_function::Function, xfeatures, kwargs...;
    nepochs=2, opt = Optimisers.Adam(), bs_seed = 123, bs = 4, shuffle=true)

    sites = xfeatures.site
    flat, re, opt_state = destructureNN(init_model; nn_opt = opt)
    n_params = length(init_model[end].bias)

    xbatches = batch_shuffle(sites, bs; seed=123)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)

    for epoch ∈ 1:nepochs
        p = Progress(nepochs; desc="Computing epochs...", offset=3)
        xbatches = shuffle ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches

        for (batch_id, xbatch) ∈ enumerate(xbatches)
            ∇params = get∇params(loss_function,  xfeatures, re, flat, xbatch, n_params, kwargs...)
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
            next!(p; showvalues=[(:epoch, epoch), (:batch_id, batch_id)])
        end

        up_params_now = re(flat)(xfeatures(; site=new_sites))
        #loss_now = loc_loss_inner(up_params_now, kwargs...)

        tot_loss[:, epoch] .= epoch #loss_now
    end
    return tot_loss, re, flat
end