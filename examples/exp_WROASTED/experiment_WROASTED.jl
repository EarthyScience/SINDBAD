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
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.catch_model_errors" => true,
    "model_run.flags.run_spinup" => false,
    "model_run.flags.debug_model" => false,
    "model_run.rules.model_array_type" => arraymethod,
    "model_run.flags.spinup.do_spinup" => true,
    "forcing.default_forcing.data_path" => inpath,
    "model_run.output.path" => outpath,
    "model_run.mapping.parallelization" => pl,
    "optimization.constraints.default_constraint.data_path" => obspath);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info

tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

info, forcing = getForcing(info, Val(Symbol(info.model_run.rules.data_backend)));

# mtup = Tuple([(nameof.(typeof.(info.tem.models.forward))..., info.tem.models.forward...)]);
# tcprint(mtup)

forc = getKeyedArrayFromYaxArray(forcing);
output = setupOutput(info);

linit = createLandInit(info.pools, info.tem.helpers, info.tem.models);


loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output,
        forc,
        info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

res_vec_space = [Vector{typeof(land_init_space[1])}(undef, tem_with_vals.helpers.dates.size) for _ ∈ 1:length(loc_space_inds)];

@time runEcosystem(info.tem.models.forward,
    res_vec_space,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    land_init_space,
    f_one);

# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one)
land_spin = land_init_space[1];
@time land_spin_now = runSpinup(info.tem.models.forward,
    loc_forcings[1],
    land_spin,
    tem_with_vals.helpers,
    tem_with_vals.spinup,
    tem_with_vals.models,
    typeof(land_spin),
    f_one;
    spinup_forcing=nothing);

tcprint(land_init_space[1])#; c_olor=false, t_ype=false)

@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info);

observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)));
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
tspan = 9000:12000
obsMod = last.(values(info.optim.variables.optim))
costOpt = info.optim.cost_options;
foreach(costOpt) do var_row
    v = var_row.variable
    def_var = def_dat[var_row.mod_ind][tspan, 1, 1, 1]
    opt_var = opt_dat[var_row.mod_ind][tspan, 1, 1, 1]
    plot(def_var; label="def", size=(1200, 900), title=v)
    plot!(opt_var; label="opt")
    @show "plot obs", v
    obs_var = obs[var_row.obs_ind][tspan, 1, 1, 1]
    plot!(obs_var; label="obs")
    savefig("wroasted_$(domain)_$(v).png")
end

# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
