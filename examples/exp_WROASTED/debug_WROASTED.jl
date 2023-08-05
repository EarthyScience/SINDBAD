using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()
using Dates
using Plots


# path_input = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# path_input = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
# path_input = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "2005"
eYear = "2017"
domain = "DE-Hai"
domain = "CA-NS6"
domain = "AU-Emr"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing

pl = "threads"
arraymethod = "staticarray"
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => false,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.catch_model_errors" => true,
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.rules.model_array_type" => arraymethod,
    "model_run.flags.spinup.do_spinup" => true,
    "forcing.default_forcing.data_path" => path_input,
    "model_run.output.path" => path_output,
    "model_run.output.output_array_type" => "array",
    "model_run.mapping.parallelization" => pl,
    "optimization.constraints.default_constraint.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

nrepeat = 200

data_path = getAbsDataPath(info, path_input)
nc = ForwardSindbad.NetCDF.open(data_path);
y_dist = nc.gatts["last_disturbance_on"]

nrepeat_d = nothing
if y_dist !== "undisturbed"
    y_disturb = year(Date(y_dist))
    y_start = year(Date(info.tem.helpers.dates.start_date))
    nrepeat_d = y_start - y_disturb
end
sequence = nothing
if isnothing(nrepeat_d)
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "day_msc", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
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
replace_info["model_run.spinup.sequence"] = sequence
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# mtup = Tuple([(nameof.(typeof.(info.tem.models.forward))..., info.tem.models.forward...)]);
# tcprint(mtup)
# forc = getNamedDimsArrayWithNames(forcing)
forc = getKeyedArrayWithNames(forcing);
output = setupOutput(info, forcing.helpers);

linit = createLandInit(info.pools, info.tem.helpers, info.tem.models);



loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output,
        forc,
        info.tem);


@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info);

# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one)
# land_spin = land_init_space[1];
# @time land_spin_now = runSpinup(info.tem.models.forward,
#     loc_forcings[1],
#     land_spin,
#     tem_with_vals.helpers,
#     tem_with_vals.spinup,
#     tem_with_vals.models,
#     typeof(land_spin),
#     f_one);

default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
out_vars = output.variables;
for (o, v) in enumerate(out_vars)
    def_var = output.data[o][:, :, 1, 1]
    vinfo = getVariableInfo(v, info.model_run.time.model_time_step)
    xdata = [info.tem.helpers.dates.range...]
    if size(def_var, 2) == 1
        plot(xdata, def_var[:, 1]; label="def ($(round(ForwardSindbad.mean(def_var[:, 1]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"]))", left_margin=1Plots.cm)
        ylabel!("$(vinfo["standard_name"])")
        savefig(joinpath(info.output.figure, "dbg_wroasted_$(domain)_$(vinfo["standard_name"]).png"))
    else
        for ll ∈ 1:size(def_var, 2)
            plot(xdata, def_var[:, ll]; label="def ($(round(ForwardSindbad.mean(def_var[:, ll]), digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]), layer $(ll),  ($(vinfo["units"]))", left_margin=1Plots.cm)
            ylabel!("$(vinfo["standard_name"])")
            savefig(joinpath(info.output.figure, "dbg_wroasted_$(domain)_$(vinfo["standard_name"])_$(ll).png"))
        end
    end

end


# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
