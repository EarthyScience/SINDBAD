using Random
using YAXArrays
using Zarr
using NaNStatistics
# using Rasters, ArchGDAL
# using Rasters.Lookups
using CairoMakie
# using GeoMakie
# ? util functions
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
# ? because the array is too big, we need to tile it in order to draw it. 
using Base.Iterators: repeated, partition

function tile_batches(ds_array; bs_x = 10000, bs_y = 5000  )
    tiles_bx = partition(1:size(ds_array, 1), bs_x)
    tiles_by = partition(1:size(ds_array, 2), bs_y)
    return tiles_bx, tiles_by
end


# ? open parameters
ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_f_pfts_0d25.zarr"
# ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_fALL2_0d25.zarr"

out_params = open_dataset(ps_path)
out_params = out_params["parameters"]
pnames = out_params.parameter

path_ps_maps = "/Net/Groups/BGI/work_5/scratch/lalonso/parameterMaps_f_pfts_0d25/"
# path_ps_maps = "/Net/Groups/BGI/work_5/scratch/lalonso/parameterMaps_f_ALL_0d25/"
mkpath(path_ps_maps)

for ps_name in pnames
    # ps_name = "constant_frac_max_root_depth" # "k_extinction"
    ds_parameter = readcubedata(out_params[parameter= At(ps_name)])
    # extrema
    new_ds = replace(x -> ismissing(x) ? NaN : x, ds_parameter)

    mn = find_min_ignore_nan(new_ds.data[:,:])
    mx = find_max_ignore_nan(new_ds.data[:,:])

    ds_latcut = ds_parameter[lat=-60 .. 90]

    # _lon = lookup(ds_latcut, :longitude)
    # _lat = lookup(ds_latcut, :latitude)
    _lon = lookup(ds_latcut, :lon)
    _lat = lookup(ds_latcut, :lat)
    tiles_bx, tiles_by = tile_batches(ds_latcut)

    begin
        # _colormap = Reverse(:haline)
        colorrange=(mn, mx)
        highclip = :orangered
        plt = nothing
        _colormap = :thermal #Reverse(:haline)
        shading = NoShading
        # do figure
        fig = Figure(; figure_padding = 5, size = (1440, 720), fontsize=22)
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
        # save(joinpath(path_ps_maps, "f_ALL_$(ps_name).png"), fig) 
        save(joinpath(path_ps_maps, "f_pfts_$(ps_name).png"), fig) 
    end
    @info ps_name
end