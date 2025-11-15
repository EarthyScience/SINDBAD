using Pkg
Pkg.activate(@__DIR__)
Pkg.add(url="https://github.com/EarthyScience/UnpackSinTiles.jl", rev="la/split_land_cover_types")

using YAXArrays, Zarr, FillArrays
using DimensionalData
using Dates
using DelimitedFiles
using ProgressMeter
using UnpackSinTiles

# ? https://lpdaac.usgs.gov/documents/1006/MCD64_User_Guide_V61.pdf
# Appendix B Coordinate conversion for the MODIS sinusoidal projection
# Navigation of the tiled MODIS products in the sinusoidal projection can be performed using the forward
# and inverse mapping transformations described here. We’ll first need to define a few constants:
# R = 6371007.181 m, the radius of the idealized sphere representing the Earth;
# T = 1111950 m, the height and width of each MODIS tile in the projection plane;
# xmin = -20015109 m, the western limit of the projection plane;
# ymax = 10007555 m, the northern limit of the projection plane;
# w = T /2400= 463.31271653 m, the actual size of a “500-m” MODIS sinusoidal grid cell.
# ! full ellipsoid
#SINUSOIDAL_CRS = ProjString("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")


properties = Dict("LandCover" => "MODIS/MCD64A1.061",
    "crs" => "+proj=sinu +lon_0=0 +type=crs",
    "grid_cell_width" => "463.31271653 m",
    "R" => "6371007.181 m")

axlist = (
    Y(range(10007555, step=-463.31271653, length=43200)),
    X(range(-20015109, step=463.31271653, length=86400)),
)

skeleton_data = Fill(NaN32, 43200, 86400)

cube = YAXArray(axlist, skeleton_data, properties)

path_to_lc = "/Net/Groups/BGI/work_5/scratch/lalonso/PlantFunctionalTypes.zarr"

ds = YAXArrays.Dataset(; (:Plant_Functional_Type => cube,)...)

d_cube = savedataset(ds; path=path_to_lc, driver=:zarr, skeleton=true, overwrite=true)

# test one, open one!
hv_tile = "h01v08"
in_date = "2009.01.01"

root_path = "/Net/Groups/BGI/data/DataStructureMDI/DATA/Incoming/MODIS/MCD12Q1.061/orgdata/"
lc_type1 = loadTileVariable(hv_tile, in_date, root_path, "LC_Type1")

#! convert those 0xXY
LC_TypeX_vals = Float32.(lc_type1)

# ? open and update entries in dataset
outar = zopen(joinpath(path_to_lc, "Plant_Functional_Type"), "w")

mtiles = modisTiles()[:]

@showprogress for hv_tile in  mtiles
    lc_type1 = loadTileVariable(hv_tile, in_date, root_path, "LC_Type1")
    if !isnothing(lc_type1)
        LC_TypeX_vals = Float32.(lc_type1)
        # get indices in array for the current tile
        hv_indices = getTileInterval(hv_tile; h_bound=1:86400, v_bound=1:43200)
        #! update entries!
        @info hv_tile
        outar[hv_indices] = LC_TypeX_vals
    end
end