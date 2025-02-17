using Revise
using SindbadExperiment
using Dates
using Plots
toggleStackTraceNT()

# site_index = 69
site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
# site_index = Base.parse(Int, ARGS[1])
forcing_set = "erai"
site_info = CSV.File(
    "/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/fluxnet_sites_info/site_info_$(forcing_set).csv";
    header=false);
domain = string(site_info[site_index][2])

experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
path_input = nothing
begin_year = nothing
end_year = nothing
ml_main_dir = nothing
if forcing_set == "erai"
    dataset = "ERAinterim.v2"
    begin_year = "1979"
    end_year = "2017"
    ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/v202312_ml_wroasted/"
else
    dataset = "CRUJRA.v2_2"
    begin_year = "1901"
    end_year = "2019"
    ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/cruj_sets_wroasted/"
end
ml_data_file = joinpath(ml_main_dir, "sindbad_processed_sets/set1/fluxnetBGI2021.BRK15.DD", dataset, "data", "$(domain).$(begin_year).$(end_year).daily.nc")
path_input = joinpath("/Net/Groups/BGI/scratch/skoirala/v202312_wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data", dataset, "daily/$(domain).$(begin_year).$(end_year).daily.nc");
path_observation = path_input;

nrepeat = 200


## get the spinup sequence
nc = SindbadData.NetCDF.open(path_input);
y_dist = nc.gatts["last_disturbance_on"]

nrepeat_d = nothing
if y_dist !== "undisturbed"
    y_disturb = year(Date(y_dist))
    y_start = Meta.parse(begin_year)
    nrepeat_d = y_start - y_disturb
end
sequence = nothing
if isnothing(nrepeat_d)
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d > 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_MSC", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat_d),
    ]
else
    error("cannot determine the repeat for disturbance")
end

opti_sets = Dict(
    :set1 => ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi"],
    :set2 => ["gpp", "nee", "transpiration", "evapotranspiration", "agb", "ndvi"],
    :set3 => ["gpp", "nee", "reco", "transpiration", "evapotranspiration"],
    :set4 => ["gpp", "nee", "transpiration", "evapotranspiration"],
    :set5 => ["gpp", "nee", "reco", "evapotranspiration", "agb", "ndvi"],
    :set6 => ["gpp", "nee", "evapotranspiration", "agb", "ndvi"],
    :set7 => ["gpp", "evapotranspiration", "agb", "ndvi"],
    :set8 => ["gppmsc", "evapotranspirationmsc", "agb", "ndvi"],
    :set9 => ["agb", "ndvi"],
    :set10 => ["agb", "ndvi", "nirv"],
)

forcing_config = "forcing_$(forcing_set).json";
parallelization_lib = "threads"
exp_main_params = "wroasted_v202312"
exp_main = "fw_wroasted_v202312"

