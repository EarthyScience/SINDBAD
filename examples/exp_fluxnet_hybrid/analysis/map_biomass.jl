using Random
using YAXArrays
using Zarr
using NaNStatistics
using CairoMakie
using Dates

path_cEco = "/Net/Groups/BGI/work_5/scratch/lalonso/forward_f_pfts_2003_2015_c16x16_0d25/Global_Seasfire_fPFTs/data/Seasfire_fPFTs_Global_cEco.zarr"

# load f_pfts

ds = open_dataset("/Net/Groups/BGI/work_5/scratch/lalonso/CovariatesGlobal_025.zarr")
cube_PFTs = readcubedata(ds["PFT_mask"])
cube_PFTs = Float32.(cube_PFTs)
cube_PFTs = replace(x->x==16.0 ? NaN : x, cube_PFTs)
cube_PFTs = replace(x-> !isnan(x) ? 1 : x, cube_PFTs)
cube_PFTs_cut = cube_PFTs[lat = -60 .. 90]

ds= open_dataset(path_cEco)

ds_cEco_2011 = readcubedata(ds_cEco[time =At(DateTime("2011-01-01")), d_cEco = 5 .. 8])
ds_cEco_μ = mapslices(sum, ds_cEco_2011, dims="d_cEco")


with_theme(theme_light()) do
    fig = Figure(; size = (1200,720))
    ax = Axis(fig[1,1])
    plt = heatmap!(ax, ds_cEco_μ[latitude=-60 .. 90] .* cube_PFTs_cut.data[:,:])
    Colorbar(fig[1,2], plt)
    save("biomass_5_8.png", fig)
end

ds_cEco = ds["layer"]
ds_cEco_2011 = readcubedata(ds_cEco[time =At(DateTime("2011-01-01")), d_cEco = 1 .. 4])
ds_cEco_μ = mapslices(sum, ds_cEco_2011, dims="d_cEco")

with_theme(theme_light()) do
    fig = Figure(; size = (1200,720))
    ax = Axis(fig[1,1])
    plt = heatmap!(ax, ds_cEco_μ[latitude=-60 .. 90] .* cube_PFTs_cut.data[:,:])
    Colorbar(fig[1,2], plt)
    save("biomass_1_4.png", fig)
end