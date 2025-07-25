using CairoMakie
using YAXArrays
using Zarr
path_masks = "/Net/Groups/BGI/work_5/scratch/lalonso/maps_masks"
# ? load vegetated land fraction
vegetated_land_0d25 = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand_0d25.zarr"
cube_land = open_dataset(vegetated_land_0d25)["VegLand"]
cube_veg_land = readcubedata(cube_land)

let
    using CairoMakie
    fig = Figure(; size=(1440, 720))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    hm = heatmap!(ax, -1*(cube_veg_land .- 1 .- 1e-3); colorscale=log10, colorrange=(1e-3, 1),
        colormap=:linear_worb_100_25_c53_n256,)
    Colorbar(fig[1,2], hm)
    save(joinpath(path_masks, "vegetated_land_fraction_flipped_scale.png"), fig)
end

let
    using CairoMakie
    fig = Figure(; size=(1440, 720))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    hm = heatmap!(ax, cube_veg_land; colormap=Reverse(:gist_stern), colorrange=(0,1))
    Colorbar(fig[1,2], hm)
    save(joinpath(path_masks,"vegetated_land_fraction_0_to_1.png"), fig)
end
