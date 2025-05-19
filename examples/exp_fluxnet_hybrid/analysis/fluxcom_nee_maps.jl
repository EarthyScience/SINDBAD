using GLMakie
using YAXArrays, Zarr
using Dates
using DimensionalData
using GeoMakie

ds_nee = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/nee_maps_fluxcom.zarr/"))

tempo = ds_nee["NEE"].time
mkpath("Fluxcom_X/NEE")

n = 256
colormap = vcat(resample_cmap(:linear_kbc_5_95_c73_n256, n),
    resample_cmap(Reverse(:linear_kryw_5_100_c67_n256), n))
sc = ReversibleScale(x -> x > 0 ? x*2 : x, x -> x > 0 ? x/2 : x)


for i in eachindex(tempo)
    with_theme(theme_dark()) do
        fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24,
            backgroundcolor=:grey15)
        ax = Axis(fig[1,1]; backgroundcolor=:grey25)
        # ax = GeoAxis(fig[1,1]; dest = "+proj=wintri")
        plt = surface!(ax,  ds_nee["NEE"][time =At(tempo[i]), lat=-60 .. 90];
            colormap = colormap, shading=NoShading,
            colorrange = (-650, 650),
            )
        cb = Colorbar(fig[2,1], plt; label = rich("NEE [gC / m² / year]", rich(" Fluxcom-X-BASE $(year(tempo[i]))", font=:bold)),
            vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85,
            labelcolor=:white, ticklabelcolor=:white)
        hidedecorations!(ax; grid=false)
        # ax.xgridwidth = 0.5
        # ax.ygridwidth = 0.5
        # ax.xgridcolor = :grey45
        # ax.ygridcolor = :grey45
        # ax.xgridstyle = :dash
        # ax.ygridstyle = :dash
        # hidespines!(ax)
        save(joinpath("./Fluxcom_X/NEE", "nee_Fluxcom_X_Base_mean_$(year(tempo[i])).png"), fig)
        fig
    end
end