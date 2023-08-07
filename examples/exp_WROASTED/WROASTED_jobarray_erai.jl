using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Dates
using Plots
noStackTrace()

# site_index = 1
site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
# site_index = Base.parse(Int, ARGS[1])
forcing_set = "erai"
site_info = Sindbad.CSV.File(
    "/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/fluxnet_sites_info/site_info_$(forcing_set).csv";
    header=false);
domain = string(site_info[site_index][2])

experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
path_input = nothing
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
ml_data_file = joinpath(ml_main_dir, "sindbad_processed_sets/set1/fluxnetBGI2021.BRK15.DD", dataset, "data", "$(domain).$(sYear).$(eYear).daily.nc")
path_input = joinpath("/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data", dataset, "daily/$(domain).$(sYear).$(eYear).daily.nc");
path_observation = path_input;

nrepeat = 200


## get the spinup sequence
nc = ForwardSindbad.NetCDF.open(path_input)
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
        Dict("spinup_mode" => "spinup", "forcing" => "all_years", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "all_years", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "all_years", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleA0H", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d > 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "all_years", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleA0H", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat_d),
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

forcingConfig = "forcing_$(forcing_set).json";
pl = "threads"
exp_main = "wroasted_no_unc_nnse"

opti_set = (:set1, :set2, :set3, :set4, :set5, :set6, :set7, :set9, :set10,)
# opti_set = (:set1,)
optimize_it = true;
for o_set in opti_set
    path_output = "/Net/Groups/BGI/scratch/skoirala/$(exp_main)_sjindbad/$(forcing_set)/$(o_set)"

    exp_name = "$(exp_main)_$(forcing_set)_$(o_set)"

    replace_info = Dict("model_run.experiment_time.date_begin" => sYear * "-01-01",
        "experiment.configuration_files.forcing" => forcingConfig,
        "experiment.domain" => domain,
        "experiment.name" => exp_name,
        "model_run.experiment_time.date_end" => eYear * "-12-31",
        "model_run.experiment_flags.run_optimization" => optimize_it,
        "model_run.experiment_flags.run_forward_and_cost" => true,
        "model_run.experiment_flags.spinup.save_spinup" => false,
        "model_run.experiment_flags.catch_model_errors" => true,
        "model_run.experiment_flags.spinup.run_spinup" => true,
        "model_run.experiment_flags.debug_model" => false,
        "model_run.experiment_flags.spinup.do_spinup" => true,
        "model_run.spinup.sequence" => sequence,
        "forcing.default_forcing.data_path" => path_input,
        "model_run.output.path" => path_output,
        "model_run.experiment_rules.parallelization" => pl,
        "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES_10000.json",
        "optimization.observations.default_observation.data_path" => path_observation,
        "optimization.observational_constraints" => opti_sets[o_set],)

    @time output_default = runExperimentForward(experiment_json; replace_info=replace_info)
    @time opt_params = runExperimentOpti(experiment_json; replace_info=replace_info)


    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info

    tbl_params = Sindbad.getParameters(info.tem.models.forward,
        info.optim.model_parameter_default,
        info.optim.model_parameters_to_optimize)
    optimized_models = updateModelParameters(tbl_params, info.tem.models.forward, opt_params)

    forcing = getForcing(info)
    observations = getObservation(info, forcing.helpers)
    obs_array = getKeyedArray(observations)

    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info)

    @time simulateTEM!(optimized_models,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem_with_vals)

    # some plots
    ds = forcing.data[1]
    opt_dat = output_array
    def_dat = output_default
    out_vars = valToSymbol(tem_with_vals.helpers.vals.output_vars)
    costOpt = info.optim.cost_options
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))

    # load matlab wroasted results
    nc_ml = ForwardSindbad.NetCDF.open(ml_data_file)

    varib_dict = Dict(:gpp => "gpp", :nee => "NEE", :transpiration => "tranAct", :evapotranspiration => "evapTotal", :ndvi => "fAPAR", :agb => "cEco", :reco => "cRECO", :nirv => "gpp")

    fig_prefix = joinpath(info.output.figure, "eval_" * info.experiment.name * "_" * info.experiment.domain)

    foreach(costOpt) do var_row
        v = var_row.variable
        @show "plot obs", v
        ml_dat = nc_ml[varib_dict[v]][:]
        if v == :agb
            ml_dat = nc_ml[varib_dict[v]][1, 1, 2, :]
        elseif v == :ndvi
            ml_dat = ml_dat .- ForwardSindbad.Statistics.mean(ml_dat)
        end
        v = (var_row.mod_field, var_row.mod_subfield)
        vinfo = getVariableInfo(v, info.model_run.experiment_time.temporal_resolution)
        v = vinfo["standard_name"]
        lossMetric = var_row.cost_metric
        loss_name = valToSymbol(lossMetric)
        if loss_name in (:nnseinv, :nseinv)
            lossMetric = Val(:nse)
        end
        (obs_var, obs_σ, def_var) = getData(def_dat, obs_array, var_row)
        (_, _, opt_var) = getData(opt_dat, obs_array, var_row)
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
        def_var = def_var[tspan, 1, 1, 1]
        opt_var = opt_var[tspan, 1, 1, 1]

        xdata = [info.tem.helpers.dates.range[tspan]...]
        obs_var_n, obs_σ_n, ml_dat_n = filterCommonNaN(obs_var, obs_σ, ml_dat)
        obs_var_n, obs_σ_n, def_var_n = filterCommonNaN(obs_var, obs_σ, def_var)
        obs_var_n, obs_σ_n, opt_var_n = filterCommonNaN(obs_var, obs_σ, opt_var)
        metr_ml = loss(obs_var_n, obs_σ_n, ml_dat_n, lossMetric)
        metr_def = loss(obs_var_n, obs_σ_n, def_var_n, lossMetric)
        metr_opt = loss(obs_var_n, obs_σ_n, opt_var_n, lossMetric)
        plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
        plot!(xdata, def_var, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=4, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(valToSymbol(lossMetric)), $(forcing_set), $(o_set)")
        plot!(xdata, opt_var; label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
        plot!(xdata, ml_dat; label="matlab ($(round(metr_ml, digits=2)))", lw=1.5, ls=:dash)
        savefig(fig_prefix * "_$(v)_$(forcing_set).png")
    end


    ### redo the forward run to save all output variables
    replace_info["model_run.experiment_flags.run_forward_and_cost"] = false
    replace_info["model_run.experiment_flags.run_optimization"] = false
    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info
    forcing = getForcing(info)


    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info)
    @time simulateTEM!(optimized_models,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem_with_vals)

    # save the outcubes

    out_info = getOutputFileInfo(info)
    saveOutCubes(out_info.file_prefix, out_info.global_info, out_vars, output_array, output.dims, "zarr", info.model_run.experiment_time.temporal_resolution, Val(true))
    saveOutCubes(out_info.file_prefix, out_info.global_info, out_vars, output_array, output.dims, "zarr", info.model_run.experiment_time.temporal_resolution, Val(false))

    saveOutCubes(out_info.file_prefix, out_info.global_info, out_vars, output_array, output.dims, "nc", info.model_run.experiment_time.temporal_resolution, Val(true))
    saveOutCubes(out_info.file_prefix, out_info.global_info, out_vars, output_array, output.dims, "nc", info.model_run.experiment_time.temporal_resolution, Val(false))


    # plot the debug figures
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    out_vars = out_vars
    fig_prefix = joinpath(info.output.figure, "debug_" * info.experiment.name * "_" * info.experiment.domain)
    for (o, v) in enumerate(out_vars)
        def_var = output_array[o][:, :, 1, 1]
        vinfo = getVariableInfo(v, info.model_run.experiment_time.temporal_resolution)
        v = vinfo["standard_name"]
        xdata = [info.tem.helpers.dates.range...]
        if size(def_var, 2) == 1
            plot(xdata, def_var[:, 1]; label="optim_forw ($(round(ForwardSindbad.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
            ylabel!("$(vinfo["standard_name"])", font=(20, :green))
            savefig(fig_prefix * "_$(v)_$(forcing_set).png")
        else
            foreach(axes(def_var, 2)) do ll
                plot(xdata, def_var[:, ll]; label="optim_forw ($(round(ForwardSindbad.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
                ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                savefig(fig_prefix * "_$(v)_$(ll)_$(forcing_set).png")
            end
        end
    end
end