using Revise 
# using YAXArrays
using Sindbad
using ForwardSindbad
# using OptimizeSindbad
# using HybridSindbad
# using ThreadPools
using AxisKeys
# using Zarr
using BenchmarkTools

# Sindbad.noStackTrace()
experiment_json = "./settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);

forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));

output = setupOutput(info, forcing.sizes);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);


loc_space_maps, land_init_space, f_one  = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

# @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one)
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one)

@time outcubes = runExperimentOpti(experiment_json);  

# @benchmark runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem)
@time runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem)
a=1


# some plots
ds = forcing.data[1];
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
site = 1


plotdat = output.data;
fig, ax, obj = heatmap(plotdat[end][:,1,:])
Colorbar(fig[1,2], obj)
save("gpp.png", fig)

for site in 1:16
    df = DataFrame(time = ds.time, gpp = output.data[end-1][:,1,site], nee = output.data[end][:,1,site], soilw1 = output.data[2][:,1,site]);

    for var = (:gpp, :nee, :soilw1)
        d = data(df)*mapping(:time, var)*visual(Lines, linewidth=0.5);

        fig = with_theme(theme_ggplot2(), resolution = (1200,400)) do
            draw(d)
        end
        save("testfig_$(var)_$(site).png", fig)
    end
end

