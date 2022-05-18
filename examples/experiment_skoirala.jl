using Revise
using Sinbad
using TypedTables: Table
# using ProfileView
# using BenchmarkTools
expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
forcing = getForcing(info);



out = createInitOut(info);
outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
@time outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);


doPlot = false

if doPlot
    pools = outevolution.pools |> columntable
    fluxes = outevolution.fluxes |> columntable
    snowW = hcat(pools.snowW...)'


    using Plots
    pyplot()
    p1 = plot(snowW, label="opt")
end


doOptimize = true
if doOptimize
    observations = getObservation(info) # target observation!!
    info = setupOptimization(info)

    out = createInitOut(info)
    outparams, outdata = optimizeModel(forcing, out, observations,
        info.tem, info.optim; maxfevals=10, nspins=1);
    # CSV.write("../data/outparams.csv", outparams)
end
