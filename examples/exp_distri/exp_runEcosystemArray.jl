using Revise
# using YAXArrays
using Sindbad
using ForwardSindbad

Sindbad.noStackTrace()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);

info, forcing = getForcing(info);
observations = getObservation(info);
output = setupOutput(info);
forc = getKeyedArrayWithNames(forcing);
obs = getKeyedArray(observations);

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output, forc, info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one)

@time outcubes = runExperimentForward(experiment_json);
@time outcubes = runExperimentOpti(experiment_json);

# @benchmark runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem)
a = 1

# some plots
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
site = 1

plotdat = output.data;
fig, ax, obj = CairoMakie.heatmap(plotdat[end][:, 1, :])
Colorbar(fig[1, 2], obj)
save(joinpath(info.output.figure, "gpp.png"), fig)

for site ∈ 1:16
    df = DataFrame(;
        time=info.tem.helpers.dates.vector,
        gpp=output.data[end-1][:, 1, site],
        nee=output.data[end][:, 1, site],
        soilw1=output.data[2][:, 1, site])

    for var ∈ (:gpp, :nee, :soilw1)
        d = data(df) * mapping(:time, var) * visual(Lines; linewidth=0.5)

        fig = with_theme(theme_ggplot2(); resolution=(1200, 400)) do
            return draw(d)
        end
        save(joinpath(info.output.figure, "testfig_$(var)_$(site).png"), fig)
    end
end
