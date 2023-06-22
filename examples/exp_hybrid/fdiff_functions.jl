
#=
args = (;
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
    f_one)
=#
function fdiff_grads(f, v, site_location, loc_land_init, args)
    gf(v) = f(v, site_location, loc_land_init, args...)
    return ForwardDiff.gradient(gf, v)
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
    f_one)

    loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location)
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
        f_grads[:, site_index] = fdiff_grads(loc_loss, v, site_location, loc_land_init, args)
    end
end

include("pkgs.jl")
include("setup_exp.jl")
n_params = sum(tblParams.is_ml)
n_neurons = 32

site_location = loc_space_maps[1];
loc_land_init = land_init_space[1];
loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location);

args = (;
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
    f_one);

@time fdiff_grads(loc_loss, tblParams.defaults, site_location, loc_land_init, args)

@code_warntype fdiff_grads(loc_loss, tblParams.defaults, site_location, loc_land_init, args)