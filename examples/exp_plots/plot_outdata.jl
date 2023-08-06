using Revise
using ForwardDiff

using Sindbad
using ForwardSindbad
using ForwardSindbad: timeLoopForward
using OptimizeSindbad
#using AxisKeys: KeyedArray as KA
#using Lux, Zygote, Optimisers, ComponentArrays, NNlib
#using Random
noStackTrace()
#Random.seed!(7)

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);#; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);

observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArrayWithNames(observations);

@time forcing_nt_array,
output_array,
loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
f_one = prepRunEcosystem(forcing, info);

@time runEcosystem!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

using GLMakie
using Colors
Makie.inline!(false)
lines(1:10)

out_vars = valToSymbol(tem_with_vals.helpers.vals.output_vars)
names_pair = Dict(out_vars .=> 1:4)

var_name = Observable(1)
gpp = @lift(output_array[$var_name]);
s = Observable(9)
gpp_site = @lift($gpp[:, 1, $s])

fig = Figure(; resolution=(1200, 600))
menu = Menu(fig;
    options=out_vars,
    cell_color_hover=RGB(0.7, 0.3, 0.25),
    cell_color_active=RGB(0.2, 0.3, 0.5))
ax = Axis(fig[1, 1])
lines!(ax, gpp_site)

fig[1, 1, TopRight()] = vgrid!(Label(fig, "Variables"; width=nothing, font=:bold, fontsize=18,
        color=:orangered),
    menu;
    tellheight=false,
    width=150,
    valign=:top)
sl = Slider(fig[0, 1]; range=1:10, startvalue=9, color_active_dimmed=RGB(0.81, 0.81, 0.2))
connect!(s, sl.value)
on(menu.selection) do s
    var_name[] = names_pair[s]
    return autolimits!(ax)
end
fig
