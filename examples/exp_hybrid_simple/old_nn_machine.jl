using Base.Iterators: repeated, partition
using Random

function shuffle_sites(sites; seed=123)
    Random.seed!(seed)
    rand_names = randperm(length(sites))
    return sites[rand_names]
end

function bs_iter(n; batch_size=32)
    return partition(1:n, batch_size)
end

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

#function fdiff_grads(f, v, site_location, loc_land_init, args)
#    gf(v) = f(v, site_location, loc_land_init, args...)
#    return ForwardDiff.gradient(gf, v)
#end


# out_data = output_array
function grads_batch!(f_grads, up_params_now, xbatch, out_data, forc, obs_array, sites_f, forward,
    tbl_params, land_init_space, loc_loss, kwargs_fixed; enabled=true)

    p = Progress(length(xbatch); desc="Computing batch grads...", color=:yellow, enabled=enabled)
    for (site_index, site_name) ∈ enumerate(xbatch)
        x_params = up_params_now(; site=site_name)
        scaled_params = getParamsAct(x_params, tbl_params)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        loc_forcing, loc_output, loc_obs = getLocDataObsN(out_data, forc, obs_array, site_location)

        gg = fdiff_grads(loc_loss, scaled_params, forward, tbl_params,
            loc_obs, loc_forcing, loc_land_init, kwargs_fixed)
        #if sum(gg) == 0.0
        #println("what!!!, why?!!: site_index $(scaled_params): site_name $(site_name)", scaled_params)
        #    @show x_params, scaled_params
        #    error("please stop...")
        #end
        f_grads[:, site_index] = gg

        next!(p; showvalues=[(:site_name, site_name), (:site_location, site_location)])
    end
end


# grads_args = (; tbl_params, sites_f, land_init_space, output, forc, obs_synt, forward, helpers, spinup, models, out_vars, forcing_one_timestep)
function get_∇params(xfeatures, re, flat, xbatch, n_params, n_bs_sites,
    out_data, forc, obs_array, sites_f, forward, tbl_params, land_init_space, loc_loss, kwargs_fixed)

    f_grads = zeros(Float32, n_params, n_bs_sites)
    x_feat = xfeatures(; site=xbatch)
    inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)
    #s_ps = sum(inst_params)
    #if isnan(s_ps) || s_ps == 0
    #    @show inst_params
    #    error("please stop...")
    #end

    grads_batch!(f_grads, inst_params, xbatch, out_data, forc, obs_array, sites_f, forward,
        tbl_params, land_init_space, loc_loss, kwargs_fixed; enabled=false)
    _, ∇params = pb(f_grads)

    #@show f_grads[1:10, 1]
    #@show inst_params[]
    #@show ∇params[:, 1]
    return ∇params
end

#x_args = (; shuffle=true, bs=16, sites)
function nn_machine(nn_args, x_args, xfeatures, info, forc, obs_array, sites_f, forward,
    tbl_params, info_tem, loc_loss, kwargs_fixed; nepochs=10)

    flat, re, opt_state = init_ml_nn(nn_args...)
    mb_idxs = bs_iter(length(x_args.sites); batch_size=x_args.bs)
    xbatches = shuffle_indxs(x_args.sites, x_args.bs, mb_idxs; seed=123)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)

    for epoch ∈ 1:nepochs
        p = Progress(length(xbatches); desc="Computing batch grads...")

        forcing_nt_array,
        output_array,
        loc_space_maps,
        loc_space_names,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        tem_with_types,
        forcing_one_timestep = prepTEM(forcing, info)
        out_data = output_array

        xbatches = if x_args.shuffle
            shuffle_indxs(x_args.sites, x_args.bs, mb_idxs; seed=epoch + 123)
        else
            xbatches
        end

        for (batch_id, xbatch) ∈ enumerate(xbatches)
            ∇params = get_∇params(xfeatures, re, flat, xbatch, nn_args.n_params, x_args.bs,
                out_data, forc, obs_array, sites_f, forward, tbl_params, land_init_space, loc_loss, kwargs_fixed)
            #if isnan(sum(∇params)) || sum(∇params) == 0
            #    @show ∇params
            #    error("please stop...")
            #end
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
            next!(p; showvalues=[(:epoch, epoch), (:batch_id, batch_id)])
        end
        up_params_now = re(flat)(xfeatures(; site=new_sites))

        tot_loss[:, epoch] = get_site_losses(up_params_now,
            out_data,
            forc,
            obs_array,
            new_sites,
            sites_f,
            land_init_space,
            forward,
            tbl_params,
            kwargs_fixed
        )
    end
    return return tot_loss, re, flat
end

function get_site_losses(up_params_now,
    out_data,
    forc,
    obs_now,
    new_sites,
    sites_f,
    land_init_space,
    forward,
    tbl_params,
    kwargs_fixed
)
    tot_loss = fill(NaN32, length(new_sites))
    for s_id ∈ eachindex(new_sites)
        site_name = new_sites[s_id]
        x_params = up_params_now(; site=site_name)
        scaled_params = getParamsAct(x_params, tbl_params)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init_now = land_init_space[site_location[1][2]]

        loc_forcing_now, loc_output, loc_obs_now = getLocDataObsN(out_data, forc, obs_now, site_location)

        tot_loss[s_id] = loc_loss(
            scaled_params,
            forward,
            tbl_params,
            loc_obs_now,
            loc_forcing_now,
            loc_land_init_now,
            kwargs_fixed...
        )
    end
    return tot_loss
end