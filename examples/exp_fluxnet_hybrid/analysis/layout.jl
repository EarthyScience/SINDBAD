# function plotOutput(out_names)

#     fig = Figure(; size=(1200, 600))
#     menu = Menu(fig;
#         options=out_names,
#         cell_color_hover=RGB(0.7, 0.3, 0.25),
#         cell_color_active=RGB(0.2, 0.3, 0.5))

#     ax = Axis(fig[1, 1];
#         ytickalign=1, xtickalign=1,
#         yticksize =10, xticksize=10,
#         xgridstyle = :dashdot,
#         ygridstyle = :dashdot)

#     plt = lines!(ax, 1:10)

#     fig[1, 2] = vgrid!(Label(fig, "Variables"; width=nothing, font=:bold, fontsize=18, color=:orangered),
#         menu;
#         tellheight=false,
#         width=150,
#         valign=:top)
#     fig
# end

# plotOutput(_name_variables)