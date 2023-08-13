using Sindbad, SindbadTEM, SindbadOptimization
using YAXArrays, YAXArrayBase
using AxisKeys
using Flux
using Random
#using GLMakie

function getLocDataObsN(outcubes, forcing, obs_array, loc_space_map)
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
# neural network design

function ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=0, seed=1618) # ~ (1+√5)/2
    Random.seed!(seed)
    return Flux.Chain(Flux.Dense(n_bs_feat => n_neurons, Flux.relu),
        [Flux.Dense(n_neurons, n_neurons, Flux.relu) for _ ∈ 0:(extra_hlayers-1)]...,
        Flux.Dense(n_neurons => n_params, Flux.sigmoid))
end

function getParamsAct(pNorm, tbl_params)
    lb = oftype(tbl_params.default, tbl_params.lower)
    ub = oftype(tbl_params.default, tbl_params.upper)
    pVec = pNorm .* (ub .- lb) .+ lb
    return pVec
end

function name_to_id(site_name, sites_forcing)
    site_id_forc = findall(x -> x == site_name, sites_forcing)
    id_site = !isempty(site_id_forc) ? [Symbol("site") => site_id_forc[1]] : error("site not available")
    return id_site
end
# simulate synth obs
# function synth_obs()

experiment_json = "../exp_hybrid_simple/settings_hybrid_simple/experiment.json"
info = getExperimentInfo(experiment_json);
forcing = getForcing(info);
# forcing = getForcing(info);










land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models)


observations = getObservation(info, forcing.helpers)
obs_array = getKeyedArrayWithNames(observations)
obsv = getKeyedArray(observations)
tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize)

# covariates
function cube_to_KA(c)
    namesCube = YAXArrayBase.dimnames(c)
    return KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
end

sites_f = forc.Tair.site
c = Cube("examples/data/fluxnet_cube/fluxnet_covariates.zarr")
xfeatures = cube_to_KA(c)
# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]
# sites = setdiff!(sites, ["RU-Ha1", "IT-PT1", "US-Me5"])
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

forcing_nt_array,
output_array,
loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_types,
forcing_one_timestep = prepTEM(forcing, info);


@time runTEM!(output_array,
    info.tem.models.forward,
    forc,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    forcing_one_timestep,
    tem_with_types)


ml_baseline = ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)

sites_parameters = ml_baseline(xfeatures)
#@show sites_parameters
#sites_parameters .= 0.0
#@show sites_parameters

params_bounded = getParamsAct.(sites_parameters, tbl_params)

function pixel_run!(output,
    forc,
    obs_array,
    site_location,
    tbl_params,
    forward,
    upVector,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_init_site,
    forcing_one_timestep)

    loc_forcing, loc_output, _ = getLocDataObsN(output_array, forc, obs_array, site_location)
    up_apps = updateModelParametersType(tbl_params, forward, upVector)
    return coreTEM!(loc_output,
        up_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        land_init_site,
        forcing_one_timestep)
end

tem_helpers = tem_with_types.helpers;
tem_spinup = tem_with_types.spinup;
tem_models = tem_with_types.models;
tem_variables = tem_with_types.variables;
tem_optim = info.optim;
forward = tem_with_types.models.forward;

site_location = loc_space_maps[1]
loc_forcing, loc_output, loc_obs =
    getLocDataObsN(output_array,
        forc, obs_array, site_location)

loc_space_ind = loc_space_inds[1]
loc_land_init = land_init_space[1]
loc_output = loc_outputs[1]
loc_forcing = loc_forcings[1]

pixel_run!(output,
    forc,
    obs_array,
    site_location,
    tbl_params,
    forward,
    tbl_params.default,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    forcing_one_timestep)


# loc_forcing, loc_output, loc_obs = getLocDataObsN(output_array, forc, obs_array, site_location)

function space_run!(up_params,
    tbl_params,
    sites_f,
    land_init_space,
    cov_sites,
    output,
    forc,
    obs_array,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    forcing_one_timestep)
    #Threads.@threads for site_index ∈ eachindex(cov_sites)
    for site_index ∈ eachindex(cov_sites)
        site_name = cov_sites[site_index]
        x_params = up_params(; site=site_name)
        site_location = name_to_id(site_name, sites_f)
        @show site_location, site_location[1][2]
        loc_land_init = land_init_space[site_location[1][2]]
        pixel_run!(output,
            forc,
            obs_array,
            site_location,
            tbl_params,
            forward,
            x_params,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_land_init,
            forcing_one_timestep
        )
    end
end
cov_sites = xfeatures.site

space_run!(params_bounded,
    tbl_params,
    sites_f,
    land_init_space,
    cov_sites,
    output,
    forc,
    obs_array,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    forcing_one_timestep);



gppOut = output_array[1]
t_steps = info.tem.helpers.dates.size

gpp_synt = reshape(gppOut, (t_steps, 205))
gppKA = KeyedArray(Float32.(gpp_synt); time=obs.gpp.time, site=obs.gpp.site)

neeOut = output_array[2]
nee_synt = reshape(neeOut, (t_steps, 205))
t_plot = 15

#series(permutedims(gpp_synt[:, 1:t_plot], (2, 1)); color=resample_cmap(:glasbey_hv_n256, t_plot))

neeKA = KeyedArray(Float32.(nee_synt); time=obs.gpp.time, site=obs.gpp.site)

#series(permutedims(nee_synt[:, 1:t_plot], (2, 1)); color=resample_cmap(:glasbey_hv_n256, t_plot))

transpirationOut = output_array[3]
transpiration_synt = reshape(transpirationOut, (t_steps, 205))
transpirationKA = KeyedArray(Float32.(transpiration_synt); time=obs.gpp.time, site=obs.gpp.site)
#series(permutedims(transpiration_synt[:, 1:t_plot], (2, 1)); color=resample_cmap(:glasbey_hv_n256, t_plot))


evapotranspirationOut = output_array[4]
evapotranspiration_synt = reshape(evapotranspirationOut, (t_steps, 205))
evapotranspirationKA = KeyedArray(Float32.(evapotranspiration_synt); time=obs.gpp.time,
    site=obs.gpp.site)
#series(permutedims(evapotranspiration_synt[:, 1:t_plot], (2, 1));
#   color=resample_cmap(:glasbey_hv_n256, t_plot))



obs_synt = (;
    gpp=gppKA,
    gpp_σ=obs.gpp_σ,
    gpp_mask=obs.gpp_mask,
    nee=neeKA,
    nee_σ=obs.nee_σ,
    nee_mask=obs.nee_mask,
    transpiration=transpirationKA,
    transpiration_σ=obs.transpiration_σ,
    transpiration_mask=obs.transpiration_mask,
    evapotranspiration=evapotranspirationKA,
    evapotranspiration_σ=obs.evapotranspiration_σ,
    evapotranspiration_mask=obs.evapotranspiration_mask)

return (; obs_synt,
    forc,
    xfeatures,
    cov_sites,
    sites,
    sites_f,
    params_bounded,
    tbl_params,
    n_params,
    n_neurons,
    loc_forcings,
    loc_outputs,
    land_init_space,
    loc_space_maps,
    forward,
    out_data=output_array,
    tem_helpers,
    tem_models,
    tem_optim,
    tem_spinup,
    tem_with_types,
    forcing_one_timestep
)
# end


syn = synth_obs();
