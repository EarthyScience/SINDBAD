using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using Plots
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"

domain = "DE-RuS"
# domain = "MY-PSO"
path_input = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

path_observation = path_input
optimize_it = true
# optimize_it = false
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

forcing = getForcing(info);

forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepTEM(forcing, info);

@time TEM!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

@time output_default = runExperimentForward(experiment_json; replace_info=replace_info);

observations = getObservation(info, forcing.helpers);
obs_array = getArray(observations);
@time getLossVector(obs_array, output_default, info.optim.cost_options)

@time opt_params = runExperimentOpti(experiment_json; replace_info=replace_info);

optimized_models = info.tem.models.forward;

if getBool(info.tem.helpers.run.run_optimization)
    tbl_params = Sindbad.getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)
    optimized_models = updateModelParameters(tbl_params, info.tem.models.forward, opt_params)
end

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

@time TEM!(output_array,
    optimized_models,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# some plots
ds = forcing.data[1];
opt_dat = output_array;
def_dat = output_default;
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
    (obs_var, obs_σ, def_var) = getData(def_dat, obs_array, var_row)
    (_, _, opt_var) = getData(opt_dat, obs_array, var_row)
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
