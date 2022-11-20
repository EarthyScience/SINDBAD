using Revise 
using YAXArrays
using Sindbad
using ForwardSindbad
using OptimizeSindbad
# using HybridSindbad
using ThreadPools
using AxisKeys
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
using Zarr
using BenchmarkTools

# using Accessors
# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
Sindbad.noStackTrace()
experiment_json = "./settings_distri/experimentW.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);

forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));

output = setupOutput(info);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));

forc, out = getDataUsingMapCube(forcing, output, info.tem; max_cache=1e9);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, info.tem.helpers.run.parallelization);
@time outcubes = runExperimentForward(experiment_json);  


observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
forc, out, obs = getObsUsingMapCube(forcing, output, observations, info.tem; max_cache=1e9);

@time outcubes = runExperimentOpti(experiment_json);  


using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
site = 1
for site in 1:16
    df = DataFrame(time = ds.time, gpp = output.data[end-1][:,site], nee = output.data[end][:,site], soilw1 = output.data[2][1,:,site]);

    for var = (:gpp, :nee, :soilw1)
        d = data(df)*mapping(:time, var)*visual(Lines, linewidth=0.5);

        fig = with_theme(theme_ggplot2(), resolution = (1200,400)) do
            draw(d)
        end
        save("testfig_$(var)_$(site).png", fig)
    end
end
