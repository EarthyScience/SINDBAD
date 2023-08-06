using Revise
# using YAXArrays
using Sindbad
using ForwardSindbad

Sindbad.noStackTrace()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);

obs_array = getKeyedArray(observations);

forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepTEM(forcing, info);

@time TEM!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
# @profview TEM!(output_array, info.tem.models.forward, forcing_nt_array info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one)

@time output_default = runExperimentForward(experiment_json);
@time out_params = runExperimentOpti(experiment_json);

# @benchmark TEM!(output_array, output.land_init, info.tem.models.forward, forcing_nt_array info.tem)
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
