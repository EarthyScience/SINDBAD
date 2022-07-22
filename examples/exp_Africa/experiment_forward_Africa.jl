using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select


expFile = "exp_Africa/settings_Africa/experiment.json"

info = getConfiguration(expFile);

info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);


output = setupOutput(info);

@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);

