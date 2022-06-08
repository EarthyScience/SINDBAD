using Revise
using Sinbad
using Suppressor

expFilejs = "settings_minimal/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);
info = setupModel!(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));

observations = getObservation(info); 
info = setupOptimization(info);
out = createInitOut(info);
outparams, outdata = optimizeModel(forcing, out, observations,
info.tem, info.optim; nspins=1);    
