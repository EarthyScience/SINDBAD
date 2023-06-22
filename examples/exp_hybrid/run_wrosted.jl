include("pkgs.jl")
include("setup_wrosted.jl")
n_params = sum(tblParams.is_ml)
n_neurons = 32

include("obs_synt_wrosted.jl")

include("nn_machine.jl")

nn_args = (; n_bs_feat, n_neurons, n_params, extra_layer = 2, nn_opt = Optimisers.Adam())

tem_variables = info.tem.variables
tem_optim = info.optim
out_variables = info.tem.variables

tem_helpers = info.tem.helpers
tem_spinup = info.tem.spinup
tem_models = info.tem.models
tem_variables = info.tem.variables
tem_optim = info.optim
out_variables = output.variables

grads_args = (;
    tblParams,
    sites_f,
    land_init_space,
    output,
    forc,
    obs_synt,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one,
);

x_args = (; shuffle = true, bs = 16, sites = sites)

nn_machine(nn_args, x_args, xfeatures, grads_args; nepochs = 2)
