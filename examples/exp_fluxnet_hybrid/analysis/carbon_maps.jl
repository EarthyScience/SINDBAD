using JLD2
using GLMakie
using Dates
using DimensionalData
using YAXArrays, Zarr
using Rasters.Lookups
using Rasters
using GLMakie.Colors
using Statistics
# area_mask
using Proj

xdim = X(Projected(-180:0.25:180-0.25; sampling=Intervals(Start()), crs=EPSG(4326)))
ydim = Y(Projected(90-0.25:-0.25:-90; sampling=Intervals(Start()), crs=EPSG(4326)))
myraster = rand(xdim, ydim)
cs = cellarea(myraster)
area_mask = cs.data

# ? saved global carbon
sum_gfas_co2_cat = JLD2.load(joinpath(@__DIR__, "co2_global.jld2"))
sum_gfas_co2_cat = DimArray(sum_gfas_co2_cat["co2_global"], (Ti(DateTime("2003-01-01"):Day(1):DateTime("2022-12-31")),))

sum_gfas_year = groupby(sum_gfas_co2_cat, Ti=>year)
# sum_gfas_year = groupby(sum_gfas_co2_cat, Dim{:time}=>year)
gfas_years = sum.(sum_gfas_year) /10^9 /1000/(44/12)


# ? from models PFT
ds_carbon_PFT = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/carbon_maps_FixK_PFT.zarr/"))

sum_carbon_PFT = mapslices(x -> sum(skipmissing(x .* area_mask)), ds_carbon_PFT["layer"],
    dims=("longitude", "latitude"))
    
# ? from models ALL
ds_carbon_ALL = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/carbon_maps_FixK_ALL.zarr/"))

sum_carbon_ALL = mapslices(x -> sum(skipmissing(x .* area_mask)), ds_carbon_ALL["layer"],
    dims=("longitude", "latitude"))
    
# ? fires
ds_fires = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/fire_maps_sums.zarr/"))
sum_fires = mapslices(x -> sum(skipmissing(x .* area_mask)), ds_fires["fire_frac_per_area"],
    dims=("longitude", "latitude"))
   
ff_diff = sum_fires.data[3:end] .- sum_fires.data[2:end-1]

with_theme(theme_latexfonts()) do 
    fig = Figure(; size = (1200, 400), fontsize = 18)
    ax = Axis(fig[1,1]; 
    yticklabelcolor = :grey15,
    rightspinecolor = :grey15,
    ytickcolor = :grey15,
    xticklabelcolor = :grey15,
    xtickcolor = :grey15
    )
    ax2 = Axis(fig[2,1]; xlabel="year",
        yticklabelcolor = :orangered,
        rightspinecolor = :orangered,
        ytickcolor = :orangered)
    Label(fig[2,1, Top()],"km² [million] : burnt area", halign=0, color=:orangered)
    Label(fig[1,1, Top()],"Pg C : Global Carbon emissions", halign=0, color=:grey15)

    scatterlines!(ax, 2003 .. 2022, gfas_years.data; label = "GFAS",
        markersize = 15, color = :black)
    scatterlines!(ax, 2003 .. 2022, sum_carbon_ALL.data[2:end] ./1e15; label = "HyFixK-All",
        markercolor=:transparent, color=:dodgerblue,
        markersize = 15, marker = :rect, strokewidth=1.25, strokecolor = :dodgerblue)
    _color =  RGBA{Float32}(0.9019608f0,0.62352943f0,0.0f0,1.0f0)
    scatterlines!(ax, 2003 .. 2022, sum_carbon_PFT.data[2:end] ./1e15; label = "HyFixK-PFT",
        color=_color, markercolor=:transparent,
        marker=:diamond, strokewidth=1.25, strokecolor = _color, markersize=13)
    barplot!(ax2, 2003 .. 2022, sum_fires.data[2:end] ./1e6 /1e6, color=(:orangered, 0.75), width=0.5)
    # diff current minus prev
    # barplot!(ax2, 2004 .. 2022, ff_diff ./1e6 /1e6, color=:black, width=0.5)

    ylims!(ax, 0, 2.5)
    # ylims!(ax2, 0, 3.65)
    ylims!(ax2, 2.0, 3.65)
    Legend(fig[1,1, Top()], ax; nbanks=3, position=:rt, framewidth=0.25, halign=1)
    hidespines!(ax)
    # hidexdecorations!(ax, grid=false, ticks=false)
    hidespines!(ax2)
    linkxaxes!.(ax, ax2)
    hidexdecorations!(ax2, grid=false, ticks=false)
    rowsize!(fig.layout, 1, Auto(3))
    rowgap!(fig.layout, 0)
    fig
end
# save("carbon_comparison_fire_2.png", current_figure())

# TODO: now the maps
ds_c_all = ds_carbon_ALL["layer"]
ds_flux_μ_t = mapslices(mean, ds_c_all, dims="time")

