using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Plots
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# inpath = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
# inpath = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
domain = "AU-DaP"
inpath = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

obspath = inpath
optimize_it = true
# optimize_it = false
outpath = nothing
plt = plot(; legend=:outerbottom, size=(900, 600))
lt = (:solid, :dash, :dot)
pl = "threads"
arraymethod = "view"
for (i, arraymethod) in enumerate(("array", "view", "staticarray"))
    replace_info = Dict("modelRun.time.sDate" => sYear * "-01-01",
        "experiment.configFiles.forcing" => forcingConfig,
        "experiment.domain" => domain,
        "modelRun.time.eDate" => eYear * "-12-31",
        "modelRun.flags.runOpti" => false,
        "modelRun.flags.calcCost" => false,
        "spinup.flags.saveSpinup" => false,
        "modelRun.flags.catchErrors" => true,
        "modelRun.flags.runSpinup" => false,
        "modelRun.flags.debugit" => false,
        "modelRun.rules.model_array_type" => arraymethod,
        "spinup.flags.doSpinup" => true,
        "forcing.default_forcing.dataPath" => inpath,
        "modelRun.output.path" => outpath,
        "modelRun.mapping.parallelization" => pl,
        "opti.constraints.oneDataPath" => obspath)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info

    info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))

    output = setupOutput(info)

    forc = getKeyedArrayFromYaxArray(forcing)

    linit = createLandInit(info.pools, info.tem.helpers, info.tem.models)

    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one =
        prepRunEcosystem(output, forc, info.tem)
    @time runEcosystem!(output.data,
        info.tem.models.forward,
        forc,
        info.tem,
        Val(info.tem.variables),
        loc_space_names,
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
    # plot(def_var; label="def", size=(900, 600), title=v)
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
savefig("tmp.png")
#     savefig("wroasted_$(domain)_$(v).png")
# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
