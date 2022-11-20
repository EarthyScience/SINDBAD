using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
using YAXArrays
# using opti
noStackTrace()

experiment_json = "../exp_usmile/settings_cw/experiment.json"
# experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"

info, forcing, output = prepExperimentForward(experiment_json);
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
forc, out, obs = getObsUsingMapCube(forcing, output, observations, info.tem; max_cache=1e9);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, info.tem.helpers.run.parallelization);
for tt = 1:5
    @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, info.tem.helpers.run.parallelization);
end
@time outcubes = runExperimentForward(experiment_json);  

@time outcubes = runExperimentOpti(experiment_json);  
# outcubes = runExperiment(experiment_json, Val(:forward));







using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

plotdat = output.data
fig, ax, obj = heatmap(plotdat[end])
Colorbar(fig[1,2], obj)
save("gpp.png", fig)

for site in 1:16
    df = DataFrame(time = 1:730, gpp = plotdat[end-1][:,site], nee = plotdat[end][:,site], soilw1 = plotdat[2][1,:,site]);

    for var = (:gpp, :nee, :soilw1)
        d = data(df)*mapping(:time, var)*visual(Lines, linewidth=0.5);

        fig = with_theme(theme_ggplot2(), resolution = (1200,400)) do
            draw(d)
        end
        save("testfig_$(var)_$(site).png", fig)
    end
end