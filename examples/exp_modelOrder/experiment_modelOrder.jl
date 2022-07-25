using Revise
using Sindbad
expFile = "exp_modelOrder/settings_modelOrder/experiment.json"


info = getConfiguration(expFile);
info = setupExperiment(info);


forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
spinup_forcing = getSpinupForcing(forcing, info.tem);

observations = getObservation(info); 
out = createInitOut(info);

outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
