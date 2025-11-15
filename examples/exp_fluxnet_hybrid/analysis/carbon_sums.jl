using CairoMakie
using YAXArrays
using Zarr
using Statistics
using Rasters
using Rasters.Lookups

# path_out = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_pfts_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cFireTotal.zarr"
# all covs
#path_out = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_ALL_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cFireTotal.zarr"
path_out = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_pfts_2003_2015_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cFireTotal.zarr"

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

# fig = lines(sum_co2) #?  gC  (grams of carbon)
# save("co2_w.png", fig)

# fig = lines(sum_co2 ./ 10^12) #? Mt C (megatonnes of carbon)
# save("co2_w_Mt.png", fig)

#! by year
using Dates
sum_co2_year = groupby(sum_co2, Dim{:time}=>year)
sums_years = sum.(sum_co2_year)

# fig = barplot(sums_years)
# save("co2_years.png", fig)
# 
fig, ax, plt = barplot(sums_years ./ 10^15; color=:grey15, #? diff 1500 Mt C
    axis=(; ytickformat=values -> ["$(round(value, digits=1))Pg" for value in values]),
    figure=(; size=(1200, 400)))
# ax.xticks = 2003:2015
ax.title = "cFireTotal SindbadCore.jl"
save("co2_rates_2003_2016_factor_Pg.png", fig)

using JLD2
sum_gfas_co2_cat = JLD2.load("co2_global.jld2", "co2_global")
sum_gfas_co2_cat = DimArray(sum_gfas_co2_cat, (Ti(DateTime("2003-01-01"):Day(1):DateTime("2022-12-31")),))

sum_gfas_year = groupby(sum_gfas_co2_cat, Ti=>year)
# sum_gfas_year = groupby(sum_gfas_co2_cat, Dim{:time}=>year)
gfas_years = sum.(sum_gfas_year)

elem_1 = [LineElement(color = :grey15, linestyle = nothing),
          MarkerElement(color = :grey15, marker=:circ, markersize = 15,
          strokecolor = :grey15)]
elem_2 = [LineElement(color = :orangered, linestyle = nothing),
    MarkerElement(color = :orangered, markersize = 15, marker=:circ,
    strokecolor = :orangered)]

fig, ax, plt = scatterlines(gfas_years./10^9 /1000/(44/12); color=:grey15, #? diff 1500 Mt C
    # label = "CAMS",
    axis=(; ytickformat=values -> ["$(round(value, digits=1))Pg" for value in values]),
    figure=(; size=(1200, 400)))
scatterlines!(ax, sums_years[2:end] ./ 10^15; color=:orangered)
Legend(fig[1, 1],
    [elem_1, elem_2],
    ["CAMS", "TEM-HyFixK-PFT"],
    tellwidth=false,
    tellhigth=false,
    valign=1,
    halign=1
    #patchsize = (35, 35), rowgap = 10
    )
# ax.xticks = 2003:2015
# ax.title = ""
save("co2_compare_Pg.png", fig)