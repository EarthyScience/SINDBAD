using Revise
using SindbadML
using YAXArrays, YAXArrayBase
using AxisKeys
using Flux
using Random
using GLMakie

include("plot_makie.jl")

# setup experiment
experiment_json = "../exp_hybrid_benchmark/settings_hybrid_benchmark/experiment.json"
info = getExperimentInfo(experiment_json);
info, forcing = getForcing(info);
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
output = setupOutput(info);
forc = getKeyedArrayWithNames(forcing);
observations = getObservation(info);
obs = getKeyedArrayWithNames(observations);
obsv = getKeyedArray(observations);
tblParams = getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
tem_with_vals,
f_one = prepRunEcosystem(output, forc, info.tem);

# load available covariates

# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr"))
xfeatures = cube_to_KA(c)
# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]

# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tblParams.is_ml)

ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)
sites_parameters = ml_baseline(xfeatures)
params_bounded = getParamsAct.(sites_parameters, tblParams)
cov_sites = xfeatures.site

# do spatial run
tem_helpers = tem_with_vals.helpers;
tem_spinup = tem_with_vals.spinup;
tem_models = tem_with_vals.models;
tem_variables = tem_with_vals.variables;
tem_optim = info.optim;
out_variables = output.variables;
forward = tem_with_vals.models.forward;

# do the run with default parameters
params_bounded .= tblParams.default

space_run!(params_bounded,
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
    f_one);

ids_locs = ids_location(cov_sites, sites_f)

tempo = string.(Date.(forc.Tair.time))
out_names = info.optim.variables.obs
#plot_output(output, obs, out_names, cov_sites, sites_f, tempo)

# do the run with the original bounded parameters
params_bounded = getParamsAct.(sites_parameters, tblParams)

space_run!(params_bounded,
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
    f_one);

#plot_output(output, obs, out_names, cov_sites, sites_f, tempo)

function assemble_synt(output, out_names, time_range, site_names)
    k_arrs = []
    for out_data in output.data
        t_steps = size(out_data,1)
        n_site = size(out_data,3)
        data_synt = reshape(out_data, (t_steps, n_site))
        dataKA = KeyedArray(Float32.(data_synt); time=time_range, site=site_names)
        push!(k_arrs, dataKA)
    end
    k_arr = (; Pair.(out_names, k_arrs)...)
    return k_arr
end

time_range = obs.gpp.time
site_names = obs.gpp.site
k_arrs = assemble_synt(output, out_names, time_range, site_names)

obs_synt = (; obs..., k_arrs...)
