export ForwardDiff_grads

"""
ForwardDiff_grads(loss_function::Function, vals::AbstractArray, kwargs...)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - kwargs :: keyword arguments needed by the loss_function
"""
function ForwardDiff_grads(loss_function::Function, vals::AbstractArray, kwargs...)
    loss_tmp(x) = loss_function(x, kwargs...)
    return ForwardDiff.gradient(loss_tmp, vals)
end

"""
site_name = xbatch[s_index]
x_params = up_params_now(; site=site_name)
scaled_params = getParamsAct(x_params, tblParams)
"""

function newVals(up_params_now, xbatch, idx)
    site_name = xbatch[idx]
    x_params = up_params_now(; site=site_name)
    scaled_params = getParamsAct(x_params, tblParams)
    return scaled_params
end

function newKwargs(xbatch, idx, kwargs_fixed...)
    site_name = xbatch[idx]
    site_location = name_to_id(site_name, sites_f)
    loc_land_init = land_init_space[site_location[1][2]]
    loc_forcing, loc_output, loc_obs = getLocDataObsN(out_data, forc, obs, site_location)
    return nothing
end

function grads_batch!(f_grads, up_params_now, kwargs_fixed; enabled=true)
    p = Progress(length(xbatch); desc="Computing batch grads...", color=:yellow, enabled=enabled)
    for idx ∈ eachindex(xbatch)
        new_vals = newVals(up_params_now, xbatch, idx)
        new_kwargs = newKwargs(xbatch, idx, kwargs_fixed...)
        gg = ForwardDiff_grads(loss_function, new_vals, new_kwargs...)
        f_grads[:, site_index] = gg
        next!(p; showvalues=[(:site_name, site_name), (:site_location, site_location)])
    end
end