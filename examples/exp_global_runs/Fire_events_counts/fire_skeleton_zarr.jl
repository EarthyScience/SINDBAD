using YAXArrays, Zarr, FillArrays
using DimensionalData
using Dates

#SINUSOIDAL_CRS = ProjString("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
axlist = (
    Y(range(9.979756529777847e6, -1.0007111969122082e7, 720)),
    X(range(-2.0015109355797417e7, 1.998725401355172e7, 1440)),
    Ti(Date("2001-01-01"):Day(1):Date("2023-12-31")),
)

skeleton_data = Fill(NaN32, 720, 1440, 8400)

properties = Dict("FireEvents" => "MODIS/MCD64A1.061",
    "crs" => "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")

c = YAXArray(axlist, skeleton_data, properties)

path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023.zarr"

ds = YAXArrays.Dataset(; (:fire_frac => c,)...)
d_cube = savedataset(ds; path=path_to_events, driver=:zarr, skeleton=true, overwrite=true)

# ? note here: We should define the axis with the right properties. Well, it goes away, once saved. Report this as an issue.

# axlist = (
#     Dim{:lat}(Projected(range(89.875, -89.875, 720), span = Regular(), crs = EPSG(4326),
#         order = ReverseOrdered(), sampling = Intervals(Center()))),
#     Dim{:lon}(Projected(range(-179.875, 179.875, 1440), span = Regular(), crs = EPSG(4326),
#         order = ForwardOrdered(), sampling = Intervals(Center()))),
#     Ti(Date("2001-01-01"):Day(1):Date("2023-12-31")),
# )

axlist = (
    Dim{:lat}(range(89.875, -89.875, 720)),
    Dim{:lon}(range(-179.875, 179.875, 1440)),
    Ti(Date("2001-01-01"):Day(1):Date("2023-12-31")),
)

skeleton_data = Fill(NaN32, 720, 1440, 8400)

properties = Dict("FireEvents" => "MODIS/MCD64A1.061",)

c = YAXArray(axlist, skeleton_data, properties)

path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023_LATLON.zarr"

ds = YAXArrays.Dataset(; (:fire_frac => c,)...)
d_cube = savedataset(ds; path=path_to_events, driver=:zarr, skeleton=true, overwrite=true)