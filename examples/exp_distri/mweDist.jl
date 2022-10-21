using Sindbad
using ForwardSindbad
using HybridSindbad

# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
experiment_json = "./settings_optiSpace/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);

ds = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"

forcing = HybridSindbad.getForcing(info, ds, Val{:zarr}());
output = setupOutput(info);

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward;
    max_cache=info.modelRun.rules.yax_max_cache);