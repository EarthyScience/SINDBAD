using CairoMakie
using YAXArrays
using Zarr
using Statistics
using Rasters
using Rasters.Lookups

# path_out = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_pfts_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cFireTotal.zarr"
# all covs
#path_out = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_ALL_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cFireTotal.zarr"
path_out = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_pfts_2003_2015_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cFireTotal.zarr"

ds_forcing = open_dataset("/Net/Groups/BGI/work_4/scratch/lalonso/GlobalForcing.zarr")
ds_fire = ds_forcing["fire_frac_per_area"]

ds_out = open_dataset(path_out)
yax_cfireTotal = ds_out["layer"]

using Proj

xdim = X(Projected(-180:0.25:180-0.25; sampling=Intervals(Start()), crs=EPSG(4326)))
ydim = Y(Projected(90-0.25:-0.25:-90; sampling=Intervals(Start()), crs=EPSG(4326)))
myraster = rand(xdim, ydim)
cs = cellarea(myraster)
area_mask = cs.data

co2_f = yax_cfireTotal[time = DateTime("2011-01-01") .. DateTime("2011-12-31")]

masked_co2 = mapslices(x -> x .* area_mask, co2_f,
    dims=("longitude", "latitude"))


masked_sum_co2 = mapslices(x -> sum(skipmissing(x)), masked_co2,
    dims=("time"))

c_fire = readcubedata(ds_fire[Ti = DateTime("2011-01-01") .. DateTime("2011-12-31")])
c_fire = replace(x->isnan(x) ? missing : x, c_fire)

sum_fire = mapslices(x -> mean(skipmissing(x)), c_fire,
    dims=("Time"))

with_theme(theme_light()) do
    fig = Figure(; size = (1200,720))
    ax = Axis(fig[1,1])
    plt = heatmap!(ax, masked_sum_co2[latitude=-60 .. 90] .* cube_PFTs_cut.data[:,:] ./10^15 .+ 1e-10;
        colorscale=log10, lowclip = :grey15, colorrange = (1e-9, 1e-3), colormap=:inferno)
    Colorbar(fig[1,2], plt, label="sum")
    save("biomass_2011.png", fig)
end

with_theme(theme_light()) do
    fig = Figure(; size = (1200,720))
    ax = Axis(fig[1,1])
    plt = heatmap!(ax, sum_fire[latitude=-60 .. 90] .* cube_PFTs_cut.data[:,:];
        # colorscale=log10,
        lowclip = :grey15, #colorrange = (1e-1, 2),
        colormap=:inferno)
    Colorbar(fig[1,2], plt,label="mean")
    save("fires_mean_2011.png", fig)
end