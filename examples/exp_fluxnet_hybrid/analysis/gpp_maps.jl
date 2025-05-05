using JLD2
using GLMakie
using Dates
using DimensionalData
using YAXArrays, Zarr
using Rasters.Lookups
using Rasters
using GLMakie.Colors
using Statistics
using CairoMakie
CairoMakie.activate!()

# TODO: GPP

# ? from models PFT
ds_gpp_PFT = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/gpp_maps_FixK_PFT.zarr/"))
ds_gpp_μ_pft = mapslices(mean, replace(ds_gpp_PFT["layer"][time= DateTime(2002) .. DateTime(2018)], 1.0f32=>missing), dims="time")
# ? masks
ds_area = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/AreaMask_0d25.zarr"))["area_mask"]
ds_veg = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/VegetatedLand_0d25.zarr"))["VegLand"]
ds_veg_p = permutedims(ds_veg, (2,1))

ds_gpp_μ_pft_new = YAXArray(dims(ds_veg_p), ds_gpp_μ_pft.data)

ds_gpp_pft_mask = ds_gpp_μ_pft_new .* ds_veg_p .* ds_area
ds_gpp_pft_mask = readcubedata(ds_gpp_pft_mask)

# ! filter after masks
to_hist_pft = filter(!ismissing, ds_gpp_pft_mask.data)
to_hist_pft = filter(!isnan, to_hist_pft)
# _g_sum = sum(to_hist_pft)./1e15
_g_sum = sum(to_hist_pft[to_hist_pft .>0])./1e15

