export pixel_run!
export getLocDataObsN
export getParamsAct
export name_to_id
export space_run!
export ids_location

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

function getParamsAct(pNorm, tblParams)
    lb = oftype(tblParams.default, tblParams.lower)
    ub = oftype(tblParams.default, tblParams.upper)
    pVec = pNorm .* (ub .- lb) .+ lb
    return pVec
end

"""
`name_to_id`(`site_name`, `sites_forcing`)
"""
function name_to_id(site_name, sites_forcing)
    site_id_forc = findall(x -> x == site_name, sites_forcing)
    id_site = !isempty(site_id_forc) ? [Symbol("site") => site_id_forc[1]] : error("site not available")
    return id_site
end

"""
`ids_location`(cov_sites, `sites_f`)
"""
function ids_location(cov_sites, sites_f)
    ids = Int[]
    for site_index ∈ eachindex(cov_sites)
        site_name = cov_sites[site_index]
        site_location = name_to_id(site_name, sites_f)
        push!(ids, site_location[1][2])
    end
    return ids
end

function pixel_run!(inits, data, tem)
    return coreTEM!(inits.selected_models, data..., inits.land_init, tem...)
end

function space_run!(
    up_params,
    tblParams,
    sites_f,
    land_init_space,
    data,
    data_optim,
    tem
)
    #Threads.@threads for site_index ∈ eachindex(cov_sites)
    p = Progress(size(data_optim.cov_sites,1))
    for site_index ∈ eachindex(data_optim.cov_sites)
        site_name = data_optim.cov_sites[site_index]
        new_params = up_params(; site=site_name) |> getParamsAct

        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        
        loc_forcing, loc_output, _ =
            getLocDataObsN(data.allocated_output, data.forcing, data_optim.obs, site_location)

        new_approaches = updateModelParametersType(tblParams, inits.selected_models, new_params)
        inits = (; selected_models=new_approaches, land_init=loc_land_init)
        data = (; loc_forcing, forcing_one_timestep, allocated_output = loc_output)

        pixel_run!(inits, data, tem)
        next!(p)
    end
end