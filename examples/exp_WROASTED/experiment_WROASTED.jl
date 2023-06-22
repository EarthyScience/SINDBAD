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
domain = "AU-DaP"
inpath = "../data/fn/$(domain).1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"

obspath = inpath
optimize_it = true
# optimize_it = false
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
    "opti.constraints.oneDataPath" => obspath);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);

info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);

linit = createLandInit(info.pools, info.tem);

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one =
    prepRunEcosystem(output.data,
        output.land_init,
        info.tem.models.forward,
        forc,
        forcing.sizes,
        info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    info.tem,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
land_spin = land_init_space[1];
@time land_spin_now = runSpinup(info.tem.models.forward,
    loc_forcings[1],
    land_spin,
    info.tem.helpers,
    info.tem.spinup,
    info.tem.models,
    typeof(land_spin),
    f_one;
    spinup_forcing=nothing);

tcprint(land_init_space[1])#; c_olor=false, t_ype=false)

@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time outparams = runExperimentOpti(experiment_json; replace_info=replace_info);

tblParams = Sindbad.getParameters(info.tem.models.forward,
    info.optim.default_parameter,
    info.optim.optimized_parameters);
new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams);
output = setupOutput(info);
@time runEcosystem!(output.data,
    new_models,
    forc,
    info.tem,
    loc_space_names,
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
obsVar = info.optim.variables.obs;
for (vi, v) ∈ enumerate(out_vars)
    def_var = def_dat[vi][tspan, 1, 1, 1]
    opt_var = opt_dat[vi][tspan, 1, 1, 1]
    plot(def_var; label="def", size=(900, 600), title=v)
    plot!(opt_var; label="opt")
    if v in obsMod
        obsv = obsVar[findall(obsMod .== v)[1]]
        @show "plot obs", v
        obs_var = getfield(obs, obsv)[tspan, 1, 1, 1]
        plot!(obs_var; label="obs")
        # title(obsv)
    end
    savefig("wroasted_$(domain)_$(v).png")
end

# using JuliaFormatter
# format(".", margin = 100, always_for_in=true, for_in_replacement="∈", format_docstrings=true, yas_style_nesting=true, import_to_using=true, remove_extra_newlines=true)
