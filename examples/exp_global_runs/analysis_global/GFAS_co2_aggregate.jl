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

# create area mask 
xdim = X(Projected(0:0.1:359.9; sampling=Intervals(Start()), crs=EPSG(4326)))
ydim = Y(Projected(89.9:-0.1:-90; sampling=Intervals(Start()), crs=EPSG(4326)))
myraster = rand(xdim, ydim)
area_mask = cellarea(myraster)
area_mask = area_mask.data

# ? load files!

path_gfas = "/Net/Groups/data_BGC/gfas/0d10_daily/co2fire/2003/"
gfas_files = readdir(path_gfas)

sum_gfas_co2_cat = []
for _year in 2003:2022
    path_gfas = "/Net/Groups/data_BGC/gfas/0d10_daily/co2fire/$_year"
    gfas_files = readdir(path_gfas)
    for gfas_file in gfas_files
        yax_one = Cube(joinpath(path_gfas, gfas_file))
        _sum_gfas = mapslices(x -> sum(skipmissing(x .* area_mask * 24 * 60 * 60)), yax_one,
            dims=("longitude", "latitude"))
        push!(sum_gfas_co2_cat, _sum_gfas)
        @info gfas_file
    end
end

# sum_gfas_co2_cat = reduce(vcat, sum_gfas_co2_cat)
# jldsave("co2_global.jld2"; co2_global=sum_gfas_co2_cat)