opti_set = (:set1, :set2, :set3, :set4, :set5, :set6, :set7, :set9, :set10,)
opti_set = (:set1,)
optimize_it = false;
o_set = :set1
# for o_set in opti_set
    path_params = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main_params)_sjindbad/$(forcing_set)/$(o_set)"
    path_output = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)_sjindbad/$(forcing_set)/$(o_set)"
    exp_name_params = "$(exp_main_params)_$(forcing_set)_$(o_set)"
    exp_name = "$(exp_main)_$(forcing_set)_$(o_set)"
    params_file = joinpath(path_params, "$(domain)_$(exp_name_params)", "optimization", "$(exp_name_params)_$(domain)_model_parameters_to_optimize.csv")

    replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
        "experiment.basics.config_files.forcing" => forcing_config,
        "experiment.basics.config_files.parameters" => params_file,
        "experiment.basics.domain" => domain,
        "experiment.basics.name" => exp_name,
        "experiment.basics.time.date_end" => end_year * "-12-31",
        "experiment.flags.run_optimization" => optimize_it,
        "experiment.flags.calc_cost" => true,
        "experiment.flags.catch_model_errors" => true,
        "experiment.flags.spinup_TEM" => true,
        "experiment.flags.debug_model" => false,
        "experiment.model_spinup.sequence" => sequence,
        "forcing.default_forcing.data_path" => path_input,
        "experiment.model_output.path" => path_output,
        "experiment.exe_rules.parallelization" => parallelization_lib,
        "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES_10000.json",
        "optimization.observations.default_observation.data_path" => path_observation,
        "optimization.observational_constraints" => opti_sets[o_set],)
    info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

    @time out_opti = runExperimentCost(experiment_json; replace_info=replace_info);

    forcing = out_opti.forcing;
    obs_array = out_opti.observation;
    info = out_opti.info;
    
    # some plots
    opt_dat = out_opti.output;
    # def_dat = out_opti.output.default
    costOpt = prepCostOptions(obs_array, info.optimization.cost_options)
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))

    # load matlab wroasted results
    nc_ml = SindbadData.NetCDF.open(ml_data_file)

    varib_dict = Dict(:gpp => "gpp", :nee => "NEE", :transpiration => "tranAct", :evapotranspiration => "evapTotal", :ndvi => "fAPAR", :agb => "cEco", :reco => "cRECO", :nirv => "gpp")

    fig_prefix = joinpath(info.output.dirs.figure, "comparison_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)

    foreach(costOpt) do var_row
        v = var_row.variable
        @show "plot obs", v
        ml_dat = nc_ml[varib_dict[v]][:]
        if v == :agb
            ml_dat = nc_ml[varib_dict[v]][1, 1, 2, :]
        elseif v == :ndvi
            ml_dat = ml_dat .- mean(ml_dat)
        end
        v = (var_row.mod_field, var_row.mod_subfield)
        vinfo = getVariableInfo(v, info.experiment.basics.temporal_resolution)
        v = vinfo["standard_name"]
        lossMetric = var_row.cost_metric
        loss_name = nameof(typeof(lossMetric))
        if loss_name in (:NNSEInv, :NSEInv)
            lossMetric = NSE()
        end
        # (obs_var, obs_σ, def_var) = getData(def_dat, obs_array, var_row)
        (obs_var, obs_σ, opt_var) = getData(opt_dat, obs_array, var_row)
        obs_var_TMP = obs_var[:, 1, 1, 1]
        non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
        if length(non_nan_index) < 2
            tspan = 1:length(obs_var_TMP)
        else
            tspan = first(non_nan_index):last(non_nan_index)
        end
        obs_σ = obs_σ[tspan]
        obs_var = obs_var[tspan]
        ml_dat = ml_dat[tspan]
        # def_var = def_var[tspan, 1, 1, 1]
        opt_var = opt_var[tspan, 1, 1, 1]

        xdata = [info.helpers.dates.range[tspan]...]
        obs_var_n, obs_σ_n, ml_dat_n = filterCommonNaN(obs_var, obs_σ, ml_dat)
        # obs_var_n, obs_σ_n, def_var_n = filterCommonNaN(obs_var, obs_σ, def_var)
        obs_var_n, obs_σ_n, opt_var_n = filterCommonNaN(obs_var, obs_σ, opt_var)
        metr_ml = loss(obs_var_n, obs_σ_n, ml_dat_n, lossMetric)
        # metr_def = loss(obs_var_n, obs_σ_n, def_var_n, lossMetric)
        metr_opt = loss(obs_var_n, obs_σ_n, opt_var_n, lossMetric)
        plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
        # plot!(xdata, def_var, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=4, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(nameof(typeof(lossMetric))), $(forcing_set), $(o_set)")
        plot!(xdata, opt_var; label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=4, size=(2000, 1000), title="$(domain):: $(vinfo["long_name"]) ($(vinfo["units"])) -> $(nameof(typeof(lossMetric))), $(forcing_set), $(o_set)" )
        plot!(xdata, ml_dat; label="matlab ($(round(metr_ml, digits=2)))", lw=1.5, ls=:dash)
        savefig(fig_prefix * "_$(v)_$(forcing_set).png")
    end

    # save the outcubes
    output_array_opt = values(opt_dat)
    # output_array_def = values(def_dat)
    output_vars = info.output.variables
    output_dims = getOutDims(info, out_opti.forcing.helpers);

    saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_opt, output_dims, output_vars, "zarr", info.experiment.basics.temporal_resolution, DoSaveSingleFile())
    saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_opt, output_dims, output_vars, "zarr", info.experiment.basics.temporal_resolution, DoNotSaveSingleFile())

    saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_opt, output_dims, output_vars, "nc", info.experiment.basics.temporal_resolution, DoSaveSingleFile())
    saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_opt, output_dims, output_vars, "nc", info.experiment.basics.temporal_resolution, DoNotSaveSingleFile())


    # plot the debug figures
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    fig_prefix = joinpath(info.output.dirs.figure, "debug_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)
    for (o, v) in enumerate(output_vars)
        # def_var = output_array_def[o][:, :, 1, 1]
        opt_var = output_array_opt[o][:, :, 1, 1]
        vinfo = getVariableInfo(v, info.experiment.basics.temporal_resolution)
        v = vinfo["standard_name"]
        println("plot debug::", v)
        xdata = [info.helpers.dates.range...]
        if size(opt_var, 2) == 1
            # plot(xdata, def_var[:, 1]; label="def ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(domain):: $(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
            plot(xdata, opt_var[:, 1]; label="opt ($(round(SindbadTEM.mean(opt_var[:, 1]), digits=2)))")
            ylabel!("$(vinfo["standard_name"])", font=(20, :green), size=(2000, 1000), title="$(domain):: $(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
            savefig(fig_prefix * "_$(v).png")
        else
            foreach(axes(opt_var, 2)) do ll
                # plot(xdata, def_var[:, ll]; label="def ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
                plot(xdata, opt_var[:, ll]; label="opt ($(round(SindbadTEM.mean(opt_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(domain):: $(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
                ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                savefig(fig_prefix * "_$(v)_$(ll).png")
            end
        end
    end
# end