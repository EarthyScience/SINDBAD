using Revise
using Sinbad
using TypedTables: Table, columntable
using Suppressor

# using ProfileView
# using BenchmarkTools
expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
forcing = getForcing(info);

# info = setupOptimization(info);

doForward = false
if doForward
    out = createInitOut(info);
    outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
    @time outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
end
out = createInitOut(info);
outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
@time outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);


pools = outevolution.pools |> columntable;
fluxes = outevolution.fluxes |> columntable;
cEco = hcat(pools.cEco...)';
using Plots
pyplot()

p = plot()
for i in 1:size(cEco,2)
    plot!(cEco[:,i])
end
p


p1 = plot(snowW, label="opt")


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
observations = getObservation(info); # target observation!!
info = setupOptimization(info);
out = createInitOut(info);
outparams, outdata = optimizeModel(forcing, out, observations,
info.tem, info.optim; maxfevals=10, nspins=1);    

@suppress begin
    outparams, outdata = optimizeModel(forcing, out, observations,
    info.tem, info.optim; maxfevals=10, nspins=1);    
end

if doOptimize
    observations = getObservation(info) # target observation!!
    info = setupOptimization(info)

    out = createInitOut(info);
    outparams, outdata = optimizeModel(forcing, out, observations,
        info.tem, info.optim; maxfevals=10, nspins=1);
    # CSV.write("../data/outparams.csv", outparams)
end
