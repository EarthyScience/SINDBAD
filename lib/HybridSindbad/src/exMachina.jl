export destructureNN
export get∇params
export exMachina
export get_site_losses

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
    exMachina(init_model::Flux.Chain, loss_function::Function, xfeatures, kwargs...;
        nepochs=2, opt = Optimisers.Adam(), bs_seed = 123, bs = 4, shuffle=true)
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
        loss_now = get_site_losses(loss_function, up_params_now, new_sites, kwargs...; logging=true)
        tot_loss[:, epoch] = loss_now
    end
    return tot_loss, re, flat
end

"""
    get_site_losses(
        loss_function::Function,
        up_params_now,
        new_sites,
        sites_f,
        land_init_space,
        out_data_cache,
        forc,
        obs_synt,
        forward,
        tblParams,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_optim,
        f_one;
        logging=true)
"""
function get_site_losses(
    loss_function::Function,
    up_params_now,
    new_sites,
    sites_f,
    land_init_space,
    out_data_cache,
    forc,
    obs_synt,
    forward,
    tblParams,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one;
    logging=true)

    tot_loss = fill(NaN32, length(new_sites))
    p = Progress(length(new_sites); desc="Computing site losses...", offset=6, color=:yellow, enabled=logging)
    for idx ∈ eachindex(new_sites)
        site_name, new_vals = scaledParams(up_params_now,  tblParams, new_sites, idx)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]

        loss_site = loss_function(new_vals, loc_land_init, site_location,
            out_data_cache,
            forc,
            obs_synt,
            forward,
            tblParams,
            tem_helpers,
            tem_spinup,
            tem_models,
            tem_optim,
            f_one
            )
        tot_loss[idx] = loss_site
        next!(p; showvalues=[(:site_name, site_name)])
    end
    return tot_loss
end