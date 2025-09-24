# ? area_mask
using Rasters
using Rasters.Lookups
using Proj
using YAXArrays
using Zarr

xdim = X(Projected(-180:0.25:180-0.25; sampling=Intervals(Start()), crs=EPSG(4326)))
ydim = Y(Projected(90-0.25:-0.25:-90; sampling=Intervals(Start()), crs=EPSG(4326)))
myraster = rand(xdim, ydim)
cs = cellarea(myraster)
area_mask = cs.data

locus_area = DimensionalData.shiftlocus(Center(), cs)

new_dims = (lon(lookup(locus_area, :X)), lat(lookup(locus_area, :Y)))

properties = Dict{String, Any}()
properties["area"] = "Pixel area"
properties["units"] = "m2"
properties["crs"] = "EPSG:4326"

area_yax = YAXArray(new_dims, locus_area.data, properties)

ds_area = YAXArrays.Dataset(; (:area_mask => area_yax, )...)

area_mask_0d25 = "/Net/Groups/BGI/work_5/scratch/lalonso/AreaMask_0d25.zarr"

savedataset(ds_area, path=area_mask_0d25, driver=:zarr, overwrite=true)