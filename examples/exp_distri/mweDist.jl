using Sindbad
using ForwardSindbad
using HybridSindbad
using YAXArrays

using Distributed
addprocs(7)

@everywhere using Pkg
@everywhere Pkg.activate(".")

@everywhere begin
    using Sindbad
    using ForwardSindbad
    using HybridSindbad
end

# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
experiment_json = "./settings_optiSpace/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);
ds = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
forcing = getForcing(info, ds, Val{:zarr}());

chunkeddata = setchunks.(forcing.data, ((site=1,),))

forcing = (; forcing..., data = (chunkeddata))

output = setupOutput(info);
GC.gc()
#GC.enable_logging(false)

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward;
    max_cache=1e7);
