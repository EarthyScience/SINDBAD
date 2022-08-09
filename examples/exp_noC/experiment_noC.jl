using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select


expFile = "exp_noC/settings_noC/experiment.json"

# do the full experiment at once based purely on json
run_output = runExperiment(expFile);

# play around with each step 
info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

output = setupOutput(info);

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward, max_cache=info.modelRun.rules.yax_max_cache);

# optimization
observations = getObservation(info, Val(:yaxarray)); 

opt_params = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
    ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
