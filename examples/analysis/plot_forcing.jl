using CairoMakie
using GeoMakie
using Dates
using YAXArrays, Zarr
using Statistics

ds = open_dataset("/Net/Groups/BGI/work_3/scratch/lalonso/FLUXNET_v2023_12_2D.zarr")

ds_fire = ds["fire_frac"]

fig = Figure(; size = (1440, 720))
ax = Axis(fig[1,1])
plt = heatmap!(ax, ds_fire[:,:,1])
Colorbar(fig[1,2], plt)
fig
save("fire.png", fig)

ds_vals = ds_fire[:,:,1].data[:,:]
ds_vals[ds_fire[:,:,1] .> 0] |> maximum