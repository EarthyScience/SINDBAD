using Sindbad, SindbadTEM, SindbadOptimization
using YAXArrays, YAXArrayBase
using AxisKeys
using Flux
using Random
using GLMakie

# simulate synth obs
experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);
forcing = getForcing(info);
land_init = createLandInit(info.pools, info.tem);

observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
obsv = getKeyedArray(observations);
tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);

# covariates
function yaxCubeToKeyedArray(c)
    namesCube = YAXArrayBase.dimnames(c)
    return KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
end

sites_f = forc.f_airT.site;
c = Cube("examples/data/fluxnet_cube/fluxnet_covariates.zarr")
xfeatures = yaxCubeToKeyedArray(c)
# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]
sites = setdiff!(sites, ["RU-Ha1", "IT-PT1", "US-Me5"])
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

run_helpers = prepTEM(forcing, info);
loc_forcings = run_helpers.loc_forcings;
forcing_one_timestep = run_helpers.forcing_one_timestep;
output_array = run_helpers.output_array;
loc_outputs = run_helpers.loc_outputs;
land_init_space = run_helpers.land_init_space;
tem_with_types = run_helpers.tem_with_types;

# neural network design

function ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=0, seed=1618) # ~ (1+√5)/2
    Random.seed!(seed)
    return Flux.Chain(Flux.Dense(n_bs_feat => n_neurons, Flux.relu),
        [Flux.Dense(n_neurons, n_neurons, Flux.relu) for _ ∈ 0:(extra_hlayers-1)]...,
        Flux.Dense(n_neurons => n_params, Flux.sigmoid))
end


ml_baseline = ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)

sites_parameters = ml_baseline(xfeatures)
params_bounded = getParamsAct.(sites_parameters, tbl_params)

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

function pixel_run!(output_array,
    forcing_nt_array,
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

    loc_forcing, loc_output, loc_obs = getLocDataObsN(output_array, forc, obs_array, site_location)
    up_apps = Tuple(updateModelParametersType(tbl_params, forward, upVector))
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

site_location = loc_space_maps[1];
loc_forcing, loc_output, loc_obs =
    getLocDataObsN(output_array,
        forc, obs_array, site_location);

loc_land_init = run_helpers.land_one;
loc_output = loc_outputs[1];
loc_forcing = run_helpers.loc_forcings[1];

def_params = tbl_params.default .* rand()
pixel_run!(output,
    forc,
    obs_array,
    site_location,
    tbl_params,
    forward,
    def_params,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_land_init,
    forcing_one_timestep)


loc_forcing, loc_output, loc_obs = getLocDataObsN(output_array, forc, obs_array, site_location)

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

#out_vars = Val(info.tem.variables)
#helpers = info.tem.helpers # helpers
#spinup = info.tem.spinup # spinup
#models = info.tem.models # models
#forward = info.tem.models.forward # forward

function name_to_id(site_name, sites_forcing)
    site_id_forc = findall(x -> x == site_name, sites_forcing)
    id_site = !isempty(site_id_forc) ? [Symbol("site") => site_id_forc[1]] : error("site not available")
    return id_site
end

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
    forcing_one_timestep)



gppOut = run_helpers.output_array[1]
t_steps = info.tem.helpers.dates.size

gpp_synt = reshape(gppOut, (t_steps, 205));
gppKA = KeyedArray(Float32.(gpp_synt); time=obs.gpp.time, site=obs.gpp.site)

neeOut = run_helpers.output_array[2];
nee_synt = reshape(neeOut, (t_steps, 205));
t_plot = 15

series(permutedims(gpp_synt[:, 1:t_plot], (2, 1)); color=resample_cmap(:glasbey_hv_n256, t_plot))

neeKA = KeyedArray(Float32.(nee_synt); time=obs.gpp.time, site=obs.gpp.site)

series(permutedims(nee_synt[:, 1:t_plot], (2, 1)); color=resample_cmap(:glasbey_hv_n256, t_plot))

transpirationOut = run_helpers.output_array[3];
transpiration_synt = reshape(transpirationOut, (t_steps, 205));
transpirationKA = KeyedArray(Float32.(transpiration_synt); time=obs.gpp.time, site=obs.gpp.site);
series(permutedims(transpiration_synt[:, 1:t_plot], (2, 1)); color=resample_cmap(:glasbey_hv_n256, t_plot))


evapotranspirationOut = run_helpers.output_array[4];
evapotranspiration_synt = reshape(evapotranspirationOut, (t_steps, 205));
evapotranspirationKA = KeyedArray(Float32.(evapotranspiration_synt); time=obs.gpp.time,
    site=obs.gpp.site)
series(permutedims(evapotranspiration_synt[:, 1:t_plot], (2, 1));
    color=resample_cmap(:glasbey_hv_n256, t_plot))


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
