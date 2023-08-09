using ForwardDiff
using HybridSindbad
using PreallocationTools
#using Flux, Optimisers, Zygote
using Statistics
#using ProgressMeter

include("syn_obs.jl");
#syn = synth_obs();
# setup experiment
experiment_json = "../exp_hybrid_benchmark/settings_hybrid_benchmark/experiment.json";
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

# fix arguments
tem_helpers = tem_with_vals.helpers;
tem_spinup = tem_with_vals.spinup;
tem_models = tem_with_vals.models;
tem_variables = tem_with_vals.variables;
tem_optim = info.optim;
out_variables = output.variables;
forward = tem_with_vals.models.forward;

# batch
allvals = [sum(obs_synt.gpp[site=i]) for i in 1:205];
to_keep = .!isnan.(allvals);
sites_obs = obs_synt.gpp.site[to_keep];
new_batch = intersect(sites_obs, xfeatures.site);

site_location = loc_space_maps[1]
loc_land_init = land_init_space[1];

loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs_synt, site_location);

# do one loss
get_loc_loss(
    forward,
    loc_output,
    loc_obs,
    loc_forcing,
    loc_land_init,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)

out_data_cache = DiffCache.(output.data);

# do one loss with DiffCache AND updating parameters

kwargs = (;
    loc_land_init,
    site_location,
    out_data_cache,
    forc,
    obs_synt,
    forward,
    tblParams,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one
);

loc_loss_inner(tblParams.default, kwargs...)

# this does one gradient calculation for one site.
ForwardDiffGrads(loc_loss_inner, tblParams.default, kwargs...)

println("second time:")

@time ForwardDiffGrads(loc_loss_inner, tblParams.default, kwargs...)

# now for a batch with 4 sites
n_bs = 4
f_grads = zeros(Float32, n_params, n_bs);
xbatch = new_batch[1:n_bs] #syn.cov_sites[1:n_bs];
f_grads = zeros(Float32, n_params, n_bs);
x_feat = xfeatures(; site=xbatch)

ml_test = DenseNN(length(xfeatures.features), n_neurons, n_params;
    extra_hlayers=2, seed=15233);
# new synthetic parameters as test.
inst_params_new = ml_test(x_feat)
sites_f = forc.Tair.site

kwargs_batch = (;
    sites_f,
    land_init_space,
    out_data_cache,
    forc,
    obs_synt,
    forward,
    tblParams,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one
);



#gradsBatch!(loc_loss_inner, f_grads, inst_params_new, xbatch, kwargs_batch...)
init_model = DenseNN(length(xfeatures.features), n_neurons, n_params; extra_hlayers=2)
flat, re, opt_state = destructureNN(init_model)
n_params = length(init_model[end].bias)
#∇params = get∇params(loc_loss_inner, xfeatures, re, flat, xbatch, n_params, kwargs_batch...)
tot_loss, re, flat = exMachina(init_model, loc_loss_inner, xfeatures[site=1:12], kwargs_batch...)
