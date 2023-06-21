include("pkgs.jl")
include("setup_exp.jl")
n_params = sum(tblParams.is_ml)
n_neurons = 32

include("obs_synt.jl")
include("nn_machine.jl")

nn_args = (; n_bs_feat, n_neurons, n_params, extra_layer=2, nn_opt = Optimisers.Adam(),)
grads_args = (; tblParams, sites_f, land_init_space, output, forc, obs_synt, forward, helpers, spinup, models, out_vars, f_one);

x_args = (; shuffle=true, bs=16, sites=sites)

nn_machine(nn_args, x_args,  xfeatures; nepochs=2)