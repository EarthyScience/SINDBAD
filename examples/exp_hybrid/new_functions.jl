using YAXArrays, Zarr, YAXArrayBase, AxisKeys
using ProgressMeter
using Statistics

function getLocDataObs(outcubes, forcing, obs, loc_space_map)
    loc_forcing = map(forcing) do a
        return view(a; loc_space_map...)
    end
    loc_obs = map(obs) do a
        return view(a; loc_space_map...)
    end
    ar_inds = last.(loc_space_map)

    loc_output = map(outcubes) do a
        return getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output, loc_obs
end

function site_loss(output,
    forc,
    obs,
    site_location,
    tblParams,
    forward,
    upVector,
    helpers,
    spinup,
    models,
    out_vars,
    land_init_site,
    f_one)
    #@show site_location, Threads.threadid()
    loc_forcing, loc_output, loc_obs = getLocDataObs(output.data, forc, obs, site_location)
    newApproaches = updateModelParametersType(tblParams, forward, upVector)
    ForwardSindbad.coreEcosystem!(loc_output,
        newApproaches,
        loc_forcing,
        helpers,
        spinup,
        models,
        out_vars,
        land_init_site,
        f_one)
    return lloss(loc_obs.gpp, loc_obs.gpp_σ, loc_output[1][:, 1], Val(:mse))
end

function get_loc_loss(loc_obs,
    loc_output,
    newApproaches,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    loc_land_init,
    f_one)
    #@show tem_helpers.pools
    ForwardSindbad.coreEcosystem!(loc_output,
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        Val(tem_variables),
        loc_land_init,
        f_one)
    model_data = (; Pair.(out_variables, loc_output)...)
    loss_vector = getLossVectorArray(loc_obs, model_data, tem_optim)
    l = combineLossArray(loss_vector, Val(tem_optim.multiConstraintMethod))
    return l
end

function site_loss2(output,
    forc,
    obs,
    site_location,
    tblParams,
    forward,
    upVector,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    loc_land_init,
    f_one)
    loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location)
    newApproaches = updateModelParametersType(tblParams, forward, upVector)
    l = get_loc_loss(loc_obs,
        loc_output,
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_variables,
        tem_optim,
        out_variables,
        loc_land_init,
        f_one)
    return l
end

function getLocObs(outcubes, obs, loc_space_map)
    loc_obs = map(obs) do a
        return view(a; loc_space_map...)
    end
    return loc_obs
end

function getLocDataObsN(outcubes, forcing, obs, loc_space_map)
    loc_forcing = map(forcing) do a
        return view(a; loc_space_map...)
    end
    loc_obs = map(obs) do a
        return view(a; loc_space_map...)
    end
    ar_inds = last.(loc_space_map)

    loc_output = map(outcubes) do a
        return getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output, loc_obs
end

function name_to_id(site_name, sites_forcing)
    site_id_forc = findall(x -> x == site_name, sites_forcing)[1]
    return [Symbol("site") => site_id_forc]
end

function names_to_ids(batch_names, sites_forcing)
    site_ids = Vector{Pair{Symbol,Int64}}[]
    for site_name ∈ batch_names
        push!(site_ids, name_to_id(site_name, sites_forcing))
    end
    return site_ids
end

# for hybrid

function cube_to_KA(c)
    namesCube = YAXArrayBase.dimnames(c)
    return KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
end

# batching

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

function getParamsAct(pNorm, tblParams)
    lb = oftype(tblParams.defaults, tblParams.lower)
    ub = oftype(tblParams.defaults, tblParams.upper)
    pVec = pNorm .* (ub .- lb) .+ lb
    return pVec
end

# neural network design
function ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=0, seed=1618) # ~ (1+√5)/2
    Random.seed!(seed)
    return Flux.Chain(Flux.Dense(n_bs_feat => n_neurons, Flux.relu),
        [Flux.Dense(n_neurons, n_neurons, Flux.relu) for _ ∈ 0:(extra_hlayers-1)]...,
        Flux.Dense(n_neurons => n_params, Flux.sigmoid))
end

function grads_batch!(f_grads,
    up_params,
    xbatch,
    tblParams,
    sites_f,
    land_init_space,
    output,
    forc,
    obs,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one)
    Threads.@threads for site_index ∈ eachindex(xbatch)
        site_name = xbatch[site_index]
        x_params = up_params(; site=site_name)
        pVec = getParamsAct(x_params, tblParams)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        #loss_thread = v -> site_loss2(output, forc, obs, site_location, tblParams, forward, v, helpers, spinup, models, out_vars, land_init_site, f_one)
        loss_thread =
            v -> site_loss2(output,
                forc,
                obs,
                site_location,
                tblParams,
                forward,
                v,
                tem_helpers,
                tem_spinup,
                tem_models,
                tem_variables,
                tem_optim,
                out_variables,
                loc_land_init,
                f_one)
        f_grads[:, site_index] = ForwardDiff.gradient(loss_thread, pVec)
    end
end

function grads_batch_seq!(f_grads,
    up_params,
    xbatch,
    tblParams,
    sites_f,
    land_init_space,
    output,
    forc,
    obs,
    forward,
    helpers,
    spinup,
    models,
    out_vars,
    f_one)
    p = Progress(length(xbatch); desc="Computing batch grads...", color=:yellow)
    for (site_index, site_name) ∈ enumerate(xbatch)
        x_params = up_params(; site=site_name)
        pVec = getParamsAct(x_params, tblParams)
        site_location = name_to_id(site_name, sites_f)
        land_init_site = land_init_space[site_location[1][2]]
        loss_thread =
            v -> site_loss(output,
                forc,
                obs,
                site_location,
                tblParams,
                forward,
                v,
                helpers,
                spinup,
                models,
                out_vars,
                land_init_site,
                f_one)
        f_grads[:, site_index] = ForwardDiff.gradient(loss_thread, pVec)
        next!(p; showvalues=[(:site_name, site_name), (:site_location, site_location)])
    end
end

function lloss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})
    idxs = (.!isnan.(y .* yσ .* ŷ))
    if sum(idxs) == 0
        return 1e20
    else
        return mean(abs2.(y[idxs] .- ŷ[idxs]))
    end
end

function get_site_losses(up_params,
    new_sites,
    tblParams,
    sites_f,
    land_init_space,
    output,
    forc,
    obs,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one)
    tot_loss = fill(NaN32, length(new_sites))
    Threads.@threads for s_id ∈ eachindex(new_sites)
        site_name = new_sites[s_id]
        x_params = up_params(; site=site_name)
        pVec = getParamsAct(x_params, tblParams)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        loss_thread =
            v -> site_loss2(output,
                forc,
                obs,
                site_location,
                tblParams,
                forward,
                v,
                tem_helpers,
                tem_spinup,
                tem_models,
                tem_variables,
                tem_optim,
                out_variables,
                loc_land_init,
                f_one)
        tot_loss[s_id] = loss_thread(pVec) # maybe a bug? threads scope
    end
    return tot_loss
end
