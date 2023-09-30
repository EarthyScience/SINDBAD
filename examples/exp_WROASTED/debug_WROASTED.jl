using Revise
using SindbadTEM
using SindbadData
toggleStackTraceNT()
using Dates
using Plots


experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "2005"
end_year = "2017"
domain = "SD-Dem"
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
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "experiment.basics.time.date_end" => end_year * "-12-31",
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
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "sel_spinup_models", "forcing" => "day_MSC", "n_repeat" => nrepeat),
        Dict("spinup_mode" => "eta_scale_AH", "forcing" => "day_MSC", "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
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
replace_info["experiment.model_spinup.sequence"] = sequence
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);
# output = prepTEMOut(info, forcing.helpers);
# output_array = output.data;
# ovars = output.variables;
# i = 1
# output_array2 = map(output_array) do od
#     ov = ovars[i]
#     mod_field = first(ov)
#     mod_subfield = last(ov)
#     lvar = getproperty(getproperty(land_one, mod_field), mod_subfield)
#     @show lvar, typeof(lvar)
#     @show ov, typeof(od)
#     eltype(lvar).(od)
# end

old_mods = info.tem.models.forward

run_helpers = prepTEM(old_mods, forcing, info);
# land_one = run_helpers.land_one;
@time runTEM!(old_mods,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)


mods = LongTuple(info.tem.models.forward...);

run_helpers_m = prepTEM(mods, forcing, info);
    # land_one = run_helpers.land_one;
@time runTEM!(mods,
        run_helpers_m.loc_forcings,
        run_helpers_m.loc_spinup_forcings,
        run_helpers_m.forcing_one_timestep,
        run_helpers_m.loc_outputs,
        run_helpers_m.land_init_space,
        run_helpers_m.tem_with_types)
    

    
@time coreTEM!(old_mods,
    run_helpers.loc_forcings[1],
    run_helpers.loc_spinup_forcings[1],
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs[1],
    run_helpers.land_init_space[1],
    run_helpers.tem_with_types.helpers,
    run_helpers.tem_with_types.models,
    run_helpers.tem_with_types.spinup,
    run_helpers.tem_with_types.helpers.run.spinup.spinup_TEM
    )
    
@time coreTEM!(mods,
    run_helpers_m.loc_forcings[1],
    run_helpers_m.loc_spinup_forcings[1],
    run_helpers_m.forcing_one_timestep,
    run_helpers_m.loc_outputs[1],
    run_helpers_m.land_init_space[1],
    run_helpers_m.tem_with_types.helpers,
    run_helpers_m.tem_with_types.models,
    run_helpers_m.tem_with_types.spinup,
    run_helpers_m.tem_with_types.helpers.run.spinup.spinup_TEM
    )
        

@time spinupTEM(
    old_mods,
    run_helpers.loc_spinup_forcings[1],
    run_helpers.forcing_one_timestep,
    run_helpers.land_init_space[1],
    run_helpers.tem_with_types.helpers,
    run_helpers.tem_with_types.models,
    run_helpers.tem_with_types.spinup);
        
@time spinupTEM(
    mods,
    run_helpers_m.loc_spinup_forcings[1],
    run_helpers_m.forcing_one_timestep,
    run_helpers_m.land_init_space[1],
    run_helpers_m.tem_with_types.helpers,
    run_helpers_m.tem_with_types.models,
    run_helpers_m.tem_with_types.spinup);

default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
out_vars = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars);
for (o, v) in enumerate(out_vars)
    def_var = run_helpers.output_array[o][:, :, 1, 1]
    vinfo = getVariableInfo(v, info.experiment.basics.time.temporal_resolution)
    println("plot dbg-model => site: $domain, variable: $(vinfo["standard_name"])")
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


