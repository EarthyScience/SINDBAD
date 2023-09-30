using Distributed
using SharedArrays
addprocs(9)

using SindbadData
using SindbadTEM
using SindbadML
using ForwardDiff
using Zygote
using Optimisers
using PreallocationTools
using YAXArrays, YAXArrayBase
using AxisKeys
using Random

@everywhere begin
    using SindbadData
    using SindbadTEM
    using SindbadML
    using ForwardDiff
    using Zygote
    using Optimisers
    using PreallocationTools
end

using CairoMakie
using JLD2

toggleStackTraceNT()
include("gen_obs.jl");

obs_synt_s, params_map = out_synt();
cov_sites = get_sites_cov()

@everywhere obs_synt = $obs_synt_s

obs_synt, params_map = out_synt();

cov_sites = get_sites_cov()

ks = (:gpp, :nee, :reco, :transpiration, :evapotranspiration, :agb, :ndvi)
cbars = (:viridis, :seaborn_icefire_gradient, :batlow100, :inferno, :magma, :thermal, :fastie)

path = dirname(Base.active_project())

data_sites = getproperty(obs_synt, :ndvi)
data_subset = data_sites(site = cov_sites)

data_subset(site = "ZM-Mon") |> sum
#mkpath(path)
name_exp = "long_par"
#path = dirname(Base.active_project())
path = joinpath("/Net/Groups/BGI/work_3/scratch/lalonso/SindbadRuns/", name_exp)
mkpath(path)

mkpath(joinpath(path, "maps_local/"))

for (i,k) in enumerate(ks)
    data_sites = getproperty(obs_synt, k)
    data_subset = data_sites(site = cov_sites)
    ds_ar = data_subset |> Array
    fig = Figure(; resolution = (2400,700))
    ax = Axis(fig[1,1]; xlabel = "time", ylabel = "site")
    obj = heatmap!(ax, ds_ar; colormap = cbars[i])
    Colorbar(fig[1,2], obj)
    fig
    save(joinpath(path, "maps_local/variable_$(k).png"), fig)
end

let 
    params_scaled = params_map |> Array
    fig = Figure(; resolution = (2400,700))
    ax = Axis(fig[1,1]; xlabel = "paramer", ylabel = "site")
    obj = heatmap!(ax, params_scaled; colormap = :tab20c,
        colorrange=(-1,20), highclip=:yellow, lowclip=:black,)
    Colorbar(fig[1,2], obj)
    fig
    save(joinpath(path, "maps_local/parameters_map.png"), fig)
end


experiment_json = "../exp_long_slurm/settings_long_slurm/experiment.json"

#info = getConfiguration(experiment_json);
#info = setupInfo(info);

info = getExperimentInfo(experiment_json);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

forc = (; Pair.(forcing.variables, forcing.data)...);
obs = (; Pair.(observations.variables, observations.data)...);

land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);


op = prepTEMOut(info, forcing.helpers);

run_helpers = prepTEM(forcing, info);

land_init_space = run_helpers.land_init_space;
tem_with_types = run_helpers.tem_with_types;

tem = (;
    tem_helpers = tem_with_types.helpers,
    tem_models = tem_with_types.models,
    tem_spinup = tem_with_types.spinup,
    tem_run_spinup = tem_with_types.helpers.run.spinup.spinup_TEM,
);

loc_space_inds = run_helpers.loc_space_inds;
land_init_space = run_helpers.land_init_space;

site_location = loc_space_inds[3]    
loc_land_init = land_init_space[3];

loc_forcing, loc_output, loc_obs =
    getLocDataObsN(op.data, forc, obs_synt, site_location); # obs_synt

loc_spinup_forcing = run_helpers.loc_spinup_forcings[site_location[1]];


land_init = land_init_space[site_location[1]];
forcing_one_timestep =run_helpers.forcing_one_timestep;

models = info.tem.models.forward;
models = LongTuple(models...);

coreTEM!(
        models,
        loc_forcing,
        loc_spinup_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem...)


@time coreTEM!(
    models,
    loc_forcing,
    loc_spinup_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem...)


cost_options = prepCostOptions(loc_obs, info.optim.cost_options);
new_cost_options = Tuple(cost_options);

new_options = [(; cost_metric= new_cost_options[i].cost_metric,
    obs_ind = new_cost_options[i].obs_ind,
    mod_ind = new_cost_options[i].mod_ind,
    valids = new_cost_options[i].valids,
    cost_weight = new_cost_options[i].cost_weight) for i in eachindex(new_cost_options)]

#cost_options= cost_options
constraint_method = info.optim.multi_constraint_method


@time  getSiteLossTEM(models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem,
    loc_obs, cost_options, constraint_method)
#CHUNK_SIZE = 13;
models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

models = LongTuple(models...);

@time siteLossInner(
    tbl_params.default,
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
    
println("Hola hola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

@time gradientSite(
    siteLossInner,
    tbl_params.default,
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

# load available covariates

# rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_covariates.zarr"));
xfeatures = cube_to_KA(c)

# RU-Ha1, IT-PT1, US-Me5
sites = xfeatures.site
sites = [s for s ∈ sites]

sites = setdiff(sites, ["CA-NS6", "SD-Dem", "US-WCr", "ZM-Mon"])
xfeatures = xfeatures(site=sites)


# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=523)
sites_parameters = ml_baseline(xfeatures)
#params_bounded = getParamsAct.(sites_parameters, tbl_params)
cov_sites = xfeatures.site

forcing_one_timestep=run_helpers.forcing_one_timestep

#sites_parameters .= tbl_params.default

op = prepTEMOut(info, forcing.helpers);

# start training 

sites = xfeatures.site
flat, re, opt_state = destructureNN(ml_baseline; nn_opt =  Optimisers.Adam())
n_params = length(ml_baseline[end].bias)

nepochs = 2
shuffle_opt = true
bs_seed = 123
bs = 8

xbatches = batch_shuffle(sites, bs; seed=123)
new_sites = reduce(vcat, xbatches)
tot_loss = fill(NaN32, length(new_sites), nepochs)


loc_spinup_forcings = run_helpers.loc_spinup_forcings

models = info.tem.models.forward;
param_to_index = param_indices(models, tbl_params);

models = LongTuple(models...);

@everywhere using SindbadML: scaledParams
all_sites = sites_f

#@everywhere loc_spinup_forcings_par = $loc_spinup_forcings

for epoch ∈ 1:nepochs
    xbatches = shuffle_opt ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches
    for xbatch ∈ xbatches
        f_grads = SharedArray{Float32}(n_params, length(xbatch))
        x_feat = xfeatures(; site=xbatch)

        inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)

        @sync @distributed for idx ∈ eachindex(xbatch)
            site_name, new_vals = scaledParams(inst_params, tbl_params, xbatch, idx)
            site_location = name_to_id(site_name, all_sites)
            land_init = land_init_space[site_location[1]]
            loc_spinup_forcing = loc_spinup_forcings[site_location[1]];
    
            loc_forcing, loc_output, loc_obs  = getLocDataObsN(op.data, forc, obs_synt, site_location) # check output order in original definition
    
            gg=gradientSite(
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
    loss_now =  lossSites(
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