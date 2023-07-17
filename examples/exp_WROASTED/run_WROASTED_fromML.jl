using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Dates
using Plots
noStackTrace()

site_index = 37
site_index = 68
# for site_index in 1:2
# site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
# site_index = Base.parse(Int, ARGS[1])
forcing = "cruj"
site_info = Sindbad.CSV.File(
    "/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/fluxnet_sites_info/site_info_$(forcing).csv";
    header=false);
domain = site_info[site_index][2]

experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = nothing
eYear = nothing
ml_main_dir = nothing
if forcing == "erai"
    dataset = "ERAinterim.v2"
    sYear = "1979"
    eYear = "2017"
    ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/sopt_sets_wroasted/"
else
    dataset = "CRUJRA.v2_2"
    sYear = "1901"
    eYear = "2019"
    ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/cruj_sets_wroasted/"
end
ml_param_file = joinpath(ml_main_dir, "sindbad_raw_set1/fluxnetBGI2021.BRK15.DD", dataset, domain, "optimization", "optimized_Params_FLUXNET_pcmaes_FLUXNET2015_daily_$(domain).json")
ml_data_file = joinpath(ml_main_dir, "sindbad_processed_sets/set1/fluxnetBGI2021.BRK15.DD", dataset, "data", "$(domain).$(sYear).$(eYear).daily.nc")

inpath = joinpath("/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data", dataset, "daily/$(domain).$(sYear).$(eYear).daily.nc");

obspath = inpath;
forcingConfig = "forcing_$(forcing).json";

outpath = "/Net/Groups/BGI/scratch/skoirala/wroasted_sjindbad_test";

nrepeat = 200
pl = "threads"
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.configuration_files.optimization" => "optimization_1_1.json",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => false,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.catch_model_errors" => false,
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.flags.spinup.do_spinup" => true,
    "forcing.default_forcing.data_path" => inpath,
    "model_run.output.path" => outpath,
    "model_run.mapping.parallelization" => pl,
    "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES_10000.json",
    "optimization.constraints.default_constraint.data_path" => obspath,)

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info


## get the spinup sequence

data_path = getAbsDataPath(info, inpath)
nc = ForwardSindbad.NetCDF.open(data_path)
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
        Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d > 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "full", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat_d),
    ]
else
    error("cannot determine the repeat for disturbance")
end

replace_info["model_run.spinup.sequence"] = sequence



# replace_info["experiment.configuration_files.parameters"] = joinpath(info.output.optim, "optimized_parameters.csv")

# ml_main_dir = "/Net/Groups/BGI/scratch/skoirala/sopt_sets_wroasted/sindbad_processed_sets/set1/fluxnetBGI2021.BRK15.DD/"
# if isfile(replace_info["experiment.configuration_files.parameters"])
tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);
outparams = tblParams.optim;
param_names = tblParams.name_full;
param_maps = Sindbad.parsefile("examples/exp_WROASTED/settings_WROASTED/ml_to_jl_params.json"; dicttype=Sindbad.DataStructures.OrderedDict)

ml_params = Sindbad.parsefile(ml_param_file; dicttype=Sindbad.DataStructures.OrderedDict)["parameter"]

for opi in eachindex(outparams)
    jl_name = param_names[opi]
    ml_name = param_maps[jl_name]
    println(jl_name, "=>", ml_name)
    ml_model = split(ml_name, ".")[1]
    ml_p = split(ml_name, ".")[2]
    ml_value = ml_params[ml_model][ml_p]
    @show outparams[opi], "old"
    outparams[opi] = ml_value
    @show outparams[opi], "new"
    println("--------------------")
end
new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams);


tblParams_2 = Sindbad.getParameters(new_models,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info

info, forcing = getForcing(info, Val(Symbol(info.model_run.rules.data_backend)));


# ### PLOT the forcings
# default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
# forc_vars = forcing.variables;
# for (o, v) in enumerate(forc_vars)
#     def_var = forcing.data[o][:, :, 1, 1]
#     xdata = [info.tem.helpers.dates.vector...]
#     if size(def_var, 1) !== length(xdata)
#         xdata=1:size(def_var,1)
#     end
#     if size(def_var, 2) == 1
#         plot(xdata, def_var[:, 1]; label="def ($(round(ForwardSindbad.mean(def_var[:, 1]), digits=2)))", size=(1200, 900), title="$(v)")
#         savefig(joinpath("examples/exp_WROASTED/tmp_figs_comparison/", "forc_wroasted_$(domain)_$(v).png"))
#     else
#         for ll ∈ 1:size(def_var, 2)
#             plot(xdata, def_var[:, ll]; label="def ($(round(ForwardSindbad.mean(def_var[:, ll]), digits=2)))", size=(1200, 900), title="$(v)")
#             savefig(joinpath("examples/exp_WROASTED/tmp_figs_comparison/", "forc_wroasted_$(domain)_$(v)_$(ll).png"))
#         end
#     end

# end

forc = getKeyedArrayFromYaxArray(forcing);
output = setupOutput(info);

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output,
        forc,
        info.tem);

@time runEcosystem!(output.data,
    new_models,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

outcubes = output.data
observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)));
obs = getObsKeyedArrayFromYaxArray(observations);


nc_ml = ForwardSindbad.NetCDF.open(ml_data_file);

varib_dict = Dict(:gpp => "gpp", :nee => "NEE", :transpiration => "tranAct", :evapotranspiration => "evapTotal", :ndvi => "fAPAR", :agb => "cEco", :reco => "cRECO")


# some plots
ds = forcing.data[1]
opt_dat = outcubes
out_vars = output.variables
costOpt = info.optim.cost_options;
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
foreach(costOpt) do var_row
    v = var_row.variable
    @show "plot obs", v
    lossMetric = var_row.cost_metric
    loss_name = valToSymbol(lossMetric)
    if loss_name in (:nnseinv, :nseinv)
        lossMetric = Val(:nse)
    end
    ml_dat = nc_ml[varib_dict[v]][:]
    if v == :agb
        ml_dat = nc_ml[varib_dict[v]][1, 1, 2, :]
    elseif v == :ndvi
        ml_dat = ml_dat .- ForwardSindbad.Statistics.mean(ml_dat)
    end
    (obs_var, obs_σ, jl_dat) = getDataArray(opt_dat, obs, var_row)
    obs_var_TMP = obs_var[:, 1, 1, 1]
    non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
    if length(non_nan_index) < 2
        tspan = 1:length(obs_var_TMP)
    else
        tspan = first(non_nan_index):last(non_nan_index)
    end
    xdata = [info.tem.helpers.dates.vector[tspan]...]
    obs_σ = obs_σ[tspan]
    obs_var = obs_var[tspan]
    jl_dat = jl_dat[tspan, 1, 1, 1]
    ml_dat = ml_dat[tspan]
    obs_var_n, obs_σ_n, ml_dat_n = filter_common_nan(obs_var, obs_σ, ml_dat)
    obs_var_n, obs_σ_n, jl_dat_n = filter_common_nan(obs_var, obs_σ, jl_dat)
    metr_def = loss(obs_var_n, obs_σ_n, ml_dat_n, lossMetric)
    metr_opt = loss(obs_var_n, obs_σ_n, jl_dat_n, lossMetric)
    plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65)
    plot!(xdata, ml_dat, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=3, label="matlab ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(v) -> $(valToSymbol(lossMetric))")
    plot!(xdata, jl_dat; label="julia ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
    savefig("examples/exp_WROASTED/tmp_figs_comparison/wroasted_$(domain)_$(v).png")
end
# end
# end