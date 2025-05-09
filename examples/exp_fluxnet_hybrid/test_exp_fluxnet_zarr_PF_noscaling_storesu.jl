using Revise
using SindbadExperiment
using Dates
using Plots
toggleStackTraceNT()

# site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
site_index = 68
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
exp_main = "Insitu_v202503_PF_Slopes_NoScaling_RgPot"

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
param_local = "/Net/Groups/BGI/scratch/skoirala/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_._DE-Hai_Insitu_v202503_PF_Slopes_NoScaling_RgPot_erai_set1_NNSE/optimization/Insitu_v202503_PF_Slopes_NoScaling_RgPot_erai_set1_NNSE_DE-Hai_model_parameters_optimized.csv"
prm = Table(CSV.File(param_local));

path_output = "./"
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
    "experiment.flags.store_spinup" => true,
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

replace_info["experiment.basics.config_files.model_structure"] = "model_structure_PF.json";
replace_info["experiment.basics.config_files.optimization"] = "optimization_PF.json";
replace_info["model_structure.parameter_table"] = prm;

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

observations = getObservation(info, forcing.helpers);
run_helpers = prepTEM(forcing, info);

long_spin =  spinupTEM(info.models.forward, run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, run_helpers.loc_land, run_helpers.tem_info, DoSpinupTEM());
lw=LandWrapper(long_spin.states.spinuplog)
# spinupTEM(info.models.forward, run_helpers.spac spinup_forcings, loc_forcing_t, land, tem_info, ::DoSpinupTEM) 
# # @ SindbadTEM /Net/Groups/BGI/scratch/skoirala/RnD/SINDBAD-RnD-SK/lib/SindbadTEM/src/spinupTEM.jl:641

cEco_all = map(long_spin.states.spinuplog) do ll
    ll.cEco
end;

pool_comps = info.helpers.pools.components.cEco;
rot_max = 90
for i in 1:8
    default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue));
    fig_prefix = joinpath(info.output.dirs.figure, "pool_comparison_" * info.experiment.basics.name * "_" * info.experiment.basics.domain);    
    cpool = map(cEco_all) do cE
        cE[i]
    end
    plot(cpool; label="Spinup ($(round(SindbadTEM.mean(cpool), digits=2)))", size=(2000, 1000), title="layer $(i): $(pool_comps[i])", left_margin=1Plots.cm, color=:steelblue2)
    vline!([1], color=:red, linestyle=:dash, label="Init")
    annotate!(1, cpool[1], text("Init", :red, :bold, rotation=rot_max))
    v_loc = 1
    s_ind = 2
    for seq in sequence
        println("n_repeat: $(seq["n_repeat"]), spinup_mode: $(seq["spinup_mode"]), forcing: $(seq["forcing"])")
        s_name = string(seq["n_repeat"]) * "_" * string(seq["spinup_mode"]) * "_" * string(seq["forcing"]) 
        v_loc = v_loc + seq["n_repeat"]
        random_color = RGB(rand(), rand(), rand())
        vline!([v_loc], color=random_color, linestyle=:dash, label="$(s_name)")
        annotate!(v_loc, cpool[v_loc]/s_ind, text("$(s_name)", random_color, :bold, rotation=rot_max))
        s_ind += 1
    end
    savefig(fig_prefix * "$(forcing_set)_layer$(i).png")
    println("--------------------------------")

end


# end