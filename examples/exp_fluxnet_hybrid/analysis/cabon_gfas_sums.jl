using YAXArrays
using Statistics
using DimensionalData
using Rasters
using Rasters.Lookups
# using NCDatasets
using NetCDF
using Proj
using JLD2
using Dates

## create area mask 
# xdim = X(Projected(0:0.1:359.9; sampling=Intervals(Start()), crs=EPSG(4326)))
# ydim = Y(Projected(89.9:-0.1:-90; sampling=Intervals(Start()), crs=EPSG(4326)))
# myraster = rand(xdim, ydim)
# area_mask = cellarea(myraster)
# area_mask = area_mask.data

# ? load files!

# sum_gfas_co2_cat = []
# for _year in 2003:2022
#     path_gfas = "/Net/Groups/data_BGC/gfas/0d10_daily/co2fire/$_year"
#     gfas_files = readdir(path_gfas)
#     for gfas_file in gfas_files
#         yax_one = Cube(joinpath(path_gfas, gfas_file))
#         _sum_gfas = mapslices(x -> sum(skipmissing(x .* area_mask * 86400)), yax_one,
#             dims=("longitude", "latitude"))
#         push!(sum_gfas_co2_cat, _sum_gfas)
#         @info gfas_file
#     end
# end

# sum_gfas_co2_cat = reduce(vcat, sum_gfas_co2_cat)
# jldsave("co2_global.jld2"; co2_global=sum_gfas_co2_cat)
sum_gfas_co2_cat = JLD2.load("co2_global.jld2", "co2_global")
sum_gfas_co2_cat = DimArray(sum_gfas_co2_cat, (Ti(DateTime("2003-01-01"):Day(1):DateTime("2022-12-31")),))

sum_gfas_year = groupby(sum_gfas_co2_cat, Ti=>year)
# sum_gfas_year = groupby(sum_gfas_co2_cat, Dim{:time}=>year)
gfas_years = sum.(sum_gfas_year)


fig, ax, plt = barplot(gfas_years ./ 10^9; color=:grey15, #? Mt C (megatonnes of carbon)
    axis=(; ytickformat=values -> ["$(round(value, digits=1))M t" for value in values]),
    figure=(; size=(1200, 400)))
ax.xticks = 2003:2022
ax.title = "Annual CO2 emissions, GFAS"
save("co2_w_gfas_Mt_yearly.png", fig)

fig, ax, plt = barplot(gfas_years ./ 10^9; color=:grey15, #? Mt C (megatonnes of carbon)
    axis=(; ytickformat=values -> ["$(round(value/1000, digits=1))B t" for value in values]),
    figure=(; size=(1200, 400)))
ax.xticks = 2003:2022
ax.title = "Annual CO2 emissions, GFAS"
save("co2_w_gfas_Bt_yearly.png", fig)

# see: https://ourworldindata.org/grapher/annual-carbon-dioxide-emissions

fig, ax, plt = barplot(gfas_years ./ 10^9; color=:grey15, #? Mt C (megatonnes of carbon)
    axis=(; ytickformat=values -> ["$(round(value/1000/(44/12), digits=1))Pg C" for value in values]),
    figure=(; size=(1200, 400)))
ax.xticks = 2003:2022
ax.title = "Annual CO2 emissions, GFAS"
save("co2_w_gfas_Pg_yearly.png", fig)