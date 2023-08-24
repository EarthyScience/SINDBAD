using Distributed
using SharedArrays
addprocs()

@everywhere begin
    using SindbadData
    using SindbadTEM
    using HybridSindbad
    using YAXArrays, YAXArrayBase
    using AxisKeys
    using Random
end

experiment_json = "../exp_repacking/settings_repacking/experiment.json"
info = getExperimentInfo(experiment_json);
tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

forc = (; Pair.(forcing.variables, forcing.data)...);
obs = (; Pair.(observations.variables, observations.data)...);

land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = prepTEMOut(info, forcing.helpers);
run_helpers = prepTEM(forcing, info);

sites_f = forc.Tair.site
c = Cube(joinpath(@__DIR__, "../data/fluxnet_cube/fluxnet_covariates.zarr"))
xfeatures = cube_to_KA(c)

sites = xfeatures.site
sites = [s for s ∈ sites]
nogood = [
    "AR-SLu",
    "CA-Obs",
    "DE-Lkb",
    "SJ-Blv",
    "US-ORv"];

sites = setdiff(sites, nogood)

xfeatures = xfeatures(site=sites);
# machine learning parameters baseline
n_bs_feat = length(xfeatures.features)
n_neurons = 32
n_params = sum(tbl_params.is_ml)

ml_baseline = DenseNN(n_bs_feat, n_neurons, n_params; extra_hlayers=2, seed=312)
sites_parameters = ml_baseline(xfeatures)
params_bounded = getParamsAct.(sites_parameters, tbl_params)
cov_sites = xfeatures.site

tem_with_types = run_helpers.tem_with_types;
tem = (;
    tem_helpers = tem_with_types.helpers,
    tem_models = tem_with_types.models,
    tem_spinup = tem_with_types.spinup,
    tem_run_spinup = tem_with_types.helpers.run.spinup.spinup_TEM,
);
forcing_one_timestep =run_helpers.forcing_one_timestep
b_data = (; allocated_output = op.data, forcing=forc);
land_init_space = run_helpers.land_init_space;

params_bounded = getParamsAct.(sites_parameters, tbl_params)

space_run!(
    info.tem.models.forward,
    params_bounded,
    tbl_params,
    sites_f,
    land_init_space,
    b_data,
    obs,
    cov_sites,
    forcing_one_timestep,
    tem
)

b_data_distri = (; allocated_output = op.data, forcing=forc);

@time space_run_distributed!(
    info.tem.models.forward,
    params_bounded,
    tbl_params,
    sites_f,
    land_init_space,
    b_data_distri,
    obs,
    cov_sites,
    forcing_one_timestep,
    tem
)


# using GLMakie
# lines(b_data_distri.allocated_output[1][:,:,3][:,1]; linewidth=0.6)
# lines!(b_data.allocated_output[1][:,:,3][:,1]; linestyle=:dot, linewidth = 0.5)
# current_figure()