using YAXArrays, Zarr
using DimensionalData
using Rasters
using DimensionalData.Lookups
using ProgressMeter

function yaxRaster(yax)
    # x_range = lookup(yax, :X).data
    # y_range = lookup(yax, :Y).data
    x_range = LinRange(-20015109.355798, 20015109.355798, 1441)[1:end-1]
    y_range = LinRange(10007554.677899, -10007554.677899, 721)[2:end]

    crs_sinu = yax.properties["crs"]
    ras_out = replace(x -> x==1.0f32 ? NaN : x, yax) # "_FillValue= 1.0f32"

    new_raster = Raster(ras_out.data, (Y(y_range; sampling=Intervals(Start())), X(x_range; sampling=Intervals(Start()))),
        crs=ProjString(crs_sinu))

    return new_raster
end
# open .zarr 
path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023.zarr"
ds = open_dataset(path_to_events)

# save new values
path_to_latlon = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023_LATLON.zarr"
outar = zopen(joinpath(path_to_latlon, "fire_frac"), "w")

# calculate new values
@showprogress for t_index in 1:size(ds["fire_frac"], 3)
    ras = yaxRaster(ds["fire_frac"][Ti=t_index])
    resampled = resample(ras; size=(720, 1440), crs=EPSG(4326), method="average")

    outar[:, :, t_index] = resampled.data
end