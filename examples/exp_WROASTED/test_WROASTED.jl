using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
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
domain = "DE-RuS"
# domain = "MY-PSO"
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
    "forcing.default_forcing.data_path" => path_input,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.catch_model_errors" => false,
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.rules.model_array_type" => arraymethod,
    "model_run.flags.spinup.do_spinup" => true,
    "model_run.output.path" => path_output,
    "model_run.output.format" => "nc",
    "model_run.output.save_single_file" => true,
    "model_run.mapping.parallelization" => pl,
    "optimization.algorithm" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.constraints.default_constraint.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

# tblParams = Sindbad.getParameters(info.tem.models.forward,
#     info.optim.default_parameter,
#     info.optim.optimized_parameters);

info, forcing = getForcing(info);

# mtup = Tuple([(nameof.(typeof.(info.tem.models.forward))..., info.tem.models.forward...)]);
# tcprint(mtup)

forc = getKeyedArrayWithNames(forcing);
output = setupOutput(info);

linit = createLandInit(info.pools, info.tem.helpers, info.tem.models);



loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output,
        forc,
        info.tem);


# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one)

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



observations = getObservation(info);
# obs = getKeyedArrayWithNames(observations);
obs = getArray(observations);
@time getLossVectorArray(obs, output.data, info.optim.cost_options)

@time outparams = runExperimentOpti(experiment_json; replace_info=replace_info);

new_models = info.tem.models.forward;

if info.tem.helpers.run.run_optimization
    tblParams = Sindbad.getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)
    new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams)
end

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

# tblParams = Sindbad.getParameters(info.tem.models.forward,
#     info.optim.default_parameter,
#     info.optim.optimized_parameters);

info, forcing = getForcing(info);

# mtup = Tuple([(nameof.(typeof.(info.tem.models.forward))..., info.tem.models.forward...)]);
# tcprint(mtup)

forc = getKeyedArrayWithNames(forcing);
output = setupOutput(info);
@time runEcosystem!(output.data,
    new_models,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# some plots
using Plots
ds = forcing.data[1];
opt_dat = output.data;
def_dat = outcubes;
out_vars = output.variables;
costOpt = info.optim.cost_options;
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
foreach(costOpt) do var_row
    v = var_row.variable
    @show "plot obs", v
    v = (var_row.mod_field, var_row.mod_subfield)
    vinfo = getVariableInfo(v, info.model_run.time.model_time_step)
    v = vinfo["standard_name"]
    lossMetric = var_row.cost_metric
    loss_name = valToSymbol(lossMetric)
    if loss_name in (:nnseinv, :nseinv)
        lossMetric = Val(:nse)
    end
    (obs_var, obs_σ, def_var) = getDataArray(def_dat, obs, var_row)
    (_, _, opt_var) = getDataArray(opt_dat, obs, var_row)
    obs_var_TMP = obs_var[:, 1, 1, 1]
    non_nan_index = findall(x -> !isnan(x), obs_var_TMP)
    if length(non_nan_index) < 2
        tspan = 1:length(obs_var_TMP)
    else
        tspan = first(non_nan_index):last(non_nan_index)
    end
    obs_σ = obs_σ[tspan]
    obs_var = obs_var[tspan]
    def_var = def_var[tspan, 1, 1, 1]
    opt_var = opt_var[tspan, 1, 1, 1]

    xdata = [info.tem.helpers.dates.range[tspan]...]
    obs_var_n, obs_σ_n, def_var_n = filterCommonNaN(obs_var, obs_σ, def_var)
    obs_var_n, obs_σ_n, opt_var_n = filterCommonNaN(obs_var, obs_σ, opt_var)
    metr_def = loss(obs_var_n, obs_σ_n, def_var_n, lossMetric)
    metr_opt = loss(obs_var_n, obs_σ_n, opt_var_n, lossMetric)
    plot(xdata, obs_var; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)
    plot!(xdata, def_var, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=3, label="def ($(round(metr_def, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(valToSymbol(lossMetric))")
    plot!(xdata, opt_var; label="opt ($(round(metr_opt, digits=2)))", lw=1.5, ls=:dash)
    savefig(joinpath(info.output.figure, "wroasted_$(domain)_$(v).png"))
end
# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
