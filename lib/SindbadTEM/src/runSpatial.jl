export pixel_run!
export getLocDataObsN
export getParamsAct
export space_run!
export space_run_distributed!

function getLocDataObsN(outcubes, forcing, obs_array, loc_space_ind)
    loc_forcing = getLocForcingData(forcing, loc_space_ind)
    loc_obs = getLocForcingData(obs_array, loc_space_ind)
    loc_output = getLocOutputData(outcubes, loc_space_ind)
    return loc_forcing, loc_output, loc_obs
end

# function getLocDataObsN(outcubes, forcing, obs, loc_space_map)
#     loc_forcing = map(forcing) do a
#         return view(a; loc_space_map...)
#     end
#     loc_obs = map(obs) do a
#         return Array(view(a; loc_space_map...))
#     end
#     ar_inds = Tuple(last.(loc_space_map))
#     loc_output = map(outcubes) do a
#         return getArrayView(a, ar_inds)
#     end
#     return loc_forcing, loc_output, loc_obs
# end

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
    param_to_index,
    all_sites,
    land_init_space,
    b_data,
    obs,
    cov_sites,
    forcing_one_timestep,
    loc_spinup_forcings,
    tem
)
    p = Progress(size(cov_sites,1))
    for site_index ∈ eachindex(cov_sites)
        site_name = cov_sites[site_index]
        new_params = up_params(; site=site_name)

        site_location = name_to_id(site_name, all_sites)
        loc_land_init = land_init_space[site_location[1]]

        loc_spinup_forcing = loc_spinup_forcings[site_location[1]];

        loc_forcing, loc_output, loc_obs = getLocDataObsN(b_data.allocated_output, b_data.forcing, obs, site_location)
        new_approaches = updateModelParametersType(param_to_index, selected_models, new_params)

        coreTEM!(
            new_approaches,
            loc_forcing,
            loc_spinup_forcing,
            forcing_one_timestep,
            loc_output,
            loc_land_init,
            tem...)
        next!(p)
    end
end

function space_run_distributed!(
    selected_models,
    up_params,
    param_to_index,
    all_sites,
    land_init_space,
    b_data,
    obs,
    cov_sites,
    forcing_one_timestep,
    loc_spinup_forcings,
    tem
)
    p = Progress(size(cov_sites,1))
    @showprogress @distributed for site_index ∈ eachindex(cov_sites)

        site_name = cov_sites[site_index]
        new_params = up_params(; site=site_name)
        site_location = name_to_id(site_name, all_sites)
        loc_land_init = land_init_space[site_location[1]]
        loc_spinup_forcing = loc_spinup_forcings[site_location[1]];

        loc_forcing, loc_output, loc_obs = getLocDataObsN(b_data.allocated_output, b_data.forcing, obs, site_location)
        new_approaches = updateModelParametersType(param_to_index, selected_models, new_params)

        coreTEM!(
            new_approaches,
            loc_forcing,
            loc_spinup_forcing,
            forcing_one_timestep,
            loc_output,
            loc_land_init,
            tem...)
        next!(p)
    end
end