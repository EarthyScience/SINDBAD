using Revise
using SindbadExperiment
using Dates
using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "1979"
end_year = "2017"

sites = ("FI-Sod", "DE-Hai", "CA-TP1", "AU-DaP", "AT-Neu")
# sites = ("AU-DaP", "AT-Neu")
# sites = ("CA-NS6",)
domain = "FI-Sod"
for domain ∈ sites
    path_input = "../data/fn/$(domain).1979.2017.daily.nc"
    forcing_config = "forcing_erai.json"

    path_observation = path_input
    optimize_it = false
    optimize_it = true
    path_output = nothing


    parallelization_lib = "threads"
    replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
        "experiment.basics.config_files.forcing" => forcing_config,
        "experiment.basics.domain" => domain,
        "experiment.basics.time.date_end" => end_year * "-12-31",
        "experiment.flags.run_optimization" => optimize_it,
        "experiment.flags.calc_cost" => true,
        "experiment.flags.catch_model_errors" => true,
        "experiment.flags.spinup_TEM" => true,
        "experiment.flags.debug_model" => false,
        "forcing.default_forcing.data_path" => path_input,
        "experiment.model_output.path" => path_output,
        "experiment.exe_rules.parallelization" => parallelization_lib,
        "optimization.observations.default_observation.data_path" => path_observation)

    ## get the spinup sequence
    nrepeat = 200
    data_path = joinpath("./examples/exp_WROASTED",path_input)
    # data_path = getAbsDataPath(info, path_input)
    nc = SindbadData.NetCDF.open(data_path)
    y_dist = nc.gatts["last_disturbance_on"]

    nrepeat_d = nothing
    if y_dist !== "undisturbed"
        y_disturb = year(Date(y_dist))
        y_start = Meta.parse(begin_year)
        # y_start = year(Date(info.tem.helpers.dates.date_begin))
        nrepeat_d = y_start - y_disturb
    end
    sequence = nothing
    if isnothing(nrepeat_d)
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "n_repeat" => 1),
        ]
    elseif nrepeat_d < 0
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "n_repeat" => 1),
        ]
    elseif nrepeat_d == 0
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_MSC", "n_repeat" => 1),
        ]
    elseif nrepeat_d > 0
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_MSC", "n_repeat" => 1),
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat_d),
        ]
    else
        error("cannot determine the repeat for disturbance")
    end

    replace_info["experiment.model_spinup.sequence"] = sequence
    @time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info)

    info = out_opti.info;
    observation = out_opti.observation;

    # some plots
    optimized_data = out_opti.output.optimized
    default_data = out_opti.output.default
    costOpt = prepCostOptions(out_opti.observation, info.optim.cost_options)
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    fig_prefix = joinpath(info.output.figure, "eval_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)

    foreach(costOpt) do var_row
        v = var_row.variable
        println("plot obs::", v)
        v = (var_row.mod_field, var_row.mod_subfield)
        vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
        v = vinfo["standard_name"]
        lossMetric = var_row.cost_metric
        loss_name = nameof(typeof(lossMetric))
        if loss_name in (:NNSEInv, :NSEInv)
            lossMetric = NSE()
        end
        (obs_var, obs_σ, def_var) = getData(default_data, observation, var_row)
        (_, _, opt_var) = getData(optimized_data, observation, var_row)
        obs_var_TMP = obs_var[:, 1, 1, 1]
        non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
        if length(non_nan_index) < 2
            tspan = 1:length(obs_var_TMP)
        else
            tspan = first(non_nan_index):last(non_nan_index)
        end
        obs_σ = obs_σ[tspan]
        obs_var = obs_var[tspan, 1, 1, 1]
        def_var = def_var[tspan, 1, 1, 1]
        opt_var = opt_var[tspan, 1, 1, 1]
    
        xdata = [info.tem.helpers.dates.range[tspan]...]
        obs_var_n, obs_σ_n, def_var_n = filterCommonNaN(obs_var, obs_σ, def_var)
        obs_var_n, obs_σ_n, opt_var_n = filterCommonNaN(obs_var, obs_σ, opt_var)
        metr_def = loss(obs_var_n, obs_σ_n, def_var_n, lossMetric)
        metr_opt = loss(obs_var_n, obs_σ_n, opt_var_n, lossMetric)
        plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
        plot!(xdata, def_var, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=3, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(nameof(typeof(lossMetric)))")
        plot!(xdata, opt_var; label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
        ylabel!("$(vinfo["standard_name"])")
        savefig(fig_prefix * "_$(v).png")
    end

    # save the outcubes

    out_info = getOutputFileInfo(info)

    optimized_data = values(optimized_data)
    default_data = values(default_data)

    output_vars = info.tem.variables
    output_dims = getOutDims(output_vars, info, out_opti.forcing.helpers);
    saveOutCubes(out_info.file_prefix, out_info.global_metadata, optimized_data, output_dims, output_vars, "zarr", info.experiment.basics.time.temporal_resolution, DoSaveSingleFile())
    saveOutCubes(out_info.file_prefix, out_info.global_metadata, optimized_data, output_dims, output_vars, "zarr", info.experiment.basics.time.temporal_resolution, DoNotSaveSingleFile())

    saveOutCubes(out_info.file_prefix, out_info.global_metadata, optimized_data, output_dims, output_vars, "nc", info.experiment.basics.time.temporal_resolution, DoSaveSingleFile())
    saveOutCubes(out_info.file_prefix, out_info.global_metadata, optimized_data, output_dims, output_vars, "nc", info.experiment.basics.time.temporal_resolution, DoNotSaveSingleFile())


    # plot the debug figures
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    fig_prefix = joinpath(info.output.figure, "debug_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)
    for (o, v) in enumerate(output_vars)
        def_var = default_data[o][:, :, 1, 1]
        opt_var = optimized_data[o][:, :, 1, 1]
        vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
        v = vinfo["standard_name"]
        println("plot debug::", v)
        xdata = [info.tem.helpers.dates.range...]
        if size(opt_var, 2) == 1
            plot(xdata, def_var[:, 1]; label="def ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
            plot!(xdata, opt_var[:, 1]; label="opt ($(round(SindbadTEM.mean(opt_var[:, 1]), digits=2)))")
            ylabel!("$(vinfo["standard_name"])", font=(20, :green))
            savefig(fig_prefix * "_$(v).png")
        else
            foreach(axes(opt_var, 2)) do ll
                plot(xdata, def_var[:, ll]; label="def ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
                plot!(xdata, opt_var[:, ll]; label="opt ($(round(SindbadTEM.mean(opt_var[:, ll]), digits=2)))")
                ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                savefig(fig_prefix * "_$(v)_$(ll).png")
            end
        end
    end

end