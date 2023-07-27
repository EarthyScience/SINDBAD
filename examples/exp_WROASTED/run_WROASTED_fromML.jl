using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Dates
using Plots
noStackTrace()

site_index = 37
# site_index = 68
sites = 1:205
# sites = [37, ]
# sites = 1:20
# sites = [11, 33, 55, 105, 148]
forcing_set = "erai"
do_debug_figs = false
do_forcing_figs = false
site_info = Sindbad.CSV.File(
    "/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/fluxnet_sites_info/site_info_$(forcing_set).csv";
    header=false);
info = nothing
forcing = nothing
models_with_matlab_params = nothing
linit = nothing
debug_span = 1:10000
if !isnothing(models_with_matlab_params)
    showParamsOfAllModels(models_with_matlab_params)
end
for site_index in sites
    # site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
    # site_index = Base.parse(Int, ARGS[1])
    domain = string(site_info[site_index][2])

    experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
    sYear = nothing
    eYear = nothing
    ml_main_dir = nothing
    if forcing_set == "erai"
        dataset = "ERAinterim.v2"
        sYear = "1979"
        eYear = "2017"
        ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/sopt_sets_wroasted/"
    else
        dataset = "CRUJRA.v2_2"
        sYear = "1901"
        eYear = "2019"
        ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/cruj_sets_wroasted/"
    end
    ml_param_file = joinpath(ml_main_dir, "sindbad_raw_set1/fluxnetBGI2021.BRK15.DD", dataset, domain, "optimization", "optimized_Params_FLUXNET_pcmaes_FLUXNET2015_daily_$(domain).json")
    ml_data_file = joinpath(ml_main_dir, "sindbad_processed_sets/set1/fluxnetBGI2021.BRK15.DD", dataset, "data", "$(domain).$(sYear).$(eYear).daily.nc")

    ml_data_path = joinpath(ml_main_dir, "sindbad_raw_set1/fluxnetBGI2021.BRK15.DD", dataset, domain, "modelOutput")
    if do_debug_figs
        ml_data_path = joinpath(ml_main_dir, "sindbad_raw_set1PF/fluxnetBGI2021.BRK15.DD", dataset, domain, "modelOutput")
    end

    path_input = joinpath("/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data", dataset, "daily/$(domain).$(sYear).$(eYear).daily.nc")

    path_observation = path_input
    forcingConfig = "forcing_$(forcing_set).json"

    path_output = "/Net/Groups/BGI/scratch/skoirala/wroasted_sjindbad_test"



    ## get the spinup sequence

    nrepeat = 200

    # data_path = getAbsDataPath(info, path_input)
    data_path = path_input
    if !isfile(data_path)
        continue
    end
    nc = ForwardSindbad.NetCDF.open(data_path)
    y_dist = nc.gatts["last_disturbance_on"]

    nrepeat_d = nothing
    if y_dist !== "undisturbed"
        y_disturb = year(Date(y_dist))
        y_start = Meta.parse(sYear)
        nrepeat_d = y_start - y_disturb
    end
    sequence = nothing
    if isnothing(nrepeat_d)
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d < 0
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d == 0
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        ]
    elseif nrepeat_d > 0
        sequence = [
            Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
            Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
            Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat_d),
        ]
    else
        error("cannot determine the repeat for disturbance")
    end



    pl = "threads"
    replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
        "experiment.configuration_files.optimization" => "optimization_1_1.json",
        "experiment.configuration_files.forcing" => forcingConfig,
        "experiment.domain" => domain,
        "forcing.default_forcing.data_path" => path_input,
        "model_run.time.end_date" => eYear * "-12-31",
        "model_run.flags.run_optimization" => false,
        "model_run.flags.run_forward_and_cost" => true,
        "model_run.flags.spinup.save_spinup" => false,
        "model_run.flags.catch_model_errors" => false,
        "model_run.flags.spinup.run_spinup" => true,
        "model_run.flags.debug_model" => false,
        "model_run.flags.spinup.do_spinup" => true,
        "model_run.spinup.sequence" => sequence[2:end],
        "model_run.output.path" => path_output,
        "model_run.mapping.parallelization" => pl,
        "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
        "optimization.constraints.default_constraint.data_path" => path_observation,)


    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info

    info, forcing = getForcing(info)

    ### update the model parameters with values from matlab optimization
    tblParams = Sindbad.getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)
    outparams = tblParams.optim
    param_names = tblParams.name_full
    param_maps = Sindbad.parsefile("examples/exp_WROASTED/settings_WROASTED/ml_to_jl_params.json"; dicttype=Sindbad.DataStructures.OrderedDict)

    if isfile(ml_param_file)
        ml_params = Sindbad.parsefile(ml_param_file; dicttype=Sindbad.DataStructures.OrderedDict)["parameter"]

        for opi in eachindex(outparams)
            jl_name = param_names[opi]
            ml_name = param_maps[jl_name]
            println(jl_name, "=>", ml_name)
            ml_model = split(ml_name, ".")[1]
            ml_p = split(ml_name, ".")[2]
            ml_value = ml_params[ml_model][ml_p]
            @show outparams[opi], "old"
            outparams[opi] = oftype(outparams[opi], ml_value)
            @show outparams[opi], "new"
            println("------------------------------------------------")
        end
        models_with_matlab_params = updateModelParameters(tblParams, info.tem.models.forward, outparams)


        tblParams_2 = Sindbad.getParameters(models_with_matlab_params,
            info.optim.default_parameter,
            info.optim.optimized_parameters)



        ## run the model
        forc = getKeyedArrayWithNames(forcing)
        output = setupOutput(info)

        loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
            prepRunEcosystem(output,
                models_with_matlab_params,
                forc,
                info.tem,
                info.tem.helpers)
        @time runEcosystem!(output.data,
            models_with_matlab_params,
            forc,
            tem_with_vals,
            loc_space_inds,
            loc_forcings,
            loc_outputs,
            land_init_space,
            f_one)

        outcubes = output.data

        observations = getObservation(info)
        obs = getKeyedArray(observations)

        # open the matlab simulation data
        # nc_ml = ForwardSindbad.NetCDF.open(ml_data_file);

        varib_dict = Dict(:gpp => "gpp", :nee => "NEE", :transpiration => "tranAct", :evapotranspiration => "evapTotal", :ndvi => "fAPAR", :agb => "cEco", :reco => "cRECO", :soilW => "wSoil", :gpp_f_soilW => "SMScGPP", :gpp_f_vpd => "VPDScGPP", :gpp_climate_stressors => "scall", :AoE => "AoE", :eco_respiration => "cRECO", :c_allocation => "cAlloc", :fAPAR => "fAPAR", :cEco => "cEco", :PAW => "pawAct", :transpiration_supply => "tranSup", :c_eco_k => "p_cTauAct_k", :auto_respiration => "cRA", :hetero_respiration => "cRH", :runoff => "roTotal", :base_runoff => "roBase", :gw_recharge => "gwRec", :c_eco_k_f_soilT => "fT", :c_eco_k_f_soilW => "p_cTaufwSoil_fwSoil", :snow_melt => "snowMelt", :groundW => "wGW", :snowW => "wSnow", :frac_snow => "wSnowFrac", :c_eco_influx => "cEcoInflux", :c_eco_efflux => "cEcoEfflux", :c_eco_out => "cEcoOut", :c_eco_flow => "cEcoFlow", :leaf_to_reserve_frac => "L2ReF", :root_to_reserve_frac => "R2ReF", :reserve_to_leaf_frac => "Re2L", :reserve_to_root_frac => "Re2R", :k_shedding_leaf_frac => "k_LshedF", :k_shedding_root_frac => "k_RshedF", :root_water_efficiency => "p_rootFrac_fracRoot2SoilD")


        # some plots for model simulations from JL and matlab versions
        ds = forcing.data[1]
        opt_dat = outcubes
        out_vars = output.variables
        costOpt = info.optim.cost_options
        default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
        foreach(costOpt) do var_row
            v = var_row.variable
            @show "plot obs", v
            println("plot obs-model => site: $domain, variable: $v")
            lossMetric = var_row.cost_metric
            loss_name = valToSymbol(lossMetric)
            if loss_name in (:nnseinv, :nseinv)
                lossMetric = Val(:nse)
            end
            ml_data_file = joinpath(ml_data_path, "FLUXNET2015_daily_$(domain)_FLUXNET_$(varib_dict[v]).nc")
            @show ml_data_file
            nc_ml = ForwardSindbad.NetCDF.open(ml_data_file)
            ml_dat = nc_ml[varib_dict[v]][:]
            if v == :agb
                ml_dat = nc_ml[varib_dict[v]][1, 2, :]
            elseif v == :ndvi
                ml_dat = ml_dat .- ForwardSindbad.Statistics.mean(ml_dat)
            end
            (obs_var, obs_σ, jl_dat) = getDataArray(opt_dat, obs, var_row)
            obs_var_TMP = obs_var[:, 1, 1, 1]
            non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
            tspan = 1:length(obs_var_TMP)
            if length(non_nan_index) < 2
                tspan = 1:length(obs_var_TMP)
            else
                tspan = first(non_nan_index):last(non_nan_index)
            end
            xdata = [info.tem.helpers.dates.vector[tspan]...]
            obs_σ = obs_σ[tspan]
            obs_var = obs_var[tspan]
            jl_dat = jl_dat[tspan, 1, 1, 1]
            ml_dat = ml_dat[tspan]
            obs_var_n, obs_σ_n, ml_dat_n = filter_common_nan(obs_var, obs_σ, ml_dat)
            obs_var_n, obs_σ_n, jl_dat_n = filter_common_nan(obs_var, obs_σ, jl_dat)
            metr_def = loss(obs_var_n, obs_σ_n, ml_dat_n, lossMetric)
            metr_opt = loss(obs_var_n, obs_σ_n, jl_dat_n, lossMetric)
            v = (var_row.mod_field, var_row.mod_subfield)
            vinfo = getVariableInfo(v, info.model_run.time.model_time_step)
            v = vinfo["standard_name"]
            plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
            plot!(xdata, ml_dat, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=3, label="matlab ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(valToSymbol(lossMetric))")
            plot!(xdata, jl_dat; label="julia ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
            savefig("examples/exp_WROASTED/tmp_figs_comparison/wroasted_$(domain)_$(v)_$(forcing_set).png")
        end
        # end
        # end




        if do_debug_figs
            ##plot more diagnostic figures for sindbad jl

            replace_info["model_run.flags.run_optimization"] = false
            replace_info["model_run.flags.run_forward_and_cost"] = false
            info = getExperimentInfo(experiment_json; replace_info=replace_info)
            # note that this will modify information from json with the replace_info
            info, forcing = getForcing(info)
            output = setupOutput(info)
            loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
                prepRunEcosystem(output,
                    models_with_matlab_params,
                    forc,
                    info.tem,
                    info.tem.helpers)
            linit = land_init_space[1]
            @time runEcosystem!(output.data,
                models_with_matlab_params,
                forc,
                tem_with_vals,
                loc_space_inds,
                loc_forcings,
                loc_outputs,
                land_init_space,
                f_one)

            default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
            out_vars = output.variables
            for (o, v) in enumerate(out_vars)
                println("plot dbg-model => site: $domain, variable: $v")
                def_var = output.data[o][:, :, 1, 1]
                xdata = [info.tem.helpers.dates.vector...][debug_span]
                vinfo = getVariableInfo(v, info.model_run.time.model_time_step)
                ml_dat = nothing
                if v in keys(varib_dict)
                    ml_data_file = joinpath(ml_data_path, "FLUXNET2015_daily_$(domain)_FLUXNET_$(varib_dict[v]).nc")
                    @show ml_data_file
                    nc_ml = ForwardSindbad.NetCDF.open(ml_data_file)
                    ml_dat = nc_ml[varib_dict[v]]
                end
                if size(def_var, 2) == 1
                    plot(xdata, def_var[debug_span, 1]; label="julia ($(round(ForwardSindbad.mean(def_var[debug_span, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
                    if !isnothing(ml_dat)
                        plot!(xdata, ml_dat[debug_span]; label="matlab ($(round(ForwardSindbad.mean(ml_dat[debug_span]), digits=2)))", size=(2000, 1000))
                    end
                    savefig(joinpath("examples/exp_WROASTED/tmp_figs_comparison/", "dbg_wroasted_$(domain)_$(vinfo["standard_name"])_$(forcing_set).png"))
                else
                    for ll ∈ 1:size(def_var, 2)
                        plot(xdata, def_var[debug_span, ll]; label="julia ($(round(ForwardSindbad.mean(def_var[debug_span, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $ll ($(vinfo["units"]))", left_margin=1Plots.cm)
                        println("           layer => $ll")

                        if !isnothing(ml_dat)
                            plot!(xdata, ml_dat[1, ll, debug_span]; label="matlab ($(round(ForwardSindbad.mean(ml_dat[1, ll, debug_span]), digits=2)))")
                        end
                        savefig(joinpath("examples/exp_WROASTED/tmp_figs_comparison/", "dbg_wroasted_$(domain)_$(vinfo["standard_name"])_$(ll)_$(forcing_set).png"))
                    end
                end
            end
        end

        if do_forcing_figs
            ### PLOT the forcings
            default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
            forc_vars = forcing.variables
            for (o, v) in enumerate(forc_vars)
                println("plot forc-model => site: $domain, variable: $v")
                def_var = forcing.data[o][:, :, 1, 1]
                xdata = [info.tem.helpers.dates.vector...]
                if size(def_var, 1) !== length(xdata)
                    xdata = 1:size(def_var, 1)
                end
                if size(def_var, 2) == 1
                    plot(xdata, def_var[:, 1]; label="def ($(round(ForwardSindbad.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(v)")
                    savefig(joinpath("examples/exp_WROASTED/tmp_figs_comparison/", "forc_wroasted_$(domain)_$(v)_$(forcing_set).png"))
                else
                    for ll ∈ 1:size(def_var, 2)
                        plot(xdata, def_var[:, ll]; label="def ($(round(ForwardSindbad.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(v)")
                        savefig(joinpath("examples/exp_WROASTED/tmp_figs_comparison/", "forc_wroasted_$(domain)_$(v)_$(ll)_$(forcing_set).png"))
                    end
                end

            end

        end
    end
end