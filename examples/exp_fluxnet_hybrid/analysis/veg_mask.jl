using YAXArrays, Zarr
# using CairoMakie
# CairoMakie.activate!()
# using GLMakie
# GLMakie.activate!()

ds_veg = open_dataset(joinpath(@__DIR__, "../data/VegetatedLand_0d25.zarr/"))["VegLand"]

using CairoMakie
CairoMakie.activate!()
let
    fig = Figure(size = (1440, 720))
    ax = Axis(fig[1,1])
    hm = heatmap!(ax, ds_veg, colormap=cgrad(resample_cmap(:gist_stern, 256)[end-20:-1:1], scale=exp10), colorrange=(0.0,1))
    hidedecorations!(ax)
    hidespines!(ax)
    cb = Colorbar(fig[1,2], hm, label="VegetatedLand: Area Fraction")
    cb.ticks = 0:0.1:1
    save("./gpp_maps/VegetatedLand_AreaFraction.png", fig)
    # fig
end