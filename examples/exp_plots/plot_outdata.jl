using Revise
using Sindbad
using Plots

toggleStackTraceNT()

experiment_json = "../exp_plots/settings_plots/experiment.json"
@time output_default = runExperimentForward(experiment_json);

using GLMakie
using Colors
Makie.inline!(false)
lines(1:10)

output_vars = valToSymbol(output_default.info.output.variables)
names_pair = Dict(output_vars .=> 1:4)

var_name = Observable(1)
gpp = @lift(output_default.output[$var_name]);
s = Observable(9)
gpp_site = @lift($gpp[:, 1, $s])

fig = Figure(; resolution=(1200, 600))
menu = Menu(fig;
    options=output_vars,
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
