using Sindbad
using ForwardSindbad
using HybridSindbad
#=
using Distributed
addprocs(3)

@everywhere using Pkg
@everywhere Pkg.activate(".")

@everywhere begin
    using Sindbad
    using ForwardSindbad
    using HybridSindbad
end
=#
# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
experiment_json = "./settings_optiSpace/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);
ds = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
forcing = HybridSindbad.getForcing(info, ds, Val{:zarr}());
output = setupOutput(info);
GC.gc()
GC.enable_logging(true)
outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward;
    max_cache=info.modelRun.rules.yax_max_cache);



gpp = outcubes[9]
gpp.data[:,1]