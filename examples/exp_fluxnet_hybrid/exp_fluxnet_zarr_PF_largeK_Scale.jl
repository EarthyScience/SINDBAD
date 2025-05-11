using Revise
using SindbadExperiment
using Dates
using Plots
toggleStackTraceNT()

site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
# site_index = 89
# site_index = Base.parse(Int, ARGS[1])
forcing_set = "erai"
site_info = CSV.File(
    "/Net/Groups/BGI/scratch/skoirala/prod_sindbad.jl/examples/exp_WROASTED/settings_WROASTED/site_names_disturbance.csv";
    header=true);
domain = string(site_info[site_index][1])
y_dist = string(site_info[site_index][2])

experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"
path_input = nothing
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
path_input = "/Net/Groups/BGI/work_4/scratch/lalonso/FLUXNET_v2023_12_1D.zarr";#joinpath("/Net/Groups/BGI/scratch/skoirala/v202312_wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data", dataset, "daily/$(domain).$(begin_year).$(end_year).daily.nc");

path_observation = path_input;

nrepeat = 200

nrepeat_d = nothing
if y_dist != "undisturbed"
    y_disturb = year(Date(y_dist))
    y_start = Meta.parse(begin_year)
    nrepeat_d = y_start - y_disturb
end
sequence = nothing
if isnothing(nrepeat_d)
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AHCWD", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AHCWD", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_A0HCWD", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d > 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_A0HCWD", "forcing" => "day_MSC", "n_repeat" => 1),
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

# forcing_set = "zarr";
# forcing_config = "forcing_$(forcing_set).json";
parallelization_lib = "threads"
exp_main = "Insitu_v202505_RgPot_LargeK_Reserve_Scale"

opti_set = (:set1, :set2, :set3, :set4, :set5, :set6, :set7, :set9, :set10,)
opti_set = (:set1, :set3, :set9)
# opti_set = (:set3,)
optimize_it = true;
opti_set = (:set1, :set3)
opti_set = (:set1, )
o_set = :set1

opti_cost = ("NNSE",)
# opti_cost = ("NSE", "NNSE")
o_cost = "NNSE"
for o_set in opti_set
    for o_cost in opti_cost
        path_output = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)/$(forcing_set)/$(o_set)"
        exp_name = "$(exp_main)_$(forcing_set)_$(o_set)_$(o_cost)"

        replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
            # "experiment.basics.config_files.forcing" => forcing_config,
            "experiment.basics.config_files.optimization" => "optimization_$(o_cost).json",
            "experiment.basics.domain" => domain,
            "experiment.basics.name" => exp_name,
            "experiment.basics.time.date_end" => end_year * "-12-31",
            "experiment.exe_rules.input_data_backend" => "zarr",
            "experiment.exe_rules.land_output_type" => "array",
            "experiment.flags.run_optimization" => optimize_it,
            "experiment.flags.calc_cost" => true,
            "experiment.flags.catch_model_errors" => true,
            "experiment.flags.spinup_TEM" => true,
            "experiment.flags.debug_model" => false,
            "experiment.model_spinup.sequence" => sequence,
            "forcing.default_forcing.data_path" => path_input,
            "forcing.subset.site" => [site_index, site_index],
            "experiment.model_output.path" => path_output,
            "experiment.exe_rules.parallelization" => parallelization_lib,
            "optimization.optimization_cost_method" => "CostModelObsMT",
            "optimization.optimization_cost_threaded" => true,
            "optimization.optimization_parameter_scaling" => "scale_bounds",
            "optimization.algorithm_optimization" => "CMAEvolutionStrategy_CMAES_fn_insitu.json",
            "optimization.observations.default_observation.data_path" => path_observation,
            "optimization.observational_constraints" => opti_sets[o_set],)

        replace_info["experiment.basics.config_files.model_structure"] = "model_structure_PF_largeK_Scale.json";
        replace_info["experiment.basics.config_files.optimization"] = "optimization_PF.json";

        info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

        forcing = getForcing(info);

        observations = getObservation(info, forcing.helpers);
        run_helpers = prepTEM(forcing, info);
        @time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info);

        forcing = out_opti.forcing;
        obs_array = out_opti.observation;
        info = out_opti.info;

        # some plots
        opt_dat = out_opti.output.optimized;
        def_dat = out_opti.output.default;
        costOpt = prepCostOptions(obs_array, info.optimization.cost_options);
        default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue));

        # load matlab wroasted results

        fig_prefix = joinpath(info.output.dirs.figure, "comparison_" * info.experiment.basics.name * "_" * info.experiment.basics.domain);

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
            valids = var_row.valids
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
            def_var = def_var[tspan, 1, 1, 1]
            opt_var = opt_var[tspan, 1, 1, 1]
            valids = valids[tspan]

            xdata = [info.helpers.dates.range[tspan]...]

            metr_def = metric(obs_var[valids], obs_σ[valids], def_var[valids], lossMetric)
            metr_opt = metric(obs_var[valids], obs_σ[valids], opt_var[valids], lossMetric)

            plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
            plot!(xdata, def_var, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=4, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(domain): $(vinfo["long_name"]) ($(vinfo["units"])) -> $(nameof(typeof(lossMetric))), $(forcing_set), $(o_set)", color=:steelblue2)
            plot!(xdata, opt_var; label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash, color=:seagreen3)
            savefig(fig_prefix * "_$(v)_$(forcing_set).png")
        end

        # save the outcubes
        output_array_opt = values(opt_dat)
        output_array_def = values(def_dat)
        output_vars = info.output.variables
        output_dims = getOutDims(info, out_opti.forcing.helpers)

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
                plot(xdata, def_var[:, 1]; label="def ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm, color=:steelblue2)
                plot!(xdata, opt_var[:, 1]; label="opt ($(round(SindbadTEM.mean(opt_var[:, 1]), digits=2)))", color=:seagreen3)
                ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                savefig(fig_prefix * "_$(v).png")
            else
                foreach(axes(opt_var, 2)) do ll
                    plot(xdata, def_var[:, ll]; label="def ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(domain): $(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm, color=:steelblue2)
                    plot!(xdata, opt_var[:, ll]; label="opt ($(round(SindbadTEM.mean(opt_var[:, ll]), digits=2)))", color=:seagreen3)
                    ylabel!("$(vinfo["standard_name"])", font=(20, :green))
                    savefig(fig_prefix * "_$(v)_$(ll).png")
                end
            end
        end
    end
end