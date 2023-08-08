export ForwardDiffGrads
export gradsBatch!
export newVals

"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, kwargs...)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - kwargs :: keyword arguments needed by the loss_function
"""
function ForwardDiffGrads(loss_function::Function, vals::AbstractArray, kwargs...)
    loss_tmp(x) = loss_function(x, kwargs...)
    return ForwardDiff.gradient(loss_tmp, vals)
end

"""
    scaledParams(up_params_now, xbatch, idx)

Returns:
    - site_name
    - scaled parameters within the proper bounds
"""
function scaledParams(up_params_now, tblParams, xbatch, idx)
    site_name = xbatch[idx]
    x_params = up_params_now(; site=site_name)
    scaled_params = getParamsAct(x_params, tblParams)
    return site_name, scaled_params
end

"""
gradsBatch!(
    loss_function::Function,
    f_grads,
    up_params_now,
    xbatch,
    sites_f,
    out_data_cache,
    forc,
    obs_synt,
    forward,
    tblParams,
    loc_land_init,
    site_location,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one; logging=true)
"""
function gradsBatch!(
    loss_function::Function,
    f_grads,
    up_params_now,
    xbatch,
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
    f_one; logging=true)

    p = Progress(length(xbatch); desc="Computing batch grads...", offset=0, color=:yellow, enabled=logging)
    for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tblParams, xbatch, idx)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]

        gg = ForwardDiffGrads(
            loss_function,
            new_vals,
            loc_land_init,
            site_location,
            out_data_cache,
            forc,
            obs_synt,
            forward,
            tblParams,
            tem_helpers,
            tem_spinup,
            tem_models,
            tem_optim,
            f_one)

        f_grads[:, idx] = gg
        next!(p; showvalues=[(:site_name, site_name)])
    end
end