with_theme(theme_latexfonts()) do
    fig = Figure(; size = (1200,640), fontsize=28)
    ax = Axis(fig[1,1])
    plt = heatmap!(ax, ds_flux_μ_t[latitude=-60 .. 90] .+ 1e-10;
        colormap = :rainbow1, colorscale=log10, colorrange = (0.001, 500),
        lowclip=:grey45, highclip=:darkred,
        )
    cb = Colorbar(fig[2,1], plt; label ="Fire emissions [gC / m² / year] (2002-2022)", vertical=false, width=Relative(0.65))
    hidedecorations!(ax; grid=false)
    cb.ticks = ([0.001, 0.01, 0.1, 1, 10, 100, 500], ["0.001", "0.01", "0.1", "1", "10", "100", "500"])
    hidespines!(ax)
    save("cFire_Flux_FixK_ALL_sum_mean_yearly.png", fig)
    fig
end


ds_c_PFT = ds_carbon_PFT["layer"]
ds_flux_μ_t = mapslices(mean, ds_c_PFT, dims="time")

with_theme(theme_latexfonts()) do
    fig = Figure(; size = (1200,640), fontsize=28)
    ax = Axis(fig[1,1])
    plt = heatmap!(ax, ds_flux_μ_t[latitude=-60 .. 90] .+ 1e-10;
        colormap = :rainbow1, colorscale=log10, colorrange = (0.001, 500),
        lowclip=:grey45, highclip=:darkred,
        )
    cb = Colorbar(fig[2,1], plt; label ="Fire emissions [gC / m² / year] (2002-2022)", vertical=false, width=Relative(0.65))
    hidedecorations!(ax; grid=false)
    cb.ticks = ([0.001, 0.01, 0.1, 1, 10, 100, 500], ["0.001", "0.01", "0.1", "1", "10", "100", "500"])
    hidespines!(ax)
    save("cFire_Flux_FixK_PFT_sum_mean_yearly.png", fig)
    fig
end

# TODO: GPP

# ? from models PFT
ds_gpp_PFT = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/gpp_maps_FixK_PFT.zarr/"))
ds_gpp_μ_pft = mapslices(mean, ds_gpp_PFT["layer"], dims="time")
to_hist_pft = filter(!ismissing, ds_gpp_μ_pft.data)

