using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
using JSONTables, CSV

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
rdback = CSV.File("./data/outparams.csv");
rdbackparams = Table(rdback)