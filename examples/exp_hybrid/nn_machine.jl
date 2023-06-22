#x_args = (; shuffle=true, bs=16, sites)
function shuffle_indxs(sites, n_bs_sites, mb_idxs; seed=1)
    s_sites = shuffle_sites(sites; seed=seed)
    xbatches = [s_sites[p] for p ∈ mb_idxs if length(p) == n_bs_sites]
    return xbatches
end

#nn_args = (; n_bs_feat, n_neurons, n_params, extra_layer, nn_opt = Optimisers.Adam(),)
function init_ml_nn(n_bs_feat, n_neurons, n_params, extra_hlayers, nn_opt=Optimisers.Adam())
    ml_model = ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=extra_hlayers)
    flat, re = Optimisers.destructure(ml_model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end

# grads_args = (; tblParams, sites_f, land_init_space, output, forc, obs_synt, forward, helpers, spinup, models, out_vars, f_one)
function get_∇params(xfeatures, re, flat, xbatch, n_params, n_bs_sites, grads_args)
    f_grads = zeros(Float32, n_params, n_bs_sites)
    x_feat = xfeatures(; site=xbatch)
    inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)
    grads_batch!(f_grads, inst_params, xbatch, grads_args...)
    _, ∇params = pb(f_grads)
    return ∇params
end

#x_args = (; shuffle=true, bs=16, sites)
function nn_machine(nn_args, x_args, xfeatures, grads_args; nepochs=10)
    flat, re, opt_state = init_ml_nn(nn_args...)
    mb_idxs = bs_iter(length(x_args.sites); batch_size=x_args.bs)
    xbatches = shuffle_indxs(x_args.sites, x_args.bs, mb_idxs; seed=1)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)

    for epoch ∈ 1:nepochs
        p = Progress(length(xbatches); desc="Computing batch grads...")
        xbatches =
            x_args.shuffle ? shuffle_indxs(x_args.sites, x_args.bs, mb_idxs; seed=epoch) :
            xbatches
        for (batch_id, xbatch) ∈ enumerate(xbatches)
            ∇params = get_∇params(xfeatures, re, flat, xbatch, nn_args.n_params, x_args.bs,
                grads_args)
            Optimisers.update!(opt_state, flat, ∇params)
            next!(p; showvalues=[(:epoch, epoch), (:batch_id, batch_id)])
        end
        up_params = re(flat)(xfeatures(; site=new_sites))
        tot_loss[:, epoch] = get_site_losses(up_params, new_sites, grads_args...)
    end
    return tot_loss
end
