using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using ForwardDiff
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "2000"
eYear = "2017"

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# inpath = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
inpath = "../data/BE-Vie.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
obspath = inpath
optimize_it = false
outpath = nothing

domain = "DE-Hai"
pl = "threads"
replace_info = Dict(
    "modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "spinup.flags.saveSpinup" => false,
    "modelRun.flags.catchErrors" => true,
    "modelRun.flags.runSpinup" => false,
    "modelRun.flags.debugit" => false,
    "modelRun.rules.forward_diff" => true,
    "spinup.flags.doSpinup" => true,
    "forcing.default_forcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl,
    "opti.constraints.oneDataPath" => obspath
);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);

info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
linit= createLandInit(info.pools, info.tem);

loc_space_maps, land_init_space, f_one  = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one)

# @time outcubes = runExperimentOpti(experiment_json);  
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);

# @time outcubes = runExperimentOpti(experiment_json);  
function loss(x, mods, forc, op, op_vars, obs, tblParams, info_tem, info_optim, loc_space_maps, land_init_space, f_one)
    l = getLossGradient(x, mods, forc, op, op_vars, obs, tblParams, info_tem, info_optim, loc_space_maps, land_init_space, f_one)
    @show l
    l
end
rand_m = rand(info.tem.helpers.numbers.numType);
op = setupOutput(info);

mods = info.tem.models.forward;
loss(tblParams.defaults .* rand_m, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_maps, land_init_space, f_one)
loss(tblParams.defaults, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_maps, land_init_space, f_one)


l1(p) = loss(p, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_maps, land_init_space, f_one)
l1(tblParams.defaults)
l1(tblParams.defaults .* rand_m)
@time grad = ForwardDiff.gradient(l1, tblParams.defaults)
