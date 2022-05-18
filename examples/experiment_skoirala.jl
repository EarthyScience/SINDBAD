using Revise
using Sinbad
using TypedTables: Table, columntable
using Suppressor
using PrettyPrinting

# using ProfileView
# using BenchmarkTools
expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
forcing = getForcing(info);
selTime = 1:13650;
# forcing=forcing[selTime];

# info = setupOptimization(info);

# doForward = false
# if doForward
#     out = createInitOut(info);
#     outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
#     @time outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
# end
# for i = 1:10
#     out = createInitOut(info);
#     @time out = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
# end
# out = createInitOut(info);
# outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
# @profview outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);


# pools = outevolution.pools |> columntable;
# fluxes = outevolution.fluxes |> columntable;
# cEco = hcat(pools.cEco...)';
# using Plots
# pyplot()

# p = plot()
# for i in 1:size(cEco,2)
#     plot!(cEco[:,i])
# end
# p


# p1 = plot(snowW, label="opt")


# doPlot = false

# if doPlot
#     pools = outevolution.pools |> columntable
#     fluxes = outevolution.fluxes |> columntable
#     snowW = hcat(pools.snowW...)'
#     using Plots
#     pyplot()
#     p1 = plot(snowW, label="opt")
# end


doOptimize = true
observations = getObservation(info); # target observation!!
# observations=observations[selTime]
info = setupOptimization(info);
out = createInitOut(info);
outparams, outdata = optimizeModel(forcing, out, observations,
info.tem, info.optim; maxfevals=10, nspins=1);    

# @suppress begin
#     outparams, outdata = optimizeModel(forcing, out, observations,
#     info.tem, info.optim; maxfevals=10, nspins=1);    
# end

# if doOptimize
#     observations = getObservation(info) # target observation!!
#     info = setupOptimization(info)

#     out = createInitOut(info);
#     outparams, outdata = optimizeModel(forcing, out, observations,
#         info.tem, info.optim; maxfevals=10, nspins=1);
#     # CSV.write("../data/outparams.csv", outparams)
# end
# using ProfileView
# using BenchmarkTools
#using GLMakie
expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root,expFilejs)

expFile = "sandbox/test_json/settings_minimal/experiment.json"

info = getConfiguration(expFile);
info = setupModel!(info);
out = createInitOut(info);
forcing = getForcing(info);
obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);


# hcat(info.opti.constraints.variables.evapotranspiration.costOptions, info.opti.constraints.variables.transpiration.costOptions)
# initPools = getInitPools(info)
# @show out.pools.soilW

outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=3);
osp = outsp[1];
pprint(osp)
@time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);

@time outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);
pools = outforw.pools |> columntable
fluxes = outforw.fluxes |> columntable

pprint(info.opti)

# outevolution = runEcosystem(approaches, forcing, outsp[1], modelvars, info.tem; nspins=3)

# outfor = runEcosystem(approaches, forcing, out, info.tem.helpers);
#pprint(outsp)

# outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    # obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=1);


# for it in 1:10
#     @time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=4)
# end

# outf=columntable(outdata.fluxes)
using GLMakie
fig = Figure(resolution=(2200, 900))
# lines(pools.snowW)
lines(fluxes.gpp)
lines!(fluxes.NEE)
lines!(fluxes.NPP)
# lines!(fluxes.evapotranspiration)
# lines!(observations.evapotranspiration)