with_theme(theme_latexfonts()) do
    fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
    ax = Axis(fig[1,1])
    ax_in = Axis(fig, bbox = BBox(20, 350, 215, 315), xticklabelsize = 18,
       yticklabelsize = 18)
    plt = heatmap!(ax, ds_gpp_μ_pft[latitude=-60 .. 90]; # .+ 1e-10;
        colormap = :deep, 
        #colorscale=log10,
        colorrange = (0.0, 3500),
        #lowclip=:grey45,
        highclip=:orangered,
        )
    # do inset density plot    
    density!(ax_in, to_hist_pft; color= :x, strokecolor=:black, strokewidth= 0.5,
        colormap = :deep, colorrange = (0.0, 3500),)
    hideydecorations!(ax_in)
    hidexdecorations!(ax_in; ticks=false, ticklabels = false)
    hidespines!(ax_in, :t, :r)
    xlims!(ax_in, 0, 3500)
    ylims!(ax_in, 0, nothing)
    ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

    cb = Colorbar(fig[2,1], plt; label = rich("GPP [gC / m² / year]", rich(" HyFixK_PFT (2002-2022)", font=:bold)),
        vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
    hidedecorations!(ax; grid=false)
    hidespines!(ax)
    save("gpp_FixK_PFT_sum_mean_yearly.png", fig)
    fig
end

# ? from models ALL
ds_gpp_ALL = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/gpp_maps_FixK_ALL.zarr/"))
ds_gpp_μ_all = mapslices(mean, ds_gpp_ALL["layer"], dims="time")
to_hist_all = filter(!ismissing, ds_gpp_μ_all.data)

with_theme(theme_latexfonts()) do
    fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
    ax = Axis(fig[1,1])
    ax_in = Axis(fig, bbox = BBox(20, 350, 215, 315), xticklabelsize = 18,
       yticklabelsize = 18)

    plt = heatmap!(ax, ds_gpp_μ_all[latitude=-60 .. 90]; # .+ 1e-10;
        colormap = :deep, 
        colorrange = (0.0, 3500),
        highclip=:orangered,
        )
    # do inset density plot    
    density!(ax_in, to_hist_all; color= :x, strokecolor=:black, strokewidth= 0.5,
        colormap = :deep, colorrange = (0.0, 3500),)
    hideydecorations!(ax_in)
    hidexdecorations!(ax_in; ticks=false, ticklabels = false)
    hidespines!(ax_in, :t, :r)
    xlims!(ax_in, 0, 3500)
    ylims!(ax_in, 0, nothing)
    ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

    cb = Colorbar(fig[2,1], plt; label = rich("GPP [gC / m² / year]", rich(" HyFixK_ALL (2002-2022)", font=:bold)),
        vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
    hidedecorations!(ax; grid=false)
    hidespines!(ax)
    save("gpp_FixK_ALL_sum_mean_yearly.png", fig)
    fig
end


# TODO: NEE

# ? from models PFT
ds_gpp_PFT = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/nee_maps_FixK_PFT.zarr/"))
ds_gpp_μ_pft = mapslices(mean, ds_gpp_PFT["layer"], dims="time")
to_hist_pft = filter(!ismissing, ds_gpp_μ_pft.data)
n = 256
colormap = vcat(resample_cmap(:linear_kbc_5_95_c73_n256, n),
    resample_cmap(Reverse(:linear_kryw_5_100_c67_n256), n))
sc = ReversibleScale(x -> x > 0 ? x*2 : x, x -> x > 0 ? x/2 : x)

with_theme(theme_latexfonts()) do
    fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
    ax = Axis(fig[1,1])
    ax_in = Axis(fig, bbox = BBox(20, 350, 215, 315), xticklabelsize = 18,
       yticklabelsize = 18)
    plt = heatmap!(ax, ds_gpp_μ_pft[latitude=-60 .. 90]; # .+ 1e-10;
        colormap = colormap, 
        #colorscale=log10,
        colorrange = (-1000, 1000),
        # colorscale = sc,
        #lowclip=:grey45,
        highclip=:orangered,
        )
    # ? do inset density plot    
    # density!(ax_in, to_hist_pft; color= :x, strokecolor=:black, strokewidth= 0.5,
    #     colormap = :deep, colorrange = (0.0, 3500),)
    # hideydecorations!(ax_in)
    # hidexdecorations!(ax_in; ticks=false, ticklabels = false)
    # hidespines!(ax_in, :t, :r)
    # xlims!(ax_in, 0, 3500)
    # ylims!(ax_in, 0, nothing)
    # ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

    cb = Colorbar(fig[2,1], plt; label = rich("GPP [gC / m² / year]", rich(" HyFixK_PFT (2002-2022)", font=:bold)),
        vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
    hidedecorations!(ax; grid=false)
    hidespines!(ax)
    # save("nee_FixK_PFT_sum_mean_yearly.png", fig)
    fig
end

# ? from models ALL
ds_nee_ALL = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/nee_maps_FixK_ALL.zarr/"))
ds_nee_μ_all = mapslices(mean, ds_nee_ALL["layer"], dims="time")
to_hist_all = filter(!ismissing, ds_nee_μ_all.data)

with_theme(theme_latexfonts()) do
    fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
    ax = Axis(fig[1,1])
    # ax_in = Axis(fig, bbox = BBox(20, 350, 215, 315), xticklabelsize = 18,
    #    yticklabelsize = 18)

    plt = heatmap!(ax, ds_nee_μ_all[latitude=-60 .. 90]; # .+ 1e-10;
        colormap = colormap, 
        colorrange = (-650, 650),
        # highclip=:orangered,
        )
    # do inset density plot    
    # density!(ax_in, to_hist_all; color= :x, strokecolor=:black, strokewidth= 0.5,
    #     colormap = :deep, colorrange = (0.0, 3500),)
    # hideydecorations!(ax_in)
    # hidexdecorations!(ax_in; ticks=false, ticklabels = false)
    # hidespines!(ax_in, :t, :r)
    # xlims!(ax_in, 0, 3500)
    # ylims!(ax_in, 0, nothing)
    # ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

    cb = Colorbar(fig[2,1], plt; label = rich("NEE [gC / m² / year]", rich(" HyFixK_ALL (2002-2022)", font=:bold)),
        vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
    hidedecorations!(ax; grid=false)
    hidespines!(ax)
    # save("gpp_FixK_ALL_sum_mean_yearly.png", fig)
    fig
end


tempo = ds_nee_ALL["layer"].time
for i in eachindex(tempo)
    with_theme(theme_latexfonts()) do
        fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24,
            backgroundcolor=:grey25)
        ax = Axis(fig[1,1]; backgroundcolor=:grey25)
        plt = heatmap!(ax,  ds_nee_ALL["layer"][time =At(tempo[i]), latitude=-60 .. 90];
            colormap = colormap, 
            colorrange = (-650, 650),
            )
        cb = Colorbar(fig[2,1], plt; label = rich("NEE [gC / m² / year]", rich(" HyFixK_ALL - $(year(tempo[i]))", font=:bold)),
            vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85,
            labelcolor=:white, ticklabelcolor=:white)
        hidedecorations!(ax; grid=false)
        hidespines!(ax)
        save("nee_FixK_ALL_sum_mean_yearly_$(year(tempo[i])).png", fig)
        fig
    end
end