function fdiff_grads(f, v, site_location, loc_land_init, args)
    gf = v -> f(v, site_location, loc_land_init, args...)
    return ForwardDiff.gradient(gf, v)
end


function fdiff_grads!(f, v, n, site_location, loc_land_init, args)
    gf = v -> f(v, site_location, loc_land_init, args...)
    cfg_n = GradientConfig(gf, v, Chunk{n}());
    out = similar(v)
    ForwardDiff.gradient!(out, gf, v, cfg_n)
    return out
end

function loc_loss(upVector,
    site_location, 
    loc_land_init,
    output,
    forc,
    obs,
    tblParams,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one,
    )

    #loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location)::f_type
    getLocOutput!(output.data, loc_space_ind, loc_output)
    getLocForcing!(forc, Val(keys(f_one)), Val(loc_space_names), loc_forcing, loc_space_ind)
    getLocObs!(obs, Val(keys(obs)), Val(loc_space_names), loc_obs, loc_space_ind)

    newApproaches = updateModelParametersType(tblParams, forward, upVector)
    return get_loc_loss(loc_obs,
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
end

function grads_batch!(f_grads, up_params, xbatch, sites_f, land_init_space, loc_loss, args)
    Threads.@threads for site_index ∈ eachindex(xbatch)
        site_name = xbatch[site_index]
        x_params = up_params(; site=site_name)
        v = getParamsAct(x_params, args.tblParams)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        f_grads[:, site_index] = ForwardDiff.gradient(x->loc_loss(x, site_location, loc_land_init, args...), v) #fdiff_grads(loc_loss, v, site_location, loc_land_init, args)
    end
end

function loc_loss_f(upVector,
    loc_space_ind, 
    loc_output,
    loc_forcing,
    v_loc_space_names,
    loc_obs,
    loc_land_init,
    output,
    forc,
    obs,
    tblParams,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one,
    )
    getLocOutput!(output.data, loc_space_ind, loc_output)
    getLocForcing!(forc, Val(keys(f_one)), v_loc_space_names, loc_forcing, loc_space_ind)
    getLocObs!(obs, Val(keys(obs)), v_loc_space_names, loc_obs, loc_space_ind)

    newApproaches = updateModelParametersType(tblParams, forward, upVector)

    return get_loc_loss(loc_obs,
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
end