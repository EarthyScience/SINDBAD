using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
using JSONTables, CSV
import JSON3
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

originTable = getParameters(info.tem.models.forward);
prm = CSV.File("./data/optimized_Params_FLUXNET_pcmaes_FLUXNET2015_daily_BE-Vie.csv");
prmt = Table(prm)

optTable = setoptparameters(originTable, prmt);
#optTable.optim == originTable.optim

newApproaches = updateParameters(optTable, approaches);
out = createInitOut(info);

doutevolution = runEcosystem(approaches, forcing, out, info.tem.variables, info.tem; nspins=1)
outevolution = runEcosystem(newApproaches, forcing, out, info.tem.variables, info.tem; nspins=1)

pools = outevolution.pools |> columntable;
fluxes = outevolution.fluxes |> columntable;
dfluxes = doutevolution.fluxes |> columntable;

using Plots
pyplot()
p1=plot(fluxes.gpp, label="opt")
plot!(dfluxes.gpp, label="def")
plot!(observations.gpp, label="obs")


p2 = plot(fluxes.gpp, observations.gpp, seriestype = :scatter)
xlims!(0,16)
ylims!(0, 16)
plot(p1, p2)
cEco = hcat(pools.cEco...)';
plot(cEco[:, 1])
for z in 1:size(cEco, 2)
    println(z)
    plot(cEco[:, z])
end

outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=10, lossym=(:mse, :cor));

CSV.write("./data/outparams.csv", outparams)

#readin back!
rdback = CSV.File("./data/outparams.csv")
rdbackparams = Table(rdback)


jsformat = JSONTables.objecttable(outparams)
open("./data/test_table.json", "w") do io
    JSON3.pretty(io, jsformat)
end
json_string = read("./data/test_table.json", String)
rdjs = JSON3.read(json_string)
tableback = Table((; zip(keys(rdjs), values(rdjs))...))