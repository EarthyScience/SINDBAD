# simulate fake gpp obs
experiment_json = "../exp_hybrid/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify info
info, forcing = getForcing(info, Val{:zarr}());
# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

# covariates
# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
function cube_to_KA(c)
    namesCube = YAXArrayBase.dimnames(c)
    return KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
end

sites_f = forc.Tair.site;
c = Cube("examples/data/fluxnet_cube/fluxnet_covariates.zarr")
xfeatures = cube_to_KA(c)
# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]
sites = setdiff!(sites, ["RU-Ha1", "IT-PT1", "US-Me5"])
n_bs_feat = length(xfeatures.features)


loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,
land_init_space, tem_vals, f_one =
    prepRunEcosystem(output.data,
        output.land_init,
        info.tem.models.forward,
        forc,
        forcing.sizes,
        info.tem);
# neural network design

function ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=0, seed=1618) # ~ (1+√5)/2
    Random.seed!(seed)
    return Flux.Chain(Flux.Dense(n_bs_feat => n_neurons, Flux.relu),
        [Flux.Dense(n_neurons, n_neurons, Flux.relu) for _ ∈ 0:(extra_hlayers-1)]...,
        Flux.Dense(n_neurons => n_params, Flux.sigmoid))
end

function getParamsAct(pNorm, tblParams)
    lb = oftype(tblParams.defaults, tblParams.lower)
    ub = oftype(tblParams.defaults, tblParams.upper)
    pVec = pNorm .* (ub .- lb) .+ lb
    return pVec
end

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
    loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location)
    newApproaches = updateModelParametersType(tblParams, forward, upVector)
    return coreEcosystem!(loc_output,
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

#out_vars = Val(info.tem.variables)
#helpers = info.tem.helpers # helpers
#spinup = info.tem.spinup # spinup
#models = info.tem.models # models
#forward = info.tem.models.forward # forward

function name_to_id(site_name, sites_forcing)
    site_id_forc = findall(x -> x == site_name, sites_forcing)[1]
    return [Symbol("site") => site_id_forc]
end

space_run!(params_bounded,
    tblParams,
    land_init_space,
    cov_sites,
    output,
    forc,
    obs,
    info.tem.models.forward,
    info.tem.helpers,
    info.tem.spinup,
    info.tem.models,
    Val(info.tem.variables),
    f_one)


gppOut = output.data[1]
gpp_synt = reshape(gppOut, (4748, 205));
gppKA = KeyedArray(Float32.(gpp_synt); time=obs.gpp.time, site=obs.gpp.site)
obs_synt = (; gpp=gppKA, gpp_σ=obs.gpp_σ, gpp_mask=obs.gpp_mask)
