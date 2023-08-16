using Revise
using SindbadTEM
using SindbadData
using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "1979"
end_year = "2017"

domain = "AU-DaP"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_input
optimize_it = false
path_output = nothing
var_select = (:pools => :cEco)
var_name = "$(first(var_select))_$(last(var_select))"
plt = plot(; legend=:outerbottom, size=(2000, 1000), title="$var_name")
lt = (:solid, :dash, :dot)
parallelization_lib = "threads"
model_array_type = "view"
info = nothing
for (i, model_array_type) in enumerate(("array", "view", "static_array"))
    replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
        "experiment.basics.config_files.forcing" => forcing_config,
        "experiment.basics.domain" => domain,
        "experiment.basics.time.date_end" => end_year * "-12-31",
        "experiment.flags.run_optimization" => false,
        "experiment.flags.calc_cost" => false,
        "experiment.flags.spinup.save_spinup" => false,
        "experiment.flags.catch_model_errors" => true,
        "experiment.flags.spinup.spinup_TEM" => false,
        "experiment.flags.debug_model" => false,
        "experiment.exe_rules.model_array_type" => model_array_type,
        "experiment.flags.spinup.run_spinup" => true,
        "forcing.default_forcing.data_path" => path_input,
        "experiment.model_output.path" => path_output,
        "experiment.exe_rules.parallelization" => parallelization_lib,
        "optimization.observations.default_observation.data_path" => path_observation)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info
    forcing = getForcing(info)
    linit = createLandInit(info.pools, info.tem.helpers, info.tem.models)
    run_helpers = prepTEM(forcing, info)
    @time runTEM!(info.tem.models.forward,
        run_helpers.forcing_nt_array,
        run_helpers.loc_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.output_array,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.loc_space_inds,
        run_helpers.tem_with_types)
    ds = forcing.data[1]
    opt_dat = run_helpers.output_array
    out_vars = run_helpers.out_vars
    sel_var_index = findall(x->first(x) == first(var_select) && last(x) == last(var_select), out_vars)[1]
    plot!(opt_dat[sel_var_index][end, :, 1, 1];
        linewidth=5,
        ls=lt[i],
        label=model_array_type)
    
end
savefig(joinpath(info.output.figure, "compare_model_array_types_$(var_name).png"))
