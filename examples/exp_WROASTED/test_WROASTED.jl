using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
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
domain = "DE-Hai"
inpath = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

obspath = inpath
optimize_it = true
# optimize_it = false
outpath = nothing

pl = "threads"
arraymethod = "staticarray"
replace_info = Dict("modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "spinup.flags.saveSpinup" => false,
    "modelRun.flags.catchErrors" => true,
    "modelRun.flags.runSpinup" => false,
    "modelRun.flags.debugit" => false,
    "modelRun.rules.model_array_type" => arraymethod,
    "spinup.flags.doSpinup" => true,
    "forcing.default_forcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl,
    "opti.constraints.oneDataPath" => obspath);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info

tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

# mtup = Tuple([(nameof.(typeof.(info.tem.models.forward))..., info.tem.models.forward...)]);
# tcprint(mtup)

forc = getKeyedArrayFromYaxArray(forcing);
output = setupOutput(info);

linit = createLandInit(info.pools, info.tem.helpers, info.tem.models);


loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one =
    prepRunEcosystem(output,
        forc,
        info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
# obs = getKeyedArrayFromYaxArray(observations);
obs = getObsKeyedArrayFromYaxArray(observations);

@time outparams = runExperimentOpti(experiment_json; replace_info=replace_info);

tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);
new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams);
output = setupOutput(info);
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
using Plots
ds = forcing.data[1];
opt_dat = output.data;
def_dat = outcubes;
out_vars = output.variables;
tspan = 9000:12000
costOpt = info.optim.costOptions;
foreach(costOpt) do var_row
    v = var_row.variable
    @show "plot obs", v
    lossMetric = var_row.costMetric
    loss_name = valToSymbol(lossMetric)
    if loss_name == :nnseinv
        lossMetric = Val(:nse)
    end
    (obs_var, obs_σ, def_var) = getDataArray(def_dat, obs, var_row)
    metr_def = loss(obs_var, obs_σ, def_var, lossMetric)
    (_, _, opt_var) = getDataArray(opt_dat, obs, var_row)
    metr_opt = loss(obs_var, obs_σ, opt_var, lossMetric)
    # @show def_var
    plot(def_var[tspan, 1, 1, 1]; label="def ($(round(metr_def, digits=2)))", size=(1200, 900), title="$(v) -> $(valToSymbol(lossMetric))")
    plot!(opt_var[tspan, 1, 1, 1]; label="opt ($(round(metr_opt, digits=2)))")
    plot!(obs_var[tspan, 1, 1, 1]; label="obs")
    savefig(joinpath(info.output.figure, "wroasted_$(domain)_$(v).png"))
end

# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
