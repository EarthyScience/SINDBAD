using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Dates
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"
using Plots

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# inpath = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
# inpath = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
sites = ("DE-Hai", "CA-TP1", "AU-DaP")
for domain ∈ sites
    # domain = "DE-Hai"
    inpath = "../data/fn/$(domain).1979.2017.daily.nc"
    forcingConfig = "forcing_erai.json"

    obspath = inpath
    optimize_it = false
    optimize_it = true
    outpath = nothing


    pl = "threads"
    replace_info = Dict("modelRun.time.sDate" => sYear * "-01-01",
        "experiment.configFiles.forcing" => forcingConfig,
        "experiment.domain" => domain,
        "modelRun.time.eDate" => eYear * "-12-31",
        "modelRun.flags.runOpti" => optimize_it,
        "modelRun.flags.calcCost" => true,
        "spinup.flags.saveSpinup" => false,
        "modelRun.flags.catchErrors" => true,
        "modelRun.flags.runSpinup" => true,
        "modelRun.flags.debugit" => false,
        "spinup.flags.doSpinup" => true,
        "forcing.default_forcing.dataPath" => inpath,
        "modelRun.output.path" => outpath,
        "modelRun.mapping.parallelization" => pl,
        "opti.constraints.oneDataPath" => obspath)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info


    ## get the spinup sequence
    nrepeat = 200

    dataPath = getAbsDataPath(info, inpath)
    nc = ForwardSindbad.NetCDF.open(dataPath)
    y_dist = nc.gatts["last_disturbance_on"]

    nrepeat_d = nothing
    if y_dist !== "undisturbed"
        y_disturb = year(Date(y_dist))
        y_start = year(Date(info.tem.helpers.dates.sDate))
        nrepeat_d = y_start - y_disturb
    end
    sequence = nothing
    if isnothing(nrepeat_d)
        sequence = [
            Dict("spinupMode" => "spinup", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => nrepeat),
            Dict("spinupMode" => "ηScaleAH", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => 1),
        ]
    elseif nrepeat_d < 0
        sequence = [
            Dict("spinupMode" => "spinup", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => nrepeat),
            Dict("spinupMode" => "ηScaleAH", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => 1),
        ]
    elseif nrepeat_d == 0
        sequence = [
            Dict("spinupMode" => "spinup", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => nrepeat),
            Dict("spinupMode" => "ηScaleA0H", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => 1),
        ]
    elseif nrepeat_d > 0
        sequence = [
            Dict("spinupMode" => "spinup", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => nrepeat),
            Dict("spinupMode" => "ηScaleA0H", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => 1),
            Dict("spinupMode" => "spinup", "forcing" => "recycleMSC", "stopCriteria" => nothing, "nLoops" => nrepeat_d),
        ]
    else
        error("cannot determine the repeat for disturbance")
    end

    replace_info["spinup.sequence"] = sequence
    @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info)
    @time outparams = runExperimentOpti(experiment_json; replace_info=replace_info)

    info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info

    tblParams = Sindbad.getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)
    new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams)

    info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))
    forc = getKeyedArrayFromYaxArray(forcing)

    output = setupOutput(info)
    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one =
        prepRunEcosystem(output,
            forc,
            info.tem)
    @time runEcosystem!(output.data,
        new_models,
        forc,
        tem_vals,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)

    # some plots
    ds = forcing.data[1]
    opt_dat = output.data
    def_dat = outcubes
    out_vars = output.variables
    tspan = 9000:12000
    costOpt = info.optim.costOptions
    foreach(costOpt) do var_row
        v = var_row.variable
        @show "plot obs", v
        lossMetric = var_row.costMetric
        (obs_var, obs_σ, def_var) = getDataArray(def_dat, obs, var_row)
        metr_def = loss(obs_var, obs_σ, def_var, lossMetric)
        (_, _, opt_var) = getDataArray(opt_dat, obs, var_row)
        metr_opt = loss(obs_var, obs_σ, opt_var, lossMetric)
        # @show def_var
        plot(def_var[tspan, 1, 1, 1]; label="def ($(round(metr_def, digits=2)))", size=(900, 600), title="$(v) -> $(val_2_symbol(lossMetric))")
        plot!(opt_var[tspan, 1, 1, 1]; label="opt ($(round(metr_opt, digits=2)))")
        plot!(obs_var[tspan, 1, 1, 1]; label="obs")
        savefig(joinpath(info.output.figure, "wroasted_$(domain)_$(v).png"))
    end

end