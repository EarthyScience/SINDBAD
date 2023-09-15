using SindbadData
using SindbadTEM
using SindbadML
using YAXArrays, YAXArrayBase
using AxisKeys
using Random
#using SindbadVisuals

# setup experiment
function out_synt()
    experiment_json = "../exp_medium/settings_medium/experiment.json"
    info = getExperimentInfo(experiment_json);
    tbl_params = getParameters(info.tem.models.forward,
        info.optim.model_parameter_default,
        info.optim.model_parameters_to_optimize);

    forcing = getForcing(info);
    observations = getObservation(info, forcing.helpers);

    forc = (; Pair.(forcing.variables, forcing.data)...);
    obs = (; Pair.(observations.variables, observations.data)...);

    #obs_array = getKeyedArrayWithNames(observations);
    #obsv = getKeyedArray(observations);

    land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
    op = prepTEMOut(info, forcing.helpers);
    run_helpers = prepTEM(forcing, info);

    # load available covariates

    # rsync -avz user@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr ~/examples/data/fluxnet_cube
    sites_f = forc.Tair.site
    c = Cube(joinpath(@__DIR__, "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr")) # ../data/fluxnet_cube/fluxnet_covariates.zarr
    xfeatures = cube_to_KA(c)
    # RU-Ha1, IT-PT1, US-Me5
    sites = xfeatures.site
    sites = [s for s ∈ sites]
    # nogood = [
    #     "AR-SLu",
    #     "CA-Obs",
    #     "DE-Lkb",
    #     "SJ-Blv",
    #     "US-ORv"];
    # sites = setdiff(sites, nogood)

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

    # do the run with default parameters
    # params_bounded .= tbl_params.default

    # space_run!(
    #     info.tem.models.forward,
    #     params_bounded,
    #     tbl_params,
    #     sites_f,
    #     land_init_space,
    #     b_data,
    #     obs,
    #     cov_sites,
    #     forcing_one_timestep,
    #     tem
    # )

    # uno = b_data.allocated_output[1][:,1,:]
    # using GLMakie
    # heatmap(uno)

    # series(uno'; color = resample_cmap(:Spectral_11, 205), linewidth=0.1)


    # tempo = string.(forc.Tair.time);
    # out_names = info.optimization.observational_constraints
    # plot_output(op, obs, out_names, cov_sites, sites_f, tempo)


    # do the run with the original bounded parameters
    params_bounded = getParamsAct.(sites_parameters, tbl_params)
    #models = [m for m in info.tem.models.forward]
    models = info.tem.models.forward
    param_to_index =  param_indices(models, tbl_params)
    models = LongTuple(models...);

    space_run!(
        models,
        params_bounded,
        param_to_index,
        sites_f,
        land_init_space,
        b_data,
        obs,
        cov_sites,
        forcing_one_timestep,
        tem
    )

    # uno = b_data.allocated_output[1][:,1,:]
    # #heatmap(uno)
    # series(uno'; color = resample_cmap([:black, :red, :blue, :yellow], 205), linewidth=0.1)

    # tempo = string.(Date.(forc.Tair.time));
    out_names = info.optimization.observational_constraints;

    # with_theme(theme_dark()) do
    #     plot_output(op, obs, out_names, cov_sites, sites_f, tempo)
    # end
    time_range = obs.gpp.time
    site_names = obs.gpp.site
    k_arrs = assemble_synt(op, Symbol.(out_names), time_range, site_names)

    return (; obs..., k_arrs...), params_bounded
end

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

function get_sites_cov()
    c = Cube(joinpath(@__DIR__, "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_covariates.zarr")) # ../data/fluxnet_cube/fluxnet_covariates.zarr
    xfeatures = cube_to_KA(c)
    sites = xfeatures.site
    sites = [s for s ∈ sites]
    return sites
end