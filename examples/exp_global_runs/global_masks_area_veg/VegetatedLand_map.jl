using CairoMakie
using YAXArrays
using Zarr
path_masks = "/Net/Groups/BGI/work_5/scratch/lalonso/maps_masks"

vegetated_land = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand.zarr"
r = open_dataset(vegetated_land)["layer"]
cube_veg_land = readcubedata(r) #! be careful, this is ~14G in memory 

let
    fig = Figure(figure_padding=(0); size = (8640, 4320))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    heatmap!(ax, cube_veg_land[1:10:end, 1:10:end],
        colormap=Categorical(cgrad([:grey45, :black], 2, categorical=true)), # tol_land_cover
        # colorrange = (1,16), highclip=:black,
        # lowclip= :grey13
        )
    save(joinpath(path_masks, "VegetatedLand.png"), fig)
end

vegetated_land_barren = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand_pBarren.zarr"
r2 = open_dataset(vegetated_land_barren)["layer"]
cube_veg_land_barren = readcubedata(r2) #! be careful, this is ~14G in memory 

let
    fig = Figure(figure_padding=(0); size = (8640, 4320))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    heatmap!(ax, cube_veg_land_barren[1:10:end, 1:10:end],
        colormap=Categorical(cgrad([:grey45, :black], 2, categorical=true)), # tol_land_cover
        # colorrange = (1,16), highclip=:black,
        # lowclip= :grey13
        )
    save(joinpath(path_masks,"VegetatedLand_plus_barren.png"), fig)
end
