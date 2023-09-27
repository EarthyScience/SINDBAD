# install dependencies by running the following line first:
# dev ../.. ../../lib/SindbadUtils/ ../../lib/SindbadData/ ../../lib/SindbadMetrics/ ../../lib/SindbadSetup/ ../../lib/SindbadTEM ../../lib/SindbadML
using SindbadData
using SindbadTEM
using YAXArrays
using SindbadML
using ForwardDiff
using Zygote
using Optimisers
using PreallocationTools
using JLD2

toggleStackTraceNT()

experiment_json = "../exp_hack_gradient/settings_gradient/experiment.json"

info = getExperimentInfo(experiment_json);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

#forc = (; Pair.(forcing.variables, forcing.data)...);
#obs = (; Pair.(observations.variables, observations.data)...);

#land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);

#op = prepTEMOut(info, forcing.helpers);
models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);
models_lt = LongTuple(models...);

run_helpers = prepTEM(models_lt, forcing, observations, info);

forcing_one_timestep = run_helpers.forcing_one_timestep;
land_init = run_helpers.land_one;
tem = (;
    tem_helpers = run_helpers.tem_with_types.helpers,
    tem_models = run_helpers.tem_with_types.models,
    tem_spinup = run_helpers.tem_with_types.spinup,
    tem_run_spinup = run_helpers.tem_with_types.helpers.run.spinup.spinup_TEM,
);

# site specific variables
loc_forcings = run_helpers.loc_forcings;
loc_observations = run_helpers.loc_observations;
loc_outputs = run_helpers.loc_outputs;
loc_spinup_forcings = run_helpers.loc_spinup_forcings;
loc_space_inds = run_helpers.loc_space_inds;
site_location = loc_space_inds[1][1]
loc_forcing = loc_forcings[site_location];
loc_obs = loc_observations[site_location];
loc_output = loc_outputs[site_location];
loc_spinup_forcing = loc_spinup_forcings[site_location];


# run the model
@time coreTEM!(
        models_lt,
        loc_forcing,
        loc_spinup_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem...)

# cost related
cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
constraint_method = info.optim.multi_constraint_method

    
# println("Do gradient")

# catched_model_args = []

# @time f_grads_one = ForwardDiffGrads(
#     siteLossInner,
#     tbl_params.default,
#     models_lt,
#     loc_forcing,
#     loc_spinup_forcing,
#     forcing_one_timestep,
#     DiffCache.(loc_output),
#     land_init,
#     tem,
#     param_to_index,
#     loc_obs,
#     cost_options,
#     constraint_method
#     )

   

# ForwardDiff.gradient(f, x)
# load available covariates
# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_forcing = forcing.data[1].site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr")); #"/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr"
xfeatures = cube_to_KA(c)

sites_feature = xfeatures.site
sites_feature = [s for s ∈ sites_feature]

# remove bad sites
sites_feature = setdiff(sites_feature, ["CA-NS6", "SD-Dem", "US-WCr", "ZM-Mon"])
xfeatures = xfeatures(site=sites_feature)

# pseudo batch
sites_batch = ["AR-SLu", "AT-Neu", "AU-Cum"]
# sites_forcing[1:4]

# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)
ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)

parameters_sites = ml_baseline(xfeatures)

grads_batch = zeros(Float32, n_params, length(sites_batch))

indices_batch = name_to_id.(sites_batch, Ref(sites_forcing))
params_batch = parameters_sites(; site=sites_batch)
scaled_params_batch = getParamsAct(params_batch, tbl_params)

gradsBatch!(
        siteLossInner,
        grads_batch,
        scaled_params_batch,
        models_lt,
        sites_batch,
        indices_batch,
        sites_forcing,
        loc_forcings,
        loc_spinup_forcings,
        forcing_one_timestep,
        loc_outputs,
        land_init,
        loc_observations,
        tem,
        param_to_index,
        cost_options,
        constraint_method
        )

#params_bounded = getParamsAct.(sites_parameters, tbl_params)
cov_sites = xfeatures.site
#sites_parameters .= tbl_params.default

# start training 

sites = xfeatures.site
flat, re, opt_state = destructureNN(ml_baseline; nn_opt =  Optimisers.Adam())
n_params = length(ml_baseline[end].bias)

# sites = sites[1:16]

nepochs = 50
shuffle_opt = true
bs_seed = 123
bs = 8

xbatches = batch_shuffle(sites, bs; seed=123)
new_sites = reduce(vcat, xbatches)
tot_loss = fill(NaN32, length(new_sites), nepochs)

#p = Progress(nepochs; desc="Computing epochs...")

loc_spinup_forcings = run_helpers.loc_spinup_forcings

models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

models = LongTuple(models...);

using SindbadML: scaledParams

all_sites = sites_f

for epoch ∈ 1:nepochs
    xbatches = shuffle_opt ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches
    for xbatch ∈ xbatches
        f_grads = zeros(n_params, length(xbatch))
        x_feat = xfeatures(; site=xbatch)

        inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)

        for idx ∈ eachindex(xbatch)
            site_name, new_vals = scaledParams(inst_params, tbl_params, xbatch, idx)
            site_location = name_to_id(site_name, all_sites)
            land_init = land_init_space[site_location[1]]
            loc_spinup_forcing = loc_spinup_forcings[site_location[1]];
    
            loc_forcing, loc_output, loc_obs  = getLocDataObsN(op.data, forc, obs_synt, site_location) # check output order in original definition
    
            gg=ForwardDiffGrads(
                siteLossInner,
                new_vals,
                models,
                loc_forcing,
                loc_spinup_forcing,
                forcing_one_timestep,
                DiffCache.(loc_output),
                land_init,
                tem,
                param_to_index,
                loc_obs,
                cost_options,
                constraint_method
                )
            f_grads[:, idx] = gg
            println("batch site: ", site_name)
        end
        _, ∇params = pb(f_grads)
        opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        println("batch: ", now())
    end
    up_params_now = re(flat)(xfeatures(; site=new_sites))
    loss_now =  get_site_losses(
            siteLossInner,
            up_params_now,
            models,
            new_sites,
            sites_f,
            op.data,
            forc,
            loc_spinup_forcings,
            forcing_one_timestep,
            obs_synt,
            tbl_params,
            land_init_space,
            tem,
            param_to_index,
            cost_options,
            constraint_method;
            logging=false
            )
    jldsave(joinpath(path, "$(name_exp)_epoch_$(epoch).jld2"); loss = loss_now, re=re, flat=flat)
    tot_loss[:, epoch] =  loss_now
    println("epoch: ", epoch)
end