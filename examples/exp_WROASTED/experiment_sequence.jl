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
        "experiment.flags.spinup.save_spinup" => false,
        "experiment.flags.catch_model_errors" => true,
        "experiment.flags.spinup.spinup_TEM" => true,
        "experiment.flags.debug_model" => false,
        "experiment.flags.spinup.run_spinup" => true,
        "forcing.default_forcing.data_path" => path_input,
        "experiment.model_output.path" => path_output,
        "experiment.exe_rules.parallelization" => parallelization_lib,
        "optimization.observations.default_observation.data_path" => path_observation)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info

    ## get the spinup sequence
    nrepeat = 200

    data_path = getAbsDataPath(info, path_input)
    nc = SindbadData.NetCDF.open(data_path)
    y_dist = nc.gatts["last_disturbance_on"]

    nrepeat_d = nothing
    if y_dist !== "undisturbed"
        y_disturb = year(Date(y_dist))
        y_start = year(Date(info.tem.helpers.dates.date_begin))
        nrepeat_d = y_start - y_disturb
    end
    sequence = nothing
    if isnothing(nrepeat_d)
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d < 0
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d == 0
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d > 0
        sequence = [
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "stop_function" => nothing, "n_repeat" => nrepeat_d),
        ]
    else
        error("cannot determine the repeat for disturbance")
    end

    replace_info["experiment.model_spinup.sequence"] = sequence
    @time output_default = runExperimentForward(experiment_json; replace_info=replace_info)
    @time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info)
    opt_params = out_opti.out_params;
    # out_model = out_opti.out_forward;

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info

    tbl_params = getParameters(info.tem.models.forward,
        info.optim.model_parameter_default,
        info.optim.model_parameters_to_optimize,
        info.tem.helpers.numbers.sNT)
    optimized_models = updateModelParameters(tbl_params, info.tem.models.forward, opt_params)

    forcing = getForcing(info)




    observations = getObservation(info, forcing.helpers)
    obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow.

    run_helpers = prepTEM(forcing, info)

    @time runTEM!(optimized_models,
        run_helpers.loc_forcings,
        run_helpers.loc_spinup_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types)

    # some plots
    ds = forcing.data[1]
    opt_dat = run_helpers.output_array
    def_dat = output_default
    costOpt = prepCostOptions(obs_array, info.optim.cost_options)
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    fig_prefix = joinpath(info.output.figure, "eval_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)

    foreach(costOpt) do var_row
        v = var_row.variable
        # @show "plot obs", v
        v = (var_row.mod_field, var_row.mod_subfield)
        vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
        v = vinfo["standard_name"]
        @show "plot obs", v
        lossMetric = var_row.cost_metric
        loss_name = nameof(typeof(lossMetric))
        if loss_name in (:NNSEInv, :NSEInv)
            lossMetric = NSE()
        end
        (obs_var, obs_σ, def_var) = getData(def_dat, obs_array, var_row)
        obs_var_TMP = obs_var[:, 1, 1, 1]
        non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
        if length(non_nan_index) < 2
            tspan = 1:length(obs_var_TMP)
        else
            tspan = first(non_nan_index):last(non_nan_index)
        end
        xdata = [info.tem.helpers.dates.range[tspan]...]
        obs_var_n, obs_σ_n, def_var_n = filterCommonNaN(obs_var, obs_σ, def_var)
        metr_def = loss(obs_var_n, obs_σ_n, def_var_n, lossMetric)
        (_, _, opt_var) = getData(opt_dat, obs_array, var_row)
        obs_var_n, obs_σ_n, opt_var_n = filterCommonNaN(obs_var, obs_σ, opt_var)
        metr_opt = loss(obs_var_n, obs_σ_n, opt_var_n, lossMetric)
        plot(xdata, obs_var[tspan]; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
        plot!(xdata, def_var[tspan, 1, 1, 1], lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=3, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(nameof(typeof(lossMetric)))")
        plot!(xdata, opt_var[tspan, 1, 1, 1]; label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
        ylabel!("$(vinfo["standard_name"])")
        savefig(fig_prefix * "_$(v).png")
    end

    ### redo the forward run to save all output variables
    replace_info["experiment.flags.calc_cost"] = false
    replace_info["experiment.flags.run_optimization"] = false
    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info
    forcing = getForcing(info)


    run_helpers = prepTEM(forcing, info)

    @time runTEM!(optimized_models,
        run_helpers.loc_forcings,
        run_helpers.loc_spinup_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types)

    # save the outcubes
    out_vars = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars)

    out_info = getOutputFileInfo(info)

    output = prepTEMOut(info, forcing.helpers)
    saveOutCubes(out_info.file_prefix, out_info.global_metadata, run_helpers.output_array, output.dims, output.variables, "zarr", info.experiment.basics.time.temporal_resolution, DoSaveSingleFile())
    saveOutCubes(out_info.file_prefix, out_info.global_metadata, run_helpers.output_array, output.dims, output.variables, "zarr", info.experiment.basics.time.temporal_resolution, DoNotSaveSingleFile())

    saveOutCubes(out_info.file_prefix, out_info.global_metadata, run_helpers.output_array, output.dims, output.variables, "nc", info.experiment.basics.time.temporal_resolution, DoSaveSingleFile())
    saveOutCubes(out_info.file_prefix, out_info.global_metadata, run_helpers.output_array, output.dims, output.variables, "nc", info.experiment.basics.time.temporal_resolution, DoNotSaveSingleFile())


    # plot the debug figures
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    fig_prefix = joinpath(info.output.figure, "debug_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)
    for (o, v) in enumerate(out_vars)
        def_var = run_helpers.output_array[o][:, :, 1, 1]
        vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
        v = vinfo["standard_name"]
        xdata = [info.tem.helpers.dates.range...]
        if size(def_var, 2) == 1
            plot(xdata, def_var[:, 1]; label="optim_forw ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
            ylabel!("$(vinfo["standard_name"])", font=(20, :green))
            savefig(fig_prefix * "_$(v).png")
        else
            foreach(axes(def_var, 2)) do ll
                plot(xdata, def_var[:, ll]; label="optim_forw ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
                ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                savefig(fig_prefix * "_$(v)_$(ll).png")
            end
        end
    end

end