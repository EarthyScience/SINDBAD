using Revise
using SindbadTEM
toggleStackTraceNT()
using Dates
using Plots


experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "2005"
eYear = "2017"
domain = "DE-Hai"
# domain = "CA-NS6"
# domain = "AU-Emr"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing

parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => sYear * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "experiment.basics.time.date_end" => eYear * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.spinup.save_spinup" => false,
    "experiment.flags.catch_model_errors" => true,
    "experiment.flags.spinup.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.flags.spinup.run_spinup" => true,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.output_array_type" => "array",
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

nrepeat = 200

data_path = getAbsDataPath(info, path_input)
nc = SindbadData.NetCDF.open(data_path);
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
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d > 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "all_years", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_A0H", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat_d),
    ]
else
    error("cannot determine the repeat for disturbance")
end
replace_info["experiment.model_spinup.sequence"] = sequence
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_types = prepTEM(forcing, info);


@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_types)

@time output_default = runExperimentForward(experiment_json; replace_info=replace_info);

default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
out_vars = valToSymbol(tem_with_types.helpers.vals.output_vars);
for (o, v) in enumerate(out_vars)
    def_var = output_array[o][:, :, 1, 1]
    vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
    xdata = [info.tem.helpers.dates.range...]
    if size(def_var, 2) == 1
        plot(xdata, def_var[:, 1]; label="def ($(round(SindbadTEM.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
        ylabel!("$(vinfo["standard_name"])")
        savefig(joinpath(info.output.figure, "dbg_wroasted_$(domain)_$(vinfo["standard_name"]).png"))
    else
        foreach(axes(def_var, 2)) do ll
            plot(xdata, def_var[:, ll]; label="def ($(round(SindbadTEM.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
            ylabel!("$(vinfo["standard_name"])")
            savefig(joinpath(info.output.figure, "dbg_wroasted_$(domain)_$(vinfo["standard_name"])_$(ll).png"))
        end
    end

end


