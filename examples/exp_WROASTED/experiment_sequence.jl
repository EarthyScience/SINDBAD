using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Dates
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"
using Plots

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# inpath = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
# inpath = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
sites = ("DE-Hai", "CA-TP1", "AU-DaP", "AT-Neu")
for domain ∈ sites
    # domain = "DE-Hai"
    inpath = "../data/fn/$(domain).1979.2017.daily.nc"
    forcingConfig = "forcing_erai.json"

    obspath = inpath
    optimize_it = false
    optimize_it = true
    outpath = nothing


    pl = "threads"
    replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
        "experiment.configuration_files.forcing" => forcingConfig,
        "experiment.domain" => domain,
        "model_run.time.end_date" => eYear * "-12-31",
        "model_run.flags.run_optimization" => optimize_it,
        "model_run.flags.run_forward_and_cost" => true,
        "spinup.flags.save_spinup" => false,
        "model_run.flags.catch_model_errors" => true,
        "model_run.flags.run_spinup" => true,
        "model_run.flags.debug_model" => false,
        "spinup.flags.do_spinup" => true,
        "forcing.default_forcing.data_path" => inpath,
        "model_run.output.path" => outpath,
        "model_run.mapping.parallelization" => pl,
        "opti.constraints.default_constraint.data_path" => obspath)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info


    ## get the spinup sequence
    nrepeat = 200

    data_path = getAbsDataPath(info, inpath)
    nc = ForwardSindbad.NetCDF.open(data_path)
    y_dist = nc.gatts["last_disturbance_on"]

    nrepeat_d = nothing
    if y_dist !== "undisturbed"
        y_disturb = year(Date(y_dist))
        y_start = year(Date(info.tem.helpers.dates.start_date))
        nrepeat_d = y_start - y_disturb
    end
    sequence = nothing
    if isnothing(nrepeat_d)
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d < 0
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d == 0
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d > 0
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat_d),
        ]
    else
        error("cannot determine the repeat for disturbance")
    end

    replace_info["spinup.sequence"] = sequence
    @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info)
    @time outparams = runExperimentOpti(experiment_json; replace_info=replace_info)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info

    tblParams = Sindbad.getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)
    new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams)

    info, forcing = getForcing(info, Val(Symbol(info.model_run.rules.data_backend)))
    forc = getKeyedArrayFromYaxArray(forcing)

    output = setupOutput(info)

    observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)))
    obs = getObsKeyedArrayFromYaxArray(observations)

    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
        prepRunEcosystem(output,
            forc,
            info.tem)
    @time runEcosystem!(output.data,
        new_models,
        forc,
        tem_with_vals,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)

    # some plots
    ds = forcing.data[1]
    opt_dat = output.data
    def_dat = outcubes
    out_vars = output.variables
    costOpt = info.optim.cost_options
    foreach(costOpt) do var_row
        v = var_row.variable
        @show "plot obs", v
        lossMetric = var_row.cost_metric
        loss_name = valToSymbol(lossMetric)
        if loss_name == :nnseinv
            lossMetric = Val(:nse)
        end
        (obs_var, obs_σ, def_var) = getDataArray(def_dat, obs, var_row)
        obs_var_TMP = obs_var[:, 1, 1, 1]
        non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
        if length(non_nan_index) < 2
            tspan = 1:length(obs_var_TMP)
        else
            tspan = first(non_nan_index):last(non_nan_index)
        end
        xdata = [info.tem.helpers.dates.vector[tspan]...]
        obs_var_n, obs_σ_n, def_var_n = filter_common_nan(obs_var, obs_σ, def_var)
        metr_def = loss(obs_var_n, obs_σ_n, def_var_n, lossMetric)
        (_, _, opt_var) = getDataArray(opt_dat, obs, var_row)
        obs_var_n, obs_σ_n, opt_var_n = filter_common_nan(obs_var, obs_σ, opt_var)
        metr_opt = loss(obs_var_n, obs_σ_n, opt_var_n, lossMetric)
        plot(xdata, def_var[tspan, 1, 1, 1]; label="def ($(round(metr_def, digits=2)))", size=(1200, 900), title="$(v) -> $(valToSymbol(lossMetric))")
        plot!(xdata, opt_var[tspan, 1, 1, 1]; label="opt ($(round(metr_opt, digits=2)))")
        plot!(xdata, obs_var[tspan]; label="obs")
        savefig(joinpath(info.output.figure, "wroasted_$(domain)_$(v).png"))
    end

end