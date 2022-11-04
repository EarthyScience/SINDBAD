using YAXArrays
using Sindbad
using ForwardSindbad
using HybridSindbad
# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
Sindbad.noStackTrace()
experiment_json = "./settings_optiSpace/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);
ds = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
forcing = HybridSindbad.getForcing(info, ds, Val{:zarr}());

chunkeddata = setchunks.(forcing.data, ((site=1,),))

forcing = (; forcing..., data = (chunkeddata))

output = setupOutput(info);
#GC.gc()
#GC.enable_logging(false)
using BenchmarkTools
for x = 1:5
    # GC.gc()
@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward;
    max_cache=1e9);
end

for x = 1:2
@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward;
    max_cache=1e9);
end
a=1





# observations 
observations = HybridSindbad.getObservations(info, Val{:zarr}())
chunkedObs = setchunks.(observations.data, ((site=2,),))
observations = (; observations..., data = (chunkedObs))

#using GLMakie
#series(observations.data[1].data[:,1:4]') 
#obsgpp = observations.data[1]


tblParams = getParameters(info.tem.models.forward)
tblParams.optim .= rand(Float32, length(tblParams.optim)) .* tblParams.optim # update the parameters with pVector
newApproaches = updateParameters(tblParams, info.tem.models.forward);

using Lux, Random
model = Lux.Chain(
        Dense(15, 8, tanh), # 15 -> forcing.data \> length
        Dense(8, 2, x->x^2) # 87 -> tblParams.optim |> length
        )


using Optimisers, Zygote
rng = Random.default_rng()
Random.seed!(rng, 0)
ps, st = Lux.setup(rng, model)

#ps = ps |> Lux.ComponentArray

ŷparam, st = Lux.apply(model, rand(Float32, 15), ps, st)

#tblParams = getParameters(info.tem.models.forward)
#tblParams.optim[1:2] .= ŷparam # update the parameters with pVector
#newApproaches = updateParameters(tblParams, info.tem.models.forward);

#outcubes = mapRunEcosystem(forcing, output, info.tem, newApproaches;
#    max_cache=info.modelRun.rules.yax_max_cache);

ŷ = outcubes[9]
y = observations.data[1]

opt = Optimisers.Adam(0.03)
using Statistics
nanmean(x) = mean(filter(!isnan,x))

function loss_function(model, ps, st, data)
    ŷparam, st = Lux.apply(model, rand(Float32, 15), ps, st)
    tblParams = getParameters(info.tem.models.forward)
    tblParams.optim[1:2] .= ŷparam # update the parameters with pVector
    newApproaches = updateParameters(tblParams, info.tem.models.forward);
    outcubes = mapRunEcosystem(forcing, output, info.tem, newApproaches;
        max_cache=info.modelRun.rules.yax_max_cache)
    ŷ = outcubes[9]
    y = data
    mse_val = nanmean(map((i,j) -> (i + j + sum(ŷparam))^2, y, ŷ).data)
    return mse_val, st, ()
end

y = setchunks(y, (site=8,))

loss_function(model, ps, st, y)


tstate = Lux.Training.TrainState(rng, model, opt)
vjp_rule = Lux.Training.ZygoteVJP()

grads, loss, stats, tstate = Lux.Training.compute_gradients(vjp_rule, loss_function, y, tstate)

#a2 = nanmean(map((i,j) -> (i + j)^2, outcubes[9], observations.data[1]).data)
