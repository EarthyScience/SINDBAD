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

function gradsBatch!(loss_function::Function, up_params_now, f_grads, xbatch, sites_f, data, data_optim,
    tem, tblParams, land_init_space, approaches, optim, forcing_one_timestep; logging=true)

    p = Progress(length(xbatch); desc="Computing batch grads...", offset=1, color=:yellow, enabled=logging)
    for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tblParams, xbatch, idx)
        site_location = name_to_id(site_name, sites_f)
        init_land = land_init_space[site_location[1][2]]

        loc_output, loc_forcing, loc_obs = getLocDataObsN(data..., data_optim.site_obs, site_location) # check output order in original definition

        inits = (; selected_models = approaches, init_land)
        data_optim = (; site_obs = loc_obs, )
        data_cache = (; loc_forcing, forcing_one_timestep, allocated_output = DiffCache.(loc_output))

        gg = ForwardDiffGrads(loss_function, new_vals, inits, data_cache, data_optim, tem, tblParams, optim)
        f_grads[:, idx] = gg

        next!(p; showvalues=[(:site_name, site_name)])
    end
end