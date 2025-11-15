using YAXArrays, Zarr
using DimensionalData
using Rasters
using Rasters.Lookups
using DimensionalData.Lookups
using ProgressMeter

function yaxRaster(yax)
    x_range = lookup(yax, :X).data
    y_range = lookup(yax, :Y).data
    _data = replace(yax.data, NaN=>0)
    return Raster(_data, (Y(y_range; sampling=Intervals(Start())), X(x_range; sampling=Intervals(Start()))),
        crs=ProjString("+proj=sinu +lon_0=0 +type=crs"))
end


vegetated_land = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand.zarr"
ds_veg = open_dataset(vegetated_land)

sin_ras = yaxRaster(readcubedata(ds_veg["layer"]))

resampled = resample(sin_ras; size=(720, 1440), crs=EPSG(4326), method="average")

locus_resampled = DimensionalData.shiftlocus(Center(), resampled)
new_dims = (lat(lookup(locus_resampled, :Y)), lon(lookup(locus_resampled, :X)))
zeros_to_nan = replace(locus_resampled, 0 => NaN32)

properties = Dict{String, Any}()
properties["VegetatedLand"] = "Percentage of vegetated area per pixel"
properties["PRODUCT"] = "MODIS/MCD64A1.061"
properties["crs"] = "EPSG:4326"

resampled_yax = YAXArray(new_dims, zeros_to_nan.data, properties)
ds_sampled = YAXArrays.Dataset(; (:VegLand => resampled_yax, )...)

vegetated_land_0d25 = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand_0d25.zarr"

savedataset(ds_sampled, path=vegetated_land_0d25, driver=:zarr, overwrite=true)