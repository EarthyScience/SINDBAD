using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select

expFilejs = "exp_Africa/settings_Africa/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);


output = setupOutput(info);

@time outcubes = mapRunEcosystem(forcing, output, info.tem);

