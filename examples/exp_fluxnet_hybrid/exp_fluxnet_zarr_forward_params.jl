using Revise
using SindbadExperiment

toggleStackTraceNT()

setLogLevel(:warn)

# site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
for site_index in 1:205
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

    # forcing_set = "zarr";
    # forcing_config = "forcing_$(forcing_set).json";
    parallelization_lib = "threads"
    exp_main = "Insitu_v202503"

    opti_set = (:set1, :set2, :set3, :set4, :set5, :set6, :set7, :set9, :set10,)
    opti_set = (:set1, :set3, :set9)
    opti_set = (:set9,)
    opti_cost = ("NSE", "NNSE")
    optimize_it = true;
    o_set = :set3
    o_cost = "NNSE"
    for o_set in opti_set
        for o_cost in opti_cost
            path_output = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)/$(forcing_set)/$(o_set)"
            exp_name = "$(exp_main)_$(forcing_set)_$(o_set)_$(o_cost)"

            params_file = joinpath(path_output, "$(domain)_$(exp_name)", "optimization", "$(exp_name)_$(domain)_model_parameters_to_optimize.csv")
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

            if isfile(params_file)
                replace_info["experiment.basics.config_files.parameters"] = params_file
                println("$(site_index): File $(params_file) exists, and hence will run the experiment with optimized parameters....")
            else
                println("$(site_index): File $(params_file) does not exist, and hence cannot run the experiment with optimized parameters. Running with default.")
            end


            out_forw = runExperimentForward(experiment_json; replace_info=replace_info, log_level=:error);

            # save the outcubes
            output_array_forw = values(out_forw.output)
            info = out_forw.info;
            output_vars = info.output.variables
            output_dims = getOutDims(info, out_forw.forcing.helpers)

            setLogLevel(:warn)
            saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_forw, output_dims, output_vars, "zarr", info.experiment.basics.temporal_resolution, DoSaveSingleFile())
            saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_forw, output_dims, output_vars, "zarr", info.experiment.basics.temporal_resolution, DoNotSaveSingleFile())

            saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_forw, output_dims, output_vars, "nc", info.experiment.basics.temporal_resolution, DoSaveSingleFile())
            saveOutCubes(info.output.file_info.file_prefix, info.output.file_info.global_metadata, output_array_forw, output_dims, output_vars, "nc", info.experiment.basics.temporal_resolution, DoNotSaveSingleFile())
        end
    end
end