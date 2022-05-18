using Revise
using Sinbad
using CSV
# using ProfileView
# using BenchmarkTools
expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root,expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
forcing = getForcing(info);


out = createInitOut(info);
outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
@time outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);


doPlot = false

if doPlot
    pools = outevolution.pools |> columntable;
    fluxes = outevolution.fluxes |> columntable;
    snowW = hcat(pools.snowW...)';


    using Plots
    pyplot()
    p1=plot(snowW, label="opt")
end
    # plot!(observations.gpp, label="obs")


doOptimize=true
if doOptimize
    obsVars, optimVars, storeVars = getConstraintNames(info.opti, info.modelRun.output.variables.store);
    observations = getObservation(info); # target observation!!

    optimParams = info.opti.params2opti;
    out = createInitOut(info);
    outparams, outdata = optimizeModel(forcing, out, observations,
        obsVars, optimVars, info.tem, info.opti; maxfevals=10, nspins=1);
    CSV.write("../data/outparams.csv", outparams)
end
