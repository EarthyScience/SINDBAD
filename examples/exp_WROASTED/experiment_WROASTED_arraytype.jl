using Revise
using SindbadExperiment
using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"

domain = "AU-DaP"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_input
optimize_it = true
# optimize_it = false
path_output = nothing
plt = plot(; legend=:outerbottom, size=(2000, 1000))
lt = (:solid, :dash, :dot)
parallelization_lib = "threads"
model_array_type = "view"
info = nothing
for (i, model_array_type) in enumerate(("array", "view", "static_array"))
    replace_info = Dict("experiment.basics.time.date_begin" => sYear * "-01-01",
        "experiment.basics.config_files.forcing" => forcing_config,
        "experiment.basics.domain" => domain,
        "experiment.basics.time.date_end" => eYear * "-12-31",
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

    forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_types, forcing_one_timestep =
        prepTEM(forcing, info)
    @time runTEM!(output_array,
        info.tem.models.forward,
        forcing_nt_array,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        forcing_one_timestep,
        tem_with_types)
    # some plots
    ds = forcing.data[1]
    opt_dat = output_array
    plot!(opt_dat[3][end, :, 1, 1];
        linewidth=5,
        ls=lt[i],
        label=model_array_type)
    # plot(def_var; label="def", size=(2000, 1000), title=v)
    #     plot!(opt_var; label="opt")
    #     if v in obsMod
    #         obsv = obsVar[findall(obsMod .== v)[1]]
    #         @show "plot obs", v
    #         obs_var = getfield(obs_array, obsv)[tspan, 1, 1, 1]
    #         plot!(obs_var; label="obs")
    #         # title(obsv)
    #     end
    # end
end
savefig(joinpath(info.output.figure, "tmp.png"))
#     savefig("wroasted_$(domain)_$(v).png")
