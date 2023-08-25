export pixel_run!
export getLocDataObsN
export getParamsAct
export space_run!
export space_run_distributed!

function getLocDataObsN(outcubes, forcing, obs, loc_space_map)
    loc_forcing = map(forcing) do a
        return view(a; loc_space_map...)
    end
    loc_obs = map(obs) do a
        return view(a; loc_space_map...)
    end
    ar_inds = Tuple(last.(loc_space_map))
    loc_output = map(outcubes) do a
        return getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output, loc_obs
end

function getParamsAct(pNorm, tblParams)
    lb = oftype(tblParams.default, tblParams.lower)
    ub = oftype(tblParams.default, tblParams.upper)
    pVec = pNorm .* (ub .- lb) .+ lb
    return pVec
end

function pixel_run!(inits, data, tem)
    return coreTEM!(inits..., data..., tem...)
end

function space_run!(
    selected_models,
    up_params,
    tbl_params,
    sites_f,
    land_init_space,
    b_data,
    obs,
    cov_sites,
    forcing_one_timestep,
    tem
)
    #Threads.@threads for site_index ∈ eachindex(cov_sites)
    p = Progress(size(cov_sites,1))
    for site_index ∈ eachindex(cov_sites)
        site_name = cov_sites[site_index]
        new_params = up_params(; site=site_name)

        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        
        loc_forcing, loc_output, loc_obs = getLocDataObsN(b_data.allocated_output, b_data.forcing, obs, site_location)
        new_approaches = updateModelParametersType(tbl_params, selected_models, new_params)
        inits = (; selected_models=new_approaches, land_init=loc_land_init)
        data = (; loc_forcing, forcing_one_timestep, allocated_output = loc_output)

        pixel_run!(inits, data, tem)
        next!(p)
    end
end

function space_run_distributed!(
    selected_models,
    up_params,
    tbl_params,
    sites_f,
    land_init_space,
    b_data,
    obs,
    cov_sites,
    forcing_one_timestep,
    tem
)
    #p = Progress(size(cov_sites,1))

    @showprogress @distributed for site_index ∈ eachindex(cov_sites)

        site_name = cov_sites[site_index]
        new_params = up_params(; site=site_name)

        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        
        loc_forcing, loc_output, loc_obs = getLocDataObsN(b_data.allocated_output, b_data.forcing, obs, site_location)
        new_approaches = updateModelParametersType(tbl_params, selected_models, new_params)
        inits = (; selected_models=new_approaches, land_init=loc_land_init)
        data = (; loc_forcing, forcing_one_timestep, allocated_output = loc_output)

        pixel_run!(inits, data, tem)
     #   next!(p)
    end
end