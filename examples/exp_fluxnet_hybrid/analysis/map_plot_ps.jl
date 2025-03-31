using Random
using YAXArrays
using SindbadData.Zarr
using NaNStatistics
# using Rasters, ArchGDAL
# using Rasters.Lookups
using CairoMakie
# using GeoMakie

# ? open parameters
ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_veg_global_025.zarr" 
# ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_veg_global_frac_025.zarr" 

out_params = open_dataset(ps_path)
out_params = out_params["parameters"]

ps_name = "constant_frac_max_root_depth" # "k_extinction"
ds_parameter = readcubedata(out_params[parameter= At(ps_name)])
# extrema
new_ds = replace(x -> ismissing(x) ? NaN : x, ds_parameter)

function find_min_ignore_nan(arr)
    min_value = Inf  # Start with a very large value
    for val in arr
        if !isnan(val) && val < min_value
            min_value = val
        end
    end
    return min_value
end
function find_max_ignore_nan(arr)
    max_value = -Inf  # Start with a very small value
    for val in arr
        if !isnan(val) && val > max_value
            max_value = val
        end
    end
    return max_value
end
# (0.43162668f0, 0.46102867f0) old
mn = find_min_ignore_nan(new_ds.data[:,:])
mx = find_max_ignore_nan(new_ds.data[:,:])
mn = 0.43162668f0
mx = 0.46300462f0

path_ps_maps = "/Net/Groups/BGI/work_5/scratch/lalonso/parameterMaps_0d25/"
mkpath(path_ps_maps)

# ? because the array is too big, we need to tile it in order to draw it. 
using Base.Iterators: repeated, partition

function tile_batches(ds_array; bs_x = 10000, bs_y = 5000  )
    tiles_bx = partition(1:size(ds_array, 1), bs_x)
    tiles_by = partition(1:size(ds_array, 2), bs_y)
    return tiles_bx, tiles_by
end

# ds_latcut = ds_parameter[lat=-60 .. 90]

# _lon = lookup(ds_latcut, :lon)
# _lat = lookup(ds_latcut, :lat)
# tiles_bx, tiles_by = tile_batches(ds_latcut)

# # ? reproject 
# function wrapYAXtoRaster(yax)
#     yax_read = readcubedata(yax)
#     _name = yax_read.properties["name"]
#     # set appropiate range value/bounds for GDAL
#     δ = 0.008333333333333333
#     lon_range = range(-180, 180 - δ, 43200)
#     lat_range = range(90-δ, -90, 21600)
#     _lon = X(lon_range; sampling=Intervals(Start()))
#     _lat = Y(lat_range; sampling=Intervals(Start()))
#     new_ds = replace(x -> ismissing(x) ? NaN : x, yax_read.data)
#     return Raster(Float32.(new_ds), (_lon, _lat), crs=EPSG(4326), missingval=NaN32, name=_name)
# end

# yax_to_ras = wrapYAXtoRaster(ds_parameter)
# crs_proj = ProjString("+proj=patterson +type=crs")
# ras_proj = resample(yax_to_ras; size=(43200, 21600), crs=crs_proj, method="average")

# ras_proj_cut = ras_proj[Y=-7.615e6 .. end]
# # ? shifted_raster

# _lon = lookup(ras_proj_cut, :X)
# _lat = lookup(ras_proj_cut, :Y)
# tiles_bx, tiles_by = tile_batches(ras_proj_cut)

# begin
#     _colormap = Reverse(:haline)
#     colorrange=(mn, mx)
#     highclip = :orangered
#     plt = nothing
#     shading = NoShading
#     # do figure
#     fig = Figure(; figure_padding = 5, size = (7680, 4320), fontsize=64)
#     ax = Axis(fig[1,1]; aspect=DataAspect())
#     for px in tiles_bx, py in tiles_by
#         plt = heatmap!(ax, _lon[px], _lat[py], ras_proj.data[px, py];
#             colormap = _colormap, colorrange, highclip)
#         println("px = $(px) and  py = $(py)")
#     end

#     Colorbar(fig[1, 1, Top()], plt, tickalign=1, ticksize=48, height=48,
#         tickcolor=:grey45, vertical=false, width=Relative(0.85),
#         tellwidth=false, flipaxis=false)
#     Label(fig[1,1],  "$(ps_name)", tellwidth=false, tellheight=false,
#         valign = 0.98, halign=0.025)

#     Box(fig[end+1,:], color=(0.1colorant"#232e41", 0.95), tellheight=false, tellwidth=false,
#         #valign=0.97, 
#         halign=0.5,
#         width=7680, 
#         height=100, cornerradius=10,)
#     color_pinfo = :grey75
#     color_pp = 1.15*colorant"tan1"
#     Label(fig[end, :], rich("user ", color = color_pinfo,
#         rich("⋅ Lazaro", color = color_pp),
#         rich("  Sindbad.jl ", color = color_pinfo,
#         rich("| v0.1.0", color = color_pp,
#         rich("  julia ", color = color_pinfo,
#         rich("⋅ 1.11", color = color_pp,
#         rich("  experiment ", color = color_pinfo,
#         rich("⋅ Hybrid", color = color_pp,
#         rich("  domain ", color = color_pinfo,
#         rich("⋅ global", color = color_pp,
#         rich("  machine ", color = color_pinfo,
#         rich("⋅ X", color = color_pp,
#         rich("  date ", color = color_pinfo,
#         rich("⋅ today", color = color_pp,
#         )))))))))))), font="mono", fontsize=64,
#         ), 
#         tellwidth=false, halign=:center)
#     hidedecorations!(ax)
#     hidespines!(ax)
#     save(joinpath(path_ps_maps, "$(ps_name)_map_proj.png"), fig) 
# end


ds_latcut = ds_parameter[lat=-60 .. 90]

_lon = lookup(ds_latcut, :lon)
_lat = lookup(ds_latcut, :lat)
tiles_bx, tiles_by = tile_batches(ds_latcut)


begin
    _colormap = Reverse(:haline)
    colorrange=(mn, mx)
    highclip = :orangered
    plt = nothing
    _colormap = Reverse(:haline)
    shading = NoShading
    # do figure
    fig = Figure(; figure_padding = 5, size = (1440, 720), fontsize=14)
    ax = Axis(fig[1,1]; aspect=DataAspect())
    for px in tiles_bx, py in tiles_by
        plt = heatmap!(ax, _lon[px], _lat[py], ds_latcut.data[px, py];
            colormap = _colormap, colorrange, highclip)
        println("px = $(px) and  py = $(py)")
    end

    Colorbar(fig[1, 1, Top()], plt, tickalign=1, ticksize=10, height=10,
        tickcolor=:grey45, vertical=false, width=Relative(0.85),
        tellwidth=false, flipaxis=false)
    Label(fig[1,1],  "$(ps_name)", tellwidth=false, tellheight=false,
        valign = 0.98, halign=0.025)
    hidedecorations!(ax)
    hidespines!(ax)
    save(joinpath(path_ps_maps, "$(ps_name)_map_lonlat_old.png"), fig) 
end
