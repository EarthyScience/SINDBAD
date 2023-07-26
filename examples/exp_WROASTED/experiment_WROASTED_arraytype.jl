using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Plots
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"

# path_input = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# path_input = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
# path_input = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
domain = "AU-DaP"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

path_observation = path_input
optimize_it = true
# optimize_it = false
path_output = nothing
plt = plot(; legend=:outerbottom, size=(1200, 900))
lt = (:solid, :dash, :dot)
pl = "threads"
arraymethod = "view"
info = nothing
for (i, arraymethod) in enumerate(("array", "view", "staticarray"))
    replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
        "experiment.configuration_files.forcing" => forcingConfig,
        "experiment.domain" => domain,
        "model_run.time.end_date" => eYear * "-12-31",
        "model_run.flags.run_optimization" => false,
        "model_run.flags.run_forward_and_cost" => false,
        "model_run.flags.spinup.save_spinup" => false,
        "model_run.flags.catch_model_errors" => true,
        "model_run.flags.spinup.run_spinup" => false,
        "model_run.flags.debug_model" => false,
        "model_run.rules.model_array_type" => arraymethod,
        "model_run.flags.spinup.do_spinup" => true,
        "forcing.default_forcing.data_path" => path_input,
        "model_run.output.path" => path_output,
        "model_run.mapping.parallelization" => pl,
        "optimization.constraints.default_constraint.data_path" => path_observation)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify information from json with the replace_info

    info, forcing = getForcing(info)

    output = setupOutput(info)

    forc = getKeyedArrayWithNames(forcing)

    linit = createLandInit(info.pools, info.tem.helpers, info.tem.models)

    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
        prepRunEcosystem(output, forc, info.tem)
    @time runEcosystem!(output.data,
        info.tem.models.forward,
        forc,
        tem_with_vals,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    # some plots
    ds = forcing.data[1]
    opt_dat = output.data
    plot!(opt_dat[3][end, :, 1, 1];
        linewidth=5,
        ls=lt[i],
        label=arraymethod)
    # plot(def_var; label="def", size=(1200, 900), title=v)
    #     plot!(opt_var; label="opt")
    #     if v in obsMod
    #         obsv = obsVar[findall(obsMod .== v)[1]]
    #         @show "plot obs", v
    #         obs_var = getfield(obs, obsv)[tspan, 1, 1, 1]
    #         plot!(obs_var; label="obs")
    #         # title(obsv)
    #     end
    # end
end
savefig(joinpath(info.output.figure, "tmp.png"))
#     savefig("wroasted_$(domain)_$(v).png")
# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
