using Revise
# using YAXArrays
using SindbadTEM
using SindbadExperiment
toggleStackTraceNT()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

obs_array = observations.data;

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_types = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_types)

@time output_default = runExperimentForward(experiment_json);
@time out_params = runExperimentOpti(experiment_json);

a = 1

# some plots
using CairoMakie, AlgebraOfGraphics, DataFrames, Dates
site = 1

plotdat = output_array;
fig, ax, obj = CairoMakie.heatmap(plotdat[end][:, 1, :])
Colorbar(fig[1, 2], obj)
save(joinpath(info.output.figure, "gpp.png"), fig)

for site ∈ 1:16
    df = DataFrame(;
        time=info.tem.helpers.dates.range,
        gpp=output_array[end-1][:, 1, site],
        nee=output_array[end][:, 1, site],
        soilw1=output_array[2][:, 1, site])

    for var ∈ (:gpp, :nee, :soilw1)
        d = data(df) * mapping(:time, var) * visual(Lines; linewidth=0.5)

        fig = with_theme(theme_ggplot2(); resolution=(1200, 400)) do
            return draw(d)
        end
        save(joinpath(info.output.figure, "testfig_$(var)_$(site).png"), fig)
    end
end
