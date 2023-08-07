using Sindbad
using ForwardDiff
using Flux, Optimisers, Zygote
using Statistics
using ProgressMeter

include("old_gen_wrosted_obs.jl");
include("old_loss.jl");
include("old_nn_machine.jl");

syn = synth_obs();
allvals = [sum(syn.obs_synt.gpp[site=i]) for i in 1:205];
to_keep = .!isnan.(allvals);
sites_obs = syn.obs_synt.gpp.site[to_keep];
new_batch = intersect(sites_obs, syn.xfeatures.site);


kwargs_fixed = (;
    tem_helpers=syn.tem_helpers,
    tem_spinup=syn.tem_spinup,
    tem_models=syn.tem_models,
    tem_optim=syn.tem_optim,
    f_one=syn.f_one
);

site_location = syn.loc_space_maps[1]
loc_land_init = syn.land_init_space[1];

loc_forcing_test, _, loc_obs_test =
    getLocDataObsN(syn.out_data,
        syn.forc, syn.obs_synt, site_location);

# this does one gradient calculation for one site.        
fdiff_grads(loc_loss,
    syn.tblParams.default,
    syn.forward,
    syn.tblParams,
    loc_obs_test,
    loc_forcing_test,
    loc_land_init,
    kwargs_fixed)


# now for a batch with 16 sites
n_bs = 16
f_grads = zeros(Float32, syn.n_params, n_bs);
xbatch = new_batch[1:n_bs] #syn.cov_sites[1:n_bs];
f_grads = zeros(Float32, syn.n_params, n_bs);
x_feat = syn.xfeatures(; site=xbatch)

ml_test = ml_nn(length(syn.xfeatures.features), syn.n_neurons, syn.n_params;
    extra_hlayers=2, seed=153);

# new synthetic parameters as test.
inst_params_new = ml_test(x_feat)

grads_batch!(f_grads, inst_params_new, xbatch,
    syn.out_data,
    syn.forc,
    syn.obs_synt,
    syn.sites_f,
    syn.forward,
    syn.tblParams,
    syn.land_init_space,
    loc_loss,
    kwargs_fixed
);


# now for the full training
x_args = (;
    shuffle=true,
    bs=16,
    sites=new_batch #syn.sites
);

nn_args = (;
    n_bs_feat=length(syn.xfeatures.features),
    n_neurons=32,
    n_params=sum(syn.tblParams.is_ml),
    extra_layer=2,
    nn_opt=Optimisers.Adam()
);

experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json";
info = getExperimentInfo(experiment_json);
info, forcing = getForcing(info);
land_init = createLandInit(info.pools, info.tem, info.tem.models.forward);
output = setupOutput(info);
forc = getKeyedArrayWithNames(forcing);

# this one does all the training
train_losses = nn_machine(nn_args, x_args,
    syn.xfeatures,
    info,
    syn.forc,
    syn.obs_synt,
    syn.sites_f,
    syn.forward,
    syn.tblParams,
    info.tem,
    loc_loss,
    kwargs_fixed; nepochs=3);