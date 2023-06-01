
using YAXArrays
using Sindbad
using ForwardSindbad
using HybridSindbad
using ThreadPools
using Zarr
# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
Sindbad.noStackTrace()
experiment_json = "./settings_distri/experimentW.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);

dsPath = "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_forcing.zarr/";
# dsPath = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
forcing = getForcing(info, dsPath, Val{:zarr}());
ds = YAXArrays.open_dataset(zopen(dsPath));

# Sindbad.eval(:(error_catcher = []));

output = ForwardSindbad.setupOutput(info);
# outcubes = runEcosystem(info.tem.models.forward, forcing, output.land_init, info.tem, output.dims);


forc = getKeyedArrayFromYaxArray(forcing);
# @code_warntype runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
# @profview runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
# @benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);

# @time runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);




additionaldims = setdiff(keys(info.tem.helpers.run.loop),[:time])
spacesize = values(info.tem.helpers.run.loop[additionaldims])
space_locs = Iterators.product(Base.OneTo.(spacesize)...) |> collect
approaches = info.tem.models.forward;
tem = info.tem;
ecofunc = x ->  ecoLoc!(output.data, approaches, forc, tem, additionaldims, x)

ecoLoc!(output.data, approaches, forc, tem, additionaldims, 1)
@time Threads.@threads for i = 1:length(space_locs)
    ecoLoc!(output.data, approaches, forc, tem, additionaldims, i)
    # ecofunc(i)
end

fig, ax, obj = heatmap(output.data[end-1])
Colorbar(fig[1,2], obj)
save("gpp.png", fig)

using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
site = 1
for site in 1:16
    df = DataFrame(time = 1:730, gpp = output.data[end-1][:,site], nee = output.data[end][:,site], soilw1 = output.data[2][1,:,site]);

    for var = (:gpp, :nee, :soilw1)
        d = data(df)*mapping(:time, var)*visual(Lines, linewidth=0.5);

        fig = with_theme(theme_ggplot2(), resolution = (1200,400)) do
            draw(d)
        end
        save("testfig_$(var)_$(site).png", fig)
    end
end

# @time _ = pmap(ecofunc, 1:length(space_locs));