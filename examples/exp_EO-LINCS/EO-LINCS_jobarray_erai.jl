using Revise
using SindbadExperiment
using Dates
using Plots
toggleStackTraceNT()
site_index = nothing

run_method = "local" # local or slurm
exp_main = "EO-LINCS_v202510"
domain = "FR-Pue"
domain = "DE-Hai"
domain = "AT-Neu"
forcing_set = "erai"

experiment_json = "../exp_EO-LINCS/settings_EO-LINCS/experiment.json"

path_input = nothing
path_output_base = nothing
begin_year = nothing
end_year = nothing
if forcing_set == "erai"
    dataset = "ERAinterim.v2"
    begin_year = "1979"
    end_year = "2017"
else
    dataset = "CRUJRA.v2_2"
    begin_year = "1901"
    end_year = "2019"
end


if run_method == "slurm"
    if !haskey(ENV, "SLURM_ARRAY_TASK_ID")
        error("This script is intended to be run as a SLURM job array. Please submit it using sbatch with --array option.")
    else
        site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
    end
    site_info = CSV.File(
    "/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/fluxnet_sites_info/site_info_$(forcing_set).csv";
    header=false);
    domain = string(site_info[site_index][2])
    path_input = joinpath("/Net/Groups/BGI/scratch/skoirala/v202312_wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data", dataset, "daily/$(domain).$(begin_year).$(end_year).daily.nc");
    path_output_base = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)/$(forcing_set)/"

else
    path_input = joinpath("examples/exp_EO-LINCS/tmp_mergedData/", "$(domain).merged.nc");
    path_input = joinpath("/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_EO-LINCS/tmp_mergedData/", "$(domain).merged.nc")
    path_output_base = "./examples/exp_EO-LINCS/tmp_output/$(exp_main)/$(forcing_set)/"
    # path_output_base = joinpath("examples/exp_EO-LINCS/tmp_output/")
end

# site_index = Base.parse(Int, ARGS[1])
path_observation = path_input
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
    :ndvi_modis => ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi_modis"],
    :ndvi_sen2 => ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi_sen2"],
)

forcing_config = "forcing_$(forcing_set).json";
parallelization_lib = "threads"

opti_set = (:ndvi_modis, :ndvi_sen2,)
# opti_set = (:set3,)
o_set = :ndvi_modis
optimize_it = true;
for o_set in opti_set

    exp_name = "$(exp_main)_$(forcing_set)_$(o_set)"
    path_output = joinpath(path_output_base, "$(exp_name)")

    replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
        "experiment.basics.config_files.forcing" => forcing_config,
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
        # "experiment.model_output.path" => path_output,
        "experiment.exe_rules.parallelization" => parallelization_lib,
        "optimization.algorithm_optimization" => "opti_algorithms/CMAEvolutionStrategy_CMAES_mt.json",
        "optimization.optimization_cost_method" => "CostModelObsMT",
        "optimization.optimization_cost_threaded"  => true,
        "optimization.observations.default_observation.data_path" => path_observation,
        "optimization.observational_constraints" => opti_sets[o_set],)
# info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info
# forcing = getForcing(info);
# run_helpers = prepTEM(forcing, info);
# @time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

    @time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info);

    forcing = out_opti.forcing;
    obs_array = out_opti.observation;
    info = out_opti.info;
    
    # some plots
    opt_dat = out_opti.output.optimized
    def_dat = out_opti.output.default
    costOpt = prepCostOptions(obs_array, info.optimization.cost_options)
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))

    # load matlab wroasted results


    fig_prefix = joinpath(info.output.dirs.figure, "comparison_" * info.experiment.basics.name * "_" * info.experiment.basics.domain)

    foreach(costOpt) do var_row
        v = var_row.variable
        @show "plot obs", v
        v = (var_row.mod_field, var_row.mod_subfield)
        vinfo = getVariableInfo(v, info.experiment.basics.temporal_resolution)
        v = vinfo["standard_name"]
        lossMetric = var_row.cost_metric
        loss_name = nameof(typeof(lossMetric))
        if loss_name in (:NNSEInv, :NSEInv)
            lossMetric = NSE()
        end
        valids = var_row.valids;
        (obs_var, obs_σ, def_var) = getData(def_dat, obs_array, var_row)
        (_, _, opt_var) = getData(opt_dat, obs_array, var_row)
        obs_var_TMP = obs_var[:, 1, 1, 1]
        non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
        tspan = 1:length(obs_var_TMP)
        if length(non_nan_index) < 2
            tspan = 1:length(obs_var_TMP)
        else
            tspan = first(non_nan_index):last(non_nan_index)
        end

        obs_σ = obs_σ[tspan]
        obs_var = obs_var[tspan]
        def_var = def_var[tspan, 1, 1, 1]
        opt_var = opt_var[tspan, 1, 1, 1]
        valids = valids[tspan]

        xdata = [info.helpers.dates.range[tspan]...]

        metr_def = metric(obs_var[valids], obs_σ[valids], def_var[valids], lossMetric)
        metr_opt = metric(obs_var[valids], obs_σ[valids], opt_var[valids], lossMetric)

        plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
        plot!(xdata, def_var, color=:steelblue2, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=4, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(nameof(typeof(lossMetric))), $(forcing_set), $(o_set)")
        plot!(xdata, opt_var; color=:seagreen3, label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
        savefig(fig_prefix * "_$(v)_$(forcing_set).png")
    end

    # save the outcubes
    output_array_opt = values(opt_dat)
    output_array_def = values(def_dat)
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
        def_var = output_array_def[o][:, :, 1, 1]
        opt_var = output_array_opt[o][:, :, 1, 1]
        vinfo = getVariableInfo(v, info.experiment.basics.temporal_resolution)
        v = vinfo["standard_name"]
        println("plot debug::", v)
        xdata = [info.helpers.dates.range...]
        if size(opt_var, 2) == 1
            plot(xdata, def_var[:, 1]; label="def ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
            plot!(xdata, opt_var, color=:seagreen3; label="opt ($(round(SindbadTEM.mean(opt_var), digits=2)))")
            ylabel!("$(vinfo["standard_name"])", font=(20, :green))
            savefig(fig_prefix * "_$(v).png")
        else
            foreach(axes(opt_var, 2)) do ll
                plot(xdata, def_var[:, ll]; label="def ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
                plot!(xdata, opt_var[:, ll]; color=:seagreen3, label="opt ($(round(SindbadTEM.mean(opt_var[:, ll]), digits=2)))")
                ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                savefig(fig_prefix * "_$(v)_$(ll).png")
            end
        end
    end
end