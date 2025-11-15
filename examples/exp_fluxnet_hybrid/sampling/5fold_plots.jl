
# activate project's environment and develop the package
using Pkg
Pkg.activate("examples/exp_fluxnet_hybrid/sampling")
Pkg.add(["MLUtils", "YAXArrays", "StatsBase", "Zarr", "JLD2", "GLMakie"])
Pkg.instantiate()

using MLUtils
using StatsBase
using YAXArrays
using Zarr
using JLD2
using GLMakie
GLMakie.activate!()
#! load folds
file_folds = load(joinpath(@__DIR__, "nfolds_sites_indices.jld2"))

function getPFTsite(set_names, set_pfts)
    return set_pfts[findfirst(site_name, set_names)]
end

function countmapPFTs(x)
    x_counts = countmap(x)
    x_keys = collect(keys(x_counts))
    x_vals = collect(values(x_counts))
    return x_counts, x_keys, x_vals
end

# get all PFTs from dataset
ds = open_dataset(joinpath(@__DIR__, "../../data/FLUXNET_v2023_12_1D.zarr"))
ds.properties["SITE_ID"][[98, 99, 100, 137, 138]]
# ! update PFTs categories, original ones are not up to date!
ds.properties["PFT"][[98, 99, 100, 137, 138]] .= ["WET", "WET", "GRA", "WET", "SNO"] 
updatePFTs = ds.properties["PFT"]


# ? site names
site_names = ds.site.val

function get_fold_names(x_fold_set, site_names, updatePFTs; color=:black)
    set_pfts = updatePFTs[x_fold_set]
    fold_names = site_names[x_fold_set]

    x_counts, x_keys, x_vals = countmapPFTs(set_pfts)
    px = sortperm(x_keys)
    u_pfts = unique(set_pfts)
    indx_names = [findall(x->x==p, set_pfts) for p in u_pfts]

    dict_names = Dict(u_pfts .=> indx_names)

    box_colors = repeat([color], length(u_pfts))

    return x_vals, px, x_keys, fold_names, dict_names, box_colors, x_counts
end

using CairoMakie
CairoMakie.activate!()
# load fold
for _nfold in 1:5
    xtrain, xval, xtest = file_folds["unfold_training"][_nfold], file_folds["unfold_validation"][_nfold], file_folds["unfold_tests"][_nfold]
    with_theme(theme_latexfonts()) do 
        fig = Figure(; size=(1200, 1400), fontsize=24)

        x_vals, px, x_keys, fold_names, dict_names, box_colors, x_counts = get_fold_names(xtest, site_names, updatePFTs)
        x_vals_test = x_vals

        ax = Axis(fig[1,1]; xgridstyle=:dash, ygridstyle=:dash)
        # ax_gl = GridLayout(fig[2,1]; xgridstyle=:dash, ygridstyle=:dash)

        barplot!(ax, x_vals[px]; color=:transparent, strokewidth=0.65, strokecolor=:dodgerblue)
        text!(ax, Point2f.(1:length(x_keys), x_vals[px]), text=string.(x_vals[px]),
            align = (:center, :bottom), fontsize=24)

        for (i, k) in enumerate(x_keys[px])
            text!(ax, [i], [x_vals[px][i]]; text= join(fold_names[dict_names[k]], "\n"), color=:grey25,
                align=(:center, 1.1), fontsize = 16)
        end
        ax.xticks = (1:length(x_keys), x_keys[px])
        hidedecorations!(ax, grid=false)
        ylims!(ax, -0.15, 12)
        hidespines!(ax)

        # validation
        x_vals, px, x_keys, fold_names, dict_names, box_colors, x_counts = get_fold_names(xval, site_names, updatePFTs; color=:tomato)
        x_vals_val = x_vals

        ax = Axis(fig[2,1]; xgridstyle=:dash, ygridstyle=:dash)
        # ax_gl = GridLayout(fig[2,1]; xgridstyle=:dash, ygridstyle=:dash)

        barplot!(ax, x_vals[px]; color=:transparent, strokewidth=0.65, strokecolor=:tomato)
        text!(ax, Point2f.(1:length(x_keys), x_vals[px]), text=string.(x_vals[px]),
            align = (:center, :bottom), fontsize=24)

        for (i, k) in enumerate(x_keys[px])
            text!(ax, [i], [x_vals[px][i]]; text= join(fold_names[dict_names[k]], "\n"), color=:grey25,
                align=(:center, 1.1), fontsize = 16)
        end
        ax.xticks = (1:length(x_keys), x_keys[px])
        hidedecorations!(ax, grid=false)
        ylims!(ax, -0.15, 5)
        hidespines!(ax)
        
        # trainining
        x_vals, px, x_keys, fold_names, dict_names, box_colors, x_counts = get_fold_names(xtrain, site_names, updatePFTs; color=:tomato)
        x_vals_train = x_vals

        ax = Axis(fig[3,1]; xgridstyle=:dash, ygridstyle=:dash)

        barplot!(ax, x_vals[px]; color=:transparent, strokewidth=0.65, strokecolor=:black)
        text!(ax, Point2f.(1:length(x_keys), x_vals[px]), text=string.(x_vals[px]),
            align = (:center, :bottom), fontsize=24)

        for (i, k) in enumerate(x_keys[px])
            text!(ax, [i], [x_vals[px][i]]; text= join(fold_names[dict_names[k]], "\n"), color=:grey25,
                align=(:center, 1.05), fontsize = 14)
        end
        ax.xticks = (1:length(x_keys), x_keys[px])
        hideydecorations!(ax, grid=false)
        ylims!(ax, -1, 36)
        hidespines!(ax)
        rowsize!(fig.layout, 2, Auto(0.5))
        rowsize!(fig.layout, 3, Auto(1.5))
        Label(fig[1,1], "Fold $(_nfold)", tellwidth=false, tellheight=false, halign=0.98, valign=1, color=:grey10, font=:bold)
        Label(fig[1,1], "Test ($(sum(x_vals_test)))", tellwidth=false, tellheight=false, halign=0.0, valign=0.9, color=:dodgerblue, font=:bold)
        Label(fig[2,1], "Validation ($(sum(x_vals_val)))", tellwidth=false, tellheight=false, halign=0.0, valign=0.9, color=:tomato, font=:bold)
        Label(fig[3,1], "Training ($(sum(x_vals_train)))", tellwidth=false, tellheight=false, halign=0.0, valign=0.9, color=:grey25, font=:bold)
        save(joinpath(@__DIR__, "../../../../fluxnet_hybrid_plots/fold_$(_nfold)_names_counts.pdf"), fig)
        fig 
    end
end
