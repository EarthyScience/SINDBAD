using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using ForwardDiff
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "2005"
eYear = "2015"

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
inpath = "../data/DE-2.1979.2017.daily.nc"
forcingConfig = "forcing_DE-2.json"
# inpath = "../data/BE-Vie.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
inpath = "../data/DE-Hai.1979.2017.daily.nc"
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
    "modelRun.time.eDate" => eYear * "-01-02",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "spinup.flags.saveSpinup" => false,
    "modelRun.flags.catchErrors" => true,
    "modelRun.flags.runSpinup" => true,
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
forc = getKeyedArrayFromYaxArray(forcing);
linit= createLandInit(info.pools, info.tem);

output = setupOutput(info);

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one);
a=1

## do the dual and remake output
dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.numType}.(tblParams.defaults);
newmods = updateModelParametersType(tblParams, mods, dualDefs);


loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, newmods, forc, forcing.sizes, info.tem);
new_op_dat = [typeof(opd[1]).(opd) for opd in output.data];
output = (; output..., data = new_op_dat);
## get typed outputs
loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, land_init_space[1], newmods, forc, forcing.sizes, info.tem);


@time runEcosystem!(output.data, newmods, forc, info.tem, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one);

# @time outcubes = runExperimentOpti(experiment_json);  
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);


function lloss(x, mods, forc, op, op_vars, obs, tblParams, info_tem, info_optim, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
    l = getLossGradient(x, mods, forc, op, op_vars, obs, tblParams, info_tem, info_optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
    pprint("params:")
    @show " "
    pprint(x)
    @show " "
    pprint("loss")
    pprint(l)
    l
end


rand_m = rand(info.tem.helpers.numbers.numType);
op = output;
mods = info.tem.models.forward;

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);


lloss(tblParams.defaults .* rand_m, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
lloss(tblParams.defaults, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
l1(p) = lloss(p, mods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,land_init_space, f_one)

dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.numType}.(tblParams.defaults);
newmods = updateModelParametersType(tblParams, mods, dualDefs);
l2(p) = lloss(p, newmods, forc, op, op.variables, obs, tblParams, info.tem, info.optim, loc_space_names, loc_space_inds, loc_forcings, loc_outputs,land_init_space, f_one)

l1(tblParams.defaults .* rand_m);
l2(tblParams.defaults .* rand_m);


@time grad = ForwardDiff.gradient(l1, tblParams.defaults)
@time grad = ForwardDiff.gradient(l2, dualDefs)