with_theme(theme_latexfonts()) do
    fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
    ax = Axis(fig[1,1])
    ax_in = Axis(fig, bbox = BBox(20, 320, 115, 215), xticklabelsize = 18,
       yticklabelsize = 18)
    plt = heatmap!(ax, ds_gpp_pft_mask[lat=-60 .. 90] ./ 1e12; # .+ 1e-10;
        colormap = :deep, 
        #colorscale=log10,
        colorrange = (0.0, 3),
        lowclip=:orange,
        highclip=:orangered,
        )
    # do inset density plot    
    density!(ax_in, to_hist_pft ./ 1e12; color= :x, strokecolor=:black, strokewidth= 0.5,
        colormap = :deep, colorrange = (0.0, 3),
        )
    hideydecorations!(ax_in)
    hidexdecorations!(ax_in; ticks=false, ticklabels = false)
    hidespines!(ax_in, :t, :r)
    xlims!(ax_in, 0, 3)
    ylims!(ax_in, 0, nothing)
    # ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

    cb = Colorbar(fig[2,1], plt; label = rich("GPP [ Mt gC ]", rich("HyFixK_PFT (2002-2017)", font=:bold)),
        vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
    hidedecorations!(ax; grid=false)
    hidespines!(ax)
    Label(fig[1,1], "Globally\n $(round(_g_sum, digits=2)) Pg C ",
            tellwidth=false, tellheight=false, halign=0.46, valign=0.25)

    mkpath("./gpp_maps/PFT/")
    save("./gpp_maps/PFT/gpp_FixK_PFT_sum_mean_yearly_2002-2017.png", fig)
    fig
end

# for each year
ds_gpp_pft = replace(ds_gpp_PFT["layer"], 1.0f32=>missing)

_gpp_pft_sums = Float64[]

for tempo in ds_gpp_pft.time
    ds_gpp_pft_year = ds_gpp_pft[time=At(tempo)]

    ds_gpp_y_pft_new = YAXArray(dims(ds_veg_p), ds_gpp_pft_year.data)

    ds_gpp_y_mask = ds_gpp_y_pft_new .* ds_veg_p .* ds_area
    ds_gpp_y_mask = readcubedata(ds_gpp_y_mask)

    to_hist_pft = filter(!ismissing, ds_gpp_y_mask.data)
    to_hist_pft = filter(!isnan, to_hist_pft)

    _gpp_sum_g = sum(to_hist_pft[to_hist_pft .>0])./1e15
    push!(_gpp_pft_sums, _gpp_sum_g)


    with_theme(theme_latexfonts()) do
        fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
        ax = Axis(fig[1,1])
        ax_in = Axis(fig, bbox = BBox(20, 320, 115, 215), xticklabelsize = 18,
        yticklabelsize = 18)
        plt = heatmap!(ax, ds_gpp_y_mask[lat=-60 .. 90] ./ 1e12; # .+ 1e-10;
            colormap = :deep, 
            #colorscale=log10,
            colorrange = (0.0, 3),
            lowclip=:orange,
            highclip=:orangered,
            )
        # do inset density plot    
        density!(ax_in, to_hist_pft ./1e12; color= :x, strokecolor=:black, strokewidth= 0.5,
            colormap = :deep, colorrange = (0.0, 3),)
        hideydecorations!(ax_in)
        hidexdecorations!(ax_in; ticks=false, ticklabels = false)
        hidespines!(ax_in, :t, :r)
        xlims!(ax_in, 0, 3)
        ylims!(ax_in, 0, nothing)
        # ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

        cb = Colorbar(fig[2,1], plt; label = rich("GPP [Mt gC]", rich("HyFixK_PFT ($(year(tempo)))", font=:bold)),
            vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
        hidedecorations!(ax; grid=false)
        hidespines!(ax)
        Label(fig[1,1], "Globally\n $(round(_gpp_sum_g, digits=2)) Pg C",
            tellwidth=false, tellheight=false, halign=0.46, valign=0.25)
        save("./gpp_maps/PFT/gpp_FixK_PFT_sum_mean_$(year(tempo)).png", fig)
        # fig
    end
end

# ? from models ALL
ds_gpp_ALL = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/gpp_maps_FixK_ALL.zarr/"))
ds_gpp_μ_all = mapslices(mean, replace(ds_gpp_ALL["layer"][time= DateTime(2002) .. DateTime(2018)], 1.0f32=>missing), dims="time")

ds_gpp_μ_all_new = YAXArray(dims(ds_veg_p), ds_gpp_μ_all.data)

ds_gpp_all_mask = ds_gpp_μ_all_new .* ds_veg_p .* ds_area
ds_gpp_all_mask = readcubedata(ds_gpp_all_mask)

# ! filter after masks
to_hist_all = filter(!ismissing, ds_gpp_all_mask.data)
to_hist_all = filter(!isnan, to_hist_all)
# _g_sum = sum(to_hist_pft)./1e15

_g_sum_all = sum(to_hist_all[to_hist_all .>0])./1e15


with_theme(theme_latexfonts()) do
    fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
    ax = Axis(fig[1,1])
    ax_in = Axis(fig, bbox = BBox(20, 320, 115, 215), xticklabelsize = 18,
       yticklabelsize = 18)

    plt = heatmap!(ax, ds_gpp_all_mask[lat=-60 .. 90] ./1e12; # .+ 1e-10;
        colormap = :deep, 
        colorrange = (0.0, 3),
        highclip=:orangered,
        )
    # do inset density plot    
    density!(ax_in, to_hist_all ./1e12; color= :x, strokecolor=:black, strokewidth= 0.5,
        colormap = :deep, colorrange = (0.0, 3),)
    hideydecorations!(ax_in)
    hidexdecorations!(ax_in; ticks=false, ticklabels = false)
    hidespines!(ax_in, :t, :r)
    xlims!(ax_in, 0, 3)
    ylims!(ax_in, 0, nothing)
    # ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

    cb = Colorbar(fig[2,1], plt; label = rich("GPP [Mt gC]", rich(" HyFixK_ALL (2002-2017)", font=:bold)),
        vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
    hidedecorations!(ax; grid=false)
    hidespines!(ax)
    Label(fig[1,1], "Globally\n $(round(_g_sum_all, digits=2)) Pg C",
        tellwidth=false, tellheight=false, halign=0.46, valign=0.25)
    mkpath("./gpp_maps/ALL/")
    save("./gpp_maps/ALL/gpp_FixK_ALL_sum_mean_yearly_2002-2017.png", fig)
    fig
end




# for each year
ds_gpp_ALL = open_dataset(joinpath(@__DIR__, "$(getSindbadDataDepot())/gpp_maps_FixK_ALL.zarr/"))
ds_gpp_ALL = replace(ds_gpp_ALL["layer"], 1.0f32=>missing)

_gpp_all_sums = Float64[]

for tempo in ds_gpp_ALL.time
    ds_gpp_all_year = ds_gpp_ALL[time=At(tempo)]

    ds_gpp_y_all_new = YAXArray(dims(ds_veg_p), ds_gpp_all_year.data)

    ds_gpp_y_mask = ds_gpp_y_all_new .* ds_veg_p .* ds_area
    ds_gpp_y_mask = readcubedata(ds_gpp_y_mask)

    to_hist_all = filter(!ismissing, ds_gpp_y_mask.data)
    to_hist_all = filter(!isnan, to_hist_all)

    _gpp_sum_g = sum(to_hist_all[to_hist_all .>0])./1e15
    push!(_gpp_all_sums, _gpp_sum_g)

    with_theme(theme_latexfonts()) do
        fig = Figure(; figure_padding=(10,10,40,10), size = (1200,640), fontsize=24)
        ax = Axis(fig[1,1])
        ax_in = Axis(fig, bbox = BBox(20, 320, 115, 215), xticklabelsize = 18,
        yticklabelsize = 18)
        plt = heatmap!(ax, ds_gpp_y_mask[lat=-60 .. 90] ./1e12; # .+ 1e-10;
            colormap = :deep, 
            #colorscale=log10,
            colorrange = (0.0, 3),
            lowclip=:orange,
            highclip=:orangered,
            )
        # do inset density plot    
        density!(ax_in, to_hist_all ./1e12; color= :x, strokecolor=:black, strokewidth= 0.5,
            colormap = :deep, colorrange = (0.0, 3),)
        hideydecorations!(ax_in)
        hidexdecorations!(ax_in; ticks=false, ticklabels = false)
        hidespines!(ax_in, :t, :r)
        xlims!(ax_in, 0, 3)
        ylims!(ax_in, 0, nothing)
        # ax_in.xticks = ([0, 1500, 3000], string.([0, 1500, 3000]))

        cb = Colorbar(fig[2,1], plt; label = rich("GPP [Mt gC]", rich("HyFixK_PFT ($(year(tempo)))", font=:bold)),
            vertical=false, width=Relative(0.65), flipaxis=false, labelpadding=-85)
        hidedecorations!(ax; grid=false)
        hidespines!(ax)
        Label(fig[1,1], "Globally\n $(round(_gpp_sum_g, digits=2)) Pg C",
            tellwidth=false, tellheight=false, halign=0.46, valign=0.25)

        save("./gpp_maps/ALL/gpp_FixK_ALL_sum_mean_$(year(tempo)).png", fig)
        # fig
    end
end

# ! yearly dots
using JLD2
xBase_gpp = load(joinpath(@__DIR__, "Fluxcom_X_BASE_GPP_global.jld2"))

my_markers = [:circle, :rect, :utriangle, :dtriangle, :diamond,
    :pentagon, :cross, :xcross]

with_theme(theme_light()) do
    ms = 15

    fig = Figure(; size = (1200, 600))
    ax = Axis(fig[1,1]; ylabel = "Pg C", xlabel="year")
    scatterlines!(ax, Array(year.(xBase_gpp["time"]))[2:17], _gpp_pft_sums[1:16];
        label = "VegLand: HyFixK_PFT", markersize=ms, marker=my_markers[1])
    scatterlines!(ax, Array(year.(xBase_gpp["time"]))[2:17], _gpp_all_sums[1:16];
        label = "VegLand: HyFixK_ALL",  markersize=ms, marker=my_markers[2])
    scatterlines!(ax, Array(year.(xBase_gpp["time"]))[2:17], xBase_gpp["gpp_area_veg"][1:16];
        label = "VegLand: X-Base",  markersize=ms, marker=my_markers[3])
    scatterlines!(ax, Array(year.(xBase_gpp["time"]))[2:17], xBase_gpp["gpp_area"][1:16];
        label = "X-Base", markersize=ms, marker=my_markers[4])

    Legend(fig[0,1], ax, tellheight=true, tellwidth=false, nbanks=4)
    ax.xticks = 2002:2017
    save("./gpp_maps/comparisons_globally.png", fig)
    fig
end