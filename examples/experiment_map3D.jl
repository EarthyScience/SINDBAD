using Revise
using Sinbad
using ProfileView
using BenchmarkTools
using GLMakie
# using Plots
expFile = "sandbox/test_json/settings_minimal/experiment_3D.json";

info = getConfiguration(expFile);
info = setupModel!(info);
out = createInitOut(info);
forcing = getForcing(info);
obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!
# plot(observations.transpiration)
# plot(observations.transpiration_σ)
optimParams = info.opti.optimized_paramaters;
approaches = info.tem.models.forward;
tblParams = getParameters(info.tem.models.forward, info.opti.optimized_paramaters);


# hcat(info.opti.constraints.variables.evapotranspiration.costOptions, info.opti.constraints.variables.transpiration.costOptions)
# initPools = getInitPools(info)
# @show out.pools.soilW
out = createInitOut(info);
# outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
# osp = outsp[1];
# fluxes = osp.fluxes |> columntable;

out = runPrecompute(forcing[1], approaches, out, info.tem.helpers);
outforw = runForward(approaches, forcing, out, info.tem.variables, info.tem.helpers);
# outforw= runEcosystem(approaches, forcing, out, info.tem.variables, info.tem, false; nspins=1);
states = outforw.states |> columntable;
pools = outforw.pools |> columntable;
fluxes = outforw.fluxes |> columntable;
gppD = outforw.gppDemand |> columntable
# using GR
fig = Figure(resolution=(2200, 900))
lines(gppD.AllDemScGPP)


# plot(fluxes.gpp)
# mm(fluxes.gpp)
pprint(outforw)
function mm(dat)
    minn = minimum(dat)
    maxx = maximum(dat)
    @show minn, maxx
end
runEcosystem(approaches, forcing, out, info.tem.variables, info.tem, false; nspins=3);
# @profview runEcosystem(approaches, forcing, out, info.tem.variables, info.tem, false; nspins=3);
# function runEcosystem(selectedModels, forcing, out, modelVars, modelInfo, history=false; nspins=3) # forward run

# @profview outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
@time outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
osp = outsp[1];
pprint(osp)

# @profview outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);
outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);
@time outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);
states = outforw.states |> columntable;
pools = outforw.pools |> columntable;
fluxes = outforw.fluxes |> columntable;
using GR
plot(fluxes.gpp)
cEco = hcat(pools.cEco...)';
plot(cEco[:, 1])
for z in 1:size(cEco, 2)
    println(z)
    plot(cEco[:, z])
end

# outevolution = runEcosystem(approaches, forcing, outsp[1], modelvars, info.tem; nspins=3)

# outfor = runEcosystem(approaches, forcing, out, info.tem.helpers);
#pprint(outsp)

# outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    # obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=1);


for it in 1:10
    @time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1)
end

# outf=columntable(outdata.fluxes)
using GLMakie
fig = Figure(resolution=(2200, 900))
# lines(pools.snowW)
lines(fluxes.gpp)
lines!(fluxes.NEE)
lines!(fluxes.NPP)
# lines!(fluxes.evapotranspiration)
# lines!(observations.evapotranspiration)

