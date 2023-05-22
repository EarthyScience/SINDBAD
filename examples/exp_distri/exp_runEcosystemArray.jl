using Revise 
using YAXArrays
using Sindbad
using ForwardSindbad
# using OptimizeSindbad
# using HybridSindbad
using ThreadPools
using AxisKeys
# using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
using Zarr
using BenchmarkTools

# using Accessors
# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
# Sindbad.noStackTrace()
experiment_json = "./settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);
# @code_warntype info = setupExperiment(info);

forcing = getForcing(info, Val{:zarr}());

# Sindbad.eval(:(error_catcher = []));

output = setupOutput(info);
forc = getKeyedArrayFromYaxArray(forcing);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);


additionaldims, space_locs, l_init_threads, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds  = prepRunEcosystem(output.data, info.tem.models.forward, forc, info.tem);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, additionaldims, space_locs, l_init_threads, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds)
@profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, additionaldims, space_locs, l_init_threads, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds)

# @benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem)
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem)
a=1
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem)
# @time outcubes = runExperimentForward(experiment_json);  


# @time outcubes = runExperimentOpti(experiment_json);  

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

