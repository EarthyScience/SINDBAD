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
domain = "FI-Sod"
inpath = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

obspath = inpath
optimize_it = true
optimize_it = false
outpath = nothing

pl = "threads"
arraymethod = "staticarray"
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => false,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.catch_model_errors" => true,
    "model_run.flags.run_spinup" => false,
    "model_run.flags.debug_model" => false,
    "model_run.rules.model_array_type" => arraymethod,
    "model_run.flags.spinup.do_spinup" => true,
    "forcing.default_forcing.data_path" => inpath,
    "model_run.output.path" => outpath,
    "model_run.output.output_array_type" => "array",
    "model_run.mapping.parallelization" => pl,
    "optimization.constraints.default_constraint.data_path" => obspath);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info

nrepeat = 200

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
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d < 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleAH", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d == 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
    ]
elseif nrepeat_d > 0
    sequence = [
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat),
        Dict("spinup_mode" => "ηScaleA0H", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => 1),
        Dict("spinup_mode" => "spinup", "forcing" => "recycleMSC", "stop_function" => nothing, "n_repeat" => nrepeat_d),
    ]
else
    error("cannot determine the repeat for disturbance")
end
replace_info["model_run.spinup.sequence"] = sequence
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info

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

# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one)
# land_spin = land_init_space[1];
# @time land_spin_now = runSpinup(info.tem.models.forward,
#     loc_forcings[1],
#     land_spin,
#     tem_with_vals.helpers,
#     tem_with_vals.spinup,
#     tem_with_vals.models,
#     typeof(land_spin),
#     f_one;
#     spinup_forcing=nothing);


out_vars = output.variables;
for (o, v) in enumerate(out_vars)
    def_var = output.data[o][:, :, 1, 1]
    xdata = [info.tem.helpers.dates.vector...]
    if size(def_var, 2) == 1
        plot(xdata, def_var[:, 1]; label="def ($(round(ForwardSindbad.mean(def_var[:, 1]), digits=2)))", size=(1200, 900), title="$(v)")
        savefig(joinpath(info.output.figure, "dbg_wroasted_$(domain)_$(v).png"))
    else
        for ll ∈ 1:size(def_var, 2)
            plot(xdata, def_var[:, ll]; label="def ($(round(ForwardSindbad.mean(def_var[:, ll]), digits=2)))", size=(1200, 900), title="$(v)")
            savefig(joinpath(info.output.figure, "dbg_wroasted_$(domain)_$(v)_$(ll).png"))
        end
    end

end


# using JuliaFormatter
# format(".", MinimalStyle(), margin=100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true, trailing_comma=false)
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
