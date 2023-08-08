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

function pixel_run!(output,
    forc,
    obs,
    site_location,
    tblParams,
    forward,
    upVector,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_init_site,
    f_one)

    loc_forcing, loc_output, _ = getLocDataObsN(output.data, forc, obs, site_location)
    up_apps = updateModelParametersType(tblParams, forward, upVector)
    return coreEcosystem!(loc_output,
        up_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        land_init_site,
        f_one)
end

function space_run!(up_params,
    tblParams,
    sites_f,
    land_init_space,
    cov_sites,
    output,
    forc,
    obs,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    f_one)
    #Threads.@threads for site_index ∈ eachindex(cov_sites)
    p = Progress(size(cov_sites,1))
    for site_index ∈ eachindex(cov_sites)
        site_name = cov_sites[site_index]
        x_params = up_params(; site=site_name)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init = land_init_space[site_location[1][2]]
        pixel_run!(output,
            forc,
            obs,
            site_location,
            tblParams,
            forward,
            x_params,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_land_init,
            f_one
        )
        next!(p)
    end
end