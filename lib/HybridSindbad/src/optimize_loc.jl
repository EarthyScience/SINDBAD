# simpler forms


function gradsBatch!(loss_function::Function, up_params_now, f_grads, xbatch, sites_f, data, data_optim,
    tem, tblParams, land_init_space, approaches; logging=true)

    p = Progress(length(xbatch); desc="Computing batch grads...", offset=1, color=:yellow, enabled=logging)
    for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tblParams, xbatch, idx)
        site_location = name_to_id(site_name, sites_f)
        init_land = land_init_space[site_location[1][2]]

        loc_output, loc_forcing, loc_obs = getLocDataObsN(data..., data_optim.site_obs, site_location) # check output order in original definition

        inits = (; init_land, approaches)
        data_optim = (; site_obs = loc_obs, )
        data_cache = (; allocated_output = DiffCache.(loc_output), site_forcings= loc_forcing)

        gg = ForwardDiffGrads(loss_function, new_vals, inits, data_cache, data_optim, tem, tblParams)
        f_grads[:, idx] = gg

        next!(p; showvalues=[(:site_name, site_name)])
    end
end
