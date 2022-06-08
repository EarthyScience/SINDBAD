using Revise
using Sinbad

expFilejs = "settings_minimal/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));

out = createInitOut(info);
outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
@profview outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
