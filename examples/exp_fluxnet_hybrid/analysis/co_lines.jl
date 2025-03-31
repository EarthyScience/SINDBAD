using JLD2
using GLMakie
using Dates
using DimensionalData

sum_gfas_co2_cat = JLD2.load(joinpath(@__DIR__, "co2_global.jld2"))
sum_gfas_co2_cat = DimArray(sum_gfas_co2_cat["co2_global"], (Ti(DateTime("2003-01-01"):Day(1):DateTime("2022-12-31")),))

sum_gfas_year = groupby(sum_gfas_co2_cat, Ti=>year)
# sum_gfas_year = groupby(sum_gfas_co2_cat, Dim{:time}=>year)
gfas_years = sum.(sum_gfas_year) /10^9 /1000/(44/12)


co2_flux_all = JLD2.load(joinpath(@__DIR__, "co2_global_FixK_ALL.jld2"))
co2_flux_all_s = co2_flux_all["co2_global"]
co2_sum_all = sum(co2_flux_all_s[:, 1:6], dims=2)[2:end]

co2_flux_pft = JLD2.load(joinpath(@__DIR__, "co2_global_FixK_PFT.jld2"))
co2_flux_s_pft = co2_flux_pft["co2_global"]
co2_sum_PFT = sum(co2_flux_s_pft[:, 1:6], dims=2)[2:end]

with_theme(theme_light()) do 
    fig = Figure(; size = (1200, 400))
    ax = Axis(fig[1,1]; ylabel = "Pg C")
    scatterlines!(ax, 2003 .. 2022, gfas_years.data; label = "GFAS",
        markersize = 15, color = :black)
    scatterlines!(ax, 2003 .. 2022, co2_sum_all; label = "FixK_ALL",
        markercolor=:transparent, color=:orangered,
        markersize = 15, marker = :rect, strokewidth=1.25, strokecolor = :orangered)
    scatterlines!(ax, 2003 .. 2022, co2_sum_PFT; label = "FixK_PFT", color=:dodgerblue,
        marker=:diamond, strokewidth=1.25, strokecolor = :dodgerblue)
    ylims!(ax, 0, 2.5)
    axislegend(; nbanks=3, position=:lt)
    fig
end
save("carbon_comparison.png", current_figure())
