using Revise
using Sinbad
# using ProfileView
# using BenchmarkTools
expFilejs = "sandbox/test_json/settings_minimal/experiment.json"
local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
expFile = local_root*expFilejs


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
out = createInitOut(info);
forcing = getForcing(info);
obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
out = createInitOut(info);

outevolution = runEcosystem(forcing, out, info.tem; nspins=1);
@time outevolution = runEcosystem(forcing, out, info.tem; nspins=1);

pools = outevolution.pools |> columntable;
fluxes = outevolution.fluxes |> columntable;

using Plots
pyplot()
p1=plot(fluxes.gpp, label="opt")
plot!(observations.gpp, label="obs")


p2 = plot(fluxes.gpp, observations.gpp, seriestype = :scatter)
xlims!(0,16)
ylims!(0, 16)
plot(p1, p2)
cEco = hcat(pools.cEco...)';
Plots._create_backend_figure
p3=plot(cEco[:, 1])
for z in 1:size(cEco, 2)
    println(z)
    plot!(cEco[:, z])
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