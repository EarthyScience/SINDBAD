noStackTrace()
# settings 
experiment_json = "../exp_hybrid/settings_hybrid/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify information from json with the replace_info
info, forcing = getForcing(info);
# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayWithNames(forcing);
observations = getObservation(info);
obs = getKeyedArrayWithNames(observations);

@time loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
f_one = prepRunEcosystem(output, forc, info.tem);
@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

tblParams = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

out_vars = Val(info.tem.variables)
helpers = info.tem.helpers # helpers
spinup = info.tem.spinup # spinup
models = info.tem.models # models
forward = info.tem.models.forward # forward

# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site;
c = Cube("examples/data/fluxnet_cube/fluxnet_covariates.zarr")
xfeatures = cube_to_KA(c)
# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]
sites = setdiff!(sites, ["RU-Ha1", "IT-PT1", "US-Me5"])
n_bs_feat = length(xfeatures.features)
