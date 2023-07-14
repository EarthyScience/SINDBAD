# simulate fake gpp obs
experiment_json = "../exp_hybrid/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify info
info, forcing = getForcing(info, Val{:zarr}());
# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output, forc, info.tem);

ml_baseline = ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)

sites_parameters = ml_baseline(xfeatures)
params_bounded = getParamsAct.(sites_parameters, tblParams)

function pixel_run!(output,
    forc,
    obs,
    site_location,
    tblParams,
    forward,
    upVector,
    helpers,
    spinup,
    models,
    out_vars,
    land_init_site,
    f_one)
    loc_forcing, loc_output, loc_obs = getLocDataObs(output.data, forc, obs, site_location)
    newApproaches = updateModelParametersType(tblParams, forward, upVector)
    return ForwardSindbad.coreEcosystem!(loc_output,
        newApproaches,
        loc_forcing,
        helpers,
        spinup,
        models,
        out_vars,
        land_init_site,
        f_one)
end

function space_run!(up_params,
    tblParams,
    land_init_space,
    cov_sites,
    output,
    forc,
    obs,
    forward,
    helpers,
    spinup,
    models,
    out_vars,
    f_one)
    Threads.@threads for site_index ∈ eachindex(cov_sites)
        site_name = cov_sites[site_index]
        x_params = up_params(; site=site_name)
        site_location = name_to_id(site_name, sites_f)
        land_init_site = land_init_space[site_location[1][2]]
        pixel_run!(output,
            forc,
            obs,
            site_location,
            tblParams,
            forward,
            x_params,
            helpers,
            spinup,
            models,
            out_vars,
            land_init_site,
            f_one)
    end
end
cov_sites = xfeatures.site

space_run!(params_bounded,
    tblParams,
    land_init_space,
    cov_sites,
    output,
    forc,
    obs,
    forward,
    helpers,
    spinup,
    models,
    out_vars,
    f_one)

gppOut = output.data[1]
gpp_synt = reshape(gppOut, (4748, 205));
gppKA = KeyedArray(Float32.(gpp_synt); time=obs.gpp.time, site=obs.gpp.site)

neeOut = output.data[2]
nee_synt = reshape(neeOut, (4748, 205));
neeKA = KeyedArray(Float32.(nee_synt); time=obs.gpp.time, site=obs.gpp.site)

transpirationOut = output.data[3]
transpiration_synt = reshape(transpirationOut, (4748, 205));
transpirationKA = KeyedArray(Float32.(transpiration_synt); time=obs.gpp.time, site=obs.gpp.site)

evapotranspirationOut = output.data[4]
evapotranspiration_synt = reshape(evapotranspirationOut, (4748, 205));
evapotranspirationKA = KeyedArray(Float32.(evapotranspiration_synt); time=obs.gpp.time,
    site=obs.gpp.site)

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
