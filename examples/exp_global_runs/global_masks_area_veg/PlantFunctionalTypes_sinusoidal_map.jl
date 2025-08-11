using CairoMakie
using YAXArrays
using Zarr
path_masks = "/Net/Groups/BGI/work_5/scratch/lalonso/maps_masks"

# ? load plant funcional types
path_to_lc = "/Net/Groups/BGI/work_5/scratch/lalonso/PlantFunctionalTypes.zarr"

ds_open = open_dataset(path_to_lc)
cube_open = ds_open["Plant_Functional_Type"]
cube_pft = readcubedata(cube_open) #! be careful, this is ~14G in memory 

let
    using CairoMakie
    fig = Figure(figure_padding=(0); size = (8640, 4320))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    heatmap!(ax, cube_pft[1:10:end, 1:10:end],
        colormap=Categorical(cgrad(:ground_cover, 16, categorical=true)), # tol_land_cover
        colorrange = (1,16), highclip=:grey95,
        lowclip= :grey13
        )
    save(joinpath(path_masks, "PlantFunctionalTypes.png"), fig)
end