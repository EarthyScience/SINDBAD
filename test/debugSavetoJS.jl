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