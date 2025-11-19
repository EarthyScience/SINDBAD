using CairoMakie
using YAXArrays
using Zarr
using Statistics
using Rasters
using Rasters.Lookups

path_out = "/Net/Groups/BGI/work_4/scratch/lalonso/forward_origin_c16x16_0d25/Global_Seasfire/data/Seasfire_Global_gpp.zarr"
ds_out = open_dataset(path_out)
yax_cfireTotal = ds_out["layer"]

using Proj

xdim = X(Projected(-180:0.25:180-0.25; sampling=Intervals(Start()), crs=EPSG(4326)))
ydim = Y(Projected(90-0.25:-0.25:-90; sampling=Intervals(Start()), crs=EPSG(4326)))
myraster = rand(xdim, ydim)
cs = cellarea(myraster)
area_mask = cs.data

co2_f = yax_cfireTotal[time = DateTime("2003-01-01") .. DateTime("2016-01-01")]

sum_co2 = mapslices(x -> sum(skipmissing(x .* area_mask)), co2_f,
    dims=("longitude", "latitude"))

# 729000000

#! by year
using Dates
sum_co2_year = groupby(sum_co2, Dim{:time}=>year)
sums_years = sum.(sum_co2_year)
# fig = barplot(sums_years)
# save("co2_years.png", fig)
# 
fig, ax, plt = barplot(sums_years; color=:grey15, #? Mt C (megatonnes of carbon) ? diff 1500 Mt C
    axis=(; ytickformat=values -> ["$(round(value, digits=1))" for value in values]),
    figure=(; size=(1200, 400)))
ax.xticks = 2003:2015
ax.title = "gpp yearly SindbadCore.jl"
save("co2_years_gpp_Pg.png", fig)


yax_gpp = ds_out["layer"]

gpp_2010 = yax_gpp[time=DateTime("2010-01-01") .. DateTime("2010-12-31")]
gpp_2010 = readcubedata(gpp_2010)
tstamp = DateTime("2010-01-01")

fig, ax, plt = heatmap(gpp_2010[time = At(tstamp)]; nan_color=:gainsboro,
    colormap=:haline,
    figure=(; size=(1440, 720)))
Colorbar(fig[1,2], plt)
ax.title = "gpp [$(gpp_2010.properties["units"])] $(tstamp)"
save("map_gpp_$(tstamp).png", fig)

sum_gpp = mapslices(x -> sum(skipmissing(x .* area_mask)), gpp_2010,
    dims=("longitude", "latitude"))

sum(sum_gpp)