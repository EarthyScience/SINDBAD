using Revise 
using YAXArrays
using Sindbad
using ForwardSindbad
using HybridSindbad
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
dsPath = "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_forcing.zarr/";
# dsPath = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
forcing = HybridSindbad.getForcing(info, dsPath, Val{:zarr}());
ds = YAXArrays.open_dataset(zopen(dsPath));

chunkeddata = setchunks.(forcing.data, ((site=1,),));

forcing = (; forcing..., data = (chunkeddata));

# Sindbad.eval(:(error_catcher = []));

output = ForwardSindbad.setupOutput(info);
# outcubes = runEcosystem(info.tem.models.forward, forcing, output.land_init, info.tem, output.dims);


forc, out = getDataUsingMapCube(forcing, output, info.tem; max_cache=1e9);
# @code_warntype runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
@benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);


for x = 1:4
    println("nomapcube " * string(x))
    @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
end

# for x = 1:4
#     println("deepcopy: nomapcube " * string(x))
#     @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, land_init);
# end

# outcubes=nothing
# @time land_init = createLandInit(info.tem);
# for x = 1:4
#     println("mapcube " * string(x))
#     @time outcubes = mapRunEcosystemArray(forcing, output, info.tem, info.tem.models.forward;
#     max_cache=1e9);
# end

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
