using Revise
using Sindbad
expFile = "exp_modelOrder/settings_modelOrder/experiment.json"


info = getConfiguration(expFile);
Sindbad.eval(:(debugcatcherr = []))
info = setupExperiment(info);


forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend))); 
out = createInitOut(info);

outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
