using YAXArrays, Zarr, FillArrays
using DimensionalData
using Dates
using DelimitedFiles
using ProgressMeter
using UnpackSinTiles
using Rasters

function compute_mask_not(m, to_vals::AbstractVector)
    if ismissing(m)
        return false
    else
        return m .∉ Ref(to_vals)
    end
end

# Load data in SINUSOIDAL_CRS
path_to_lc = "/Net/Groups/BGI/work_5/scratch/lalonso/PlantFunctionalTypes.zarr"
cube_open = open_dataset(path_to_lc)["Plant_Functional_Type"]

# cube_pft = readcubedata(cube_open)

veg_forms = Dict{String, AbstractArray}()
veg_forms["non_veg"] = [17, 13, 15, 16, 255, NaN, 1.0f32]
veg_forms["tree"] = [1,2,3,4,5]
veg_forms["shrub"] = [6,7]
veg_forms["savanna"] = [8,9]
veg_forms["herb"] = [10,11,12,14]

vegetated_land = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand.zarr"

r = mapCube(cube_open, indims=InDims(), outdims=OutDims(; overwrite=true, path=vegetated_land)) do xout, x
    _veg_bool = ismissing(x) ? NaN : x
    xout .= compute_mask_not(_veg_bool, veg_forms["non_veg"]) ? 1 : NaN
end

veg_forms["non_veg_p16"] = [17, 13, 15, 255, NaN, 1.0f32] # include barren -> 16 (by removing from this list :D)

vegetated_land_barren = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand_pBarren.zarr"

r2 = mapCube(cube_open, indims=InDims(), outdims=OutDims(; overwrite=true, path=vegetated_land_barren)) do xout, x
    _veg_bool = ismissing(x) ? NaN : x
    xout .= compute_mask_not(_veg_bool, veg_forms["non_veg_p16"]) ? 1 : NaN
end