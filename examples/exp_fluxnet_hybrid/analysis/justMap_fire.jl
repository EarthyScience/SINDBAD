using CairoMakie
using GeoMakie
using Dates
using YAXArrays, Zarr
using DimensionalData
using LaTeXStrings
include("utils.jl")

CairoMakie.activate!()

path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_global_props_fire/Global_Seasfire/data/"
out_path = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_global_props_fire/Global_Seasfire/figure/"
out_path_maps = mkpath(joinpath(out_path, "maps"))

function get_var_names(path_variables)
    return map(name -> match(r"Global_(.+)\.zarr", name).captures[1], path_variables)
end

_variables = readdir(path_exp)
nameVariables = get_var_names(_variables)

name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))

tmp_path = joinpath(name_extensions["c_Fire_Flux"])
ds_tmp = open_dataset(tmp_path)["layer"]

function plotMap(name_extensions, var_name, out_path, t_index; colormap = :plasma)

    tmp_path = joinpath(name_extensions[var_name])
    ds_tmp = open_dataset(tmp_path)["layer"]
    lon = lookup(ds_tmp, :longitude)
    lat = lookup(ds_tmp, :latitude)
    tempo = lookup(ds_tmp, :Ti)
    # @show tempo[t_index]
    p_info = ds_tmp.properties["platform_info"]
    metadata = ds_tmp.properties

    plt=nothing
    fig = nothing
    ds_dims = dims(ds_tmp)
    idx_banner = 2
    if length(ds_dims) == 4
        idx_banner = 3
        l_dim = length(lookup(ds_tmp, ds_dims[1]))
        # n_col =  l_dim <= 4 ? 2 : 2
        n_row = l_dim <= 4 ? 2 : 4
        n_cbar = l_dim <= 4 ? 2 : 2:4
        date_align = l_dim <= 4 ? :center : :right
        
        pos_ij = [(i,j) for i in 1:2 for j in 1:n_row]

        # size_fig = l_dim <= 4 ? (900, 720) : (1440, 760)
        size_fig = (1440, 720)
        fig = Figure(figure_padding=(5, 5, 5,5); size = size_fig, fontsize= 22)

        # axs = [Axis(fig[p...], titlefont = :regular,
        #     xminorgridvisible=true, xminorticksvisible=true,
        #     yminorgridvisible=true, yminorticksvisible=true) for p in pos_ij]
        axs = [GeoAxis(fig[p...]; dest="+proj=hammer", titlefont = :regular,) for p in pos_ij]
        for ax_g in axs
            ax_g.xticklabelsvisible=false
            ax_g.yticklabelsvisible=false
            ax_g.ygridcolor = :grey20
            ax_g.xgridcolor = :grey20
            ax_g.ygridwidth = 0.1
            ax_g.xgridwidth = 0.15
            ax_g.yticks = -90:15:90
            ax_g.xticks = -180:30:180
        end

        for k in 1:min(l_dim, 8)
            if k ==1
                plt = heatmap!(axs[k], ds_tmp[k, t_index, :, :]; colormap,  ) #colorscale=log10) #  colorrange=(0,100)
            else
                plt = heatmap!(axs[k], ds_tmp[k, t_index, :, :]; colormap, ) # colorscale=log10)
            end

            # axs[k].title = "$(name(ds_dims[1])): $(k)"
            # axs[k].titlealign = :left
            Label(fig[pos_ij[k]...], "$(name(ds_dims[1])): $(k)",
                tellwidth=false, tellheight=false, valign=0.9, halign=0.1) 

            cb_v = Colorbar(fig[pos_ij[k]...], plt,
                width = Relative(0.65),
                tellwidth=false, 
                tellheight=false,
                valign=0,
                vertical=false,
                #halign=:right,
                # flipaxis=false,
                ticklabelsize=18,
                ticksize = 15, 
                # width = 15,
                height = 15,
                tickalign=1,
                spinewidth=0.5,
                minorticksvisible= true,
                # minortickalign=1,
                # minorticksize=15,
                # minortickcolor=:grey45,
                tickcolor = :black,
                topspinecolor = :grey15,
                bottomspinecolor = :grey15,
                leftspinecolor = :grey15,
                rightspinecolor = :grey15,
            )
            tlabels = cb_v.axis.ticklabels[]
            all_exp = get_exponents(tlabels)
            max_exp = Int(ceil(maximum(all_exp)))
            padding = l_dim <= 4 ? (-40, 0, 0, 0) : (-20, 0, 0, 0)

            if max_exp != 0
                cb_v_vals = cb_v.axis.tickvalues[]
                if max_exp > 0
                    cb_v.ticks = (cb_v_vals, string.(round.(cb_v_vals/10^max_exp, digits=3)))
                    Label(fig[pos_ij[k]...,], latexstring("\\times\\! 10^$(max_exp)"),
                        # halign=-1
                        tellwidth=false, tellheight=false, valign=0.0, halign=0.95,
                        # padding = padding,
                        )
                else
                    max_exp = Int(floor(minimum(all_exp)))

                    cb_v.ticks = (cb_v_vals, string.(round.(cb_v_vals*10^abs(max_exp), digits=3)))
                    Label(fig[pos_ij[k]...,], latexstring("\\times\\! 10^{$(max_exp)}"),
                        # halign=-1
                        tellwidth=false, tellheight=false, valign=0.0, halign=0.95,
                        # padding = padding,
                        )
                end
            end
        end
        # hidespines!.(axs)
        # hidedecorations!.(axs, ticks=true, grid=false, label=false)
        [delete!(axs[i]) for i in l_dim+1:length(axs)]

        #ax.ytickformat = "{:.1f}ᵒ"
        #ax.xtickformat = "{:.1f}ᵒ"
    elseif length(dims(ds_tmp)) == 3
        fig = Figure(figure_padding=(5, 5, 5,5); size = (1440, 720), fontsize= 18)

        # ax = Axis(fig[1, 1:2], titlefont = :regular,
        #     xminorgridvisible=true, xminorticksvisible=true,
        #     yminorgridvisible=true, yminorticksvisible=true)

        ax = GeoAxis(fig[1, 1:2]; dest="+proj=hammer")

        plt = surface!(ax, ds_tmp[1, :, :]; colormap)
        plt.shading = NoShading

        ax.xticklabelsvisible=false
        ax.limits[] = (-180, 180, -89.99, 89.99)
        ax.ygridcolor = :grey20
        ax.xgridcolor = :grey20
        ax.ygridwidth = 0.1
        ax.xgridwidth = 0.15
        ax.yticks = -90:15:90
        ax.xticks = -180:30:180

        # scatter!(ax, Point2f.(-150:30:150, 0); marker = :rect,
        #     markersize = Vec2f(55,35), color=(:grey90, 0.5))
        # text!(ax, Point2f.(-150:30:150, 0); text=string.(-150:30:150).*"ᵒ", align=(:center, :center))

        # ga.ygridstyle = :dash

        cb_v = Colorbar(fig[0, 1:2], plt,
            # labelpadding = (0,0,0,0),
            width = Relative(0.6), 
            vertical=false, halign=:right,
            flipaxis=false,
            ticklabelsize=18,
            ticksize = 15, 
            # width = 15,
            height = 15,
            tickalign=1,
            spinewidth=0.5,
            minorticksvisible= true,
            # minortickalign=1,
            # minorticksize=15,
            tickcolor = :black,
            # minortickcolor = :grey45,
            topspinecolor = :grey15,
            bottomspinecolor = :grey15,
            leftspinecolor = :grey15,
            rightspinecolor = :grey15,
        )
        tlabels = cb_v.axis.ticklabels[]
        all_exp = get_exponents(tlabels)
        # @show all_exp
        # @show tlabels
        # @show tlabels[1]
        max_exp = Int(ceil(maximum(all_exp)))
        if max_exp != 0
            cb_v_vals = cb_v.axis.tickvalues[]
            if max_exp > 0
                cb_v.ticks = (cb_v_vals, string.(round.(cb_v_vals/10^max_exp, digits=3)))
                Label(fig[0, 1:2, Right()], latexstring("\\times\\! 10^$(max_exp)"))
            else
                max_exp = Int(floor(minimum(all_exp)))
                cb_v.ticks = (cb_v_vals, string.(round.(cb_v_vals*10^abs(max_exp), digits=3)))
                Label(fig[0, 1:2, Right()], latexstring("\\times\\! 10^{$(max_exp)}")
                )
            end
        end

        # hidespines!(ax)
        # hidedecorations!(ax, ticks=false, grid=false, label=false)
        # ax.ytickformat = "{:.0f}ᵒ"
        # ax.xtickformat = "{:.0f}ᵒ"
    end
    # lines!(ax, GeoMakie.coastlines(); color = :orangered, linewidth=1.25)
    # xlims!(minimum(lon), maximum(lon))
    # ylims!(minimum(lat), maximum(lat))
    
    # Label(fig[0,1], rich("   $var_name [$(metadata["units"])]  ", font="CMU Serif",  
    #     rich("⋅  $(Date(tempo[t_index]))\n", color = :firebrick,
    #     rich("$(lstrip(join(split(metadata["long_name"], "_"), " ")))", color=:grey45,
    #     ))
    #     ),
    #     tellwidth=false, halign=:left)

    Box(fig[end+1,:], color=(0.1colorant"#232e41", 0.95), tellheight=false, tellwidth=false,
        #valign=0.97, 
        halign=0.5,
        width=1440, 
        height=30, cornerradius=10,)
    color_pinfo = :grey75
    color_pp = 1.15*colorant"tan1"
    Label(fig[end, :], rich("user ", color = color_pinfo,
        rich("⋅ $(p_info["simulation_by"])", color = color_pp),
        rich("  Sindbad.jl ", color = color_pinfo,
        rich("| v0.1.0", color = color_pp,
        rich("  julia ", color = color_pinfo,
        rich("⋅ $(p_info["julia"])", color = color_pp,
        rich("  experiment ", color = color_pinfo,
        rich("⋅ $(p_info["experiment"])", color = color_pp,
        rich("  domain ", color = color_pinfo,
        rich("⋅ $(p_info["domain"])", color = color_pp,
        rich("  machine ", color = color_pinfo,
        rich("⋅ $(p_info["machine"])", color = color_pp,
        rich("  date ", color = color_pinfo,
        rich("⋅ $(p_info["date"])", color = color_pp,
        )))))))))))), font="mono", fontsize=16,
        ), 
        tellwidth=false, halign=:center)
    if length(dims(ds_tmp)) == 3
        rowgap!(fig.layout, -10)
        colgap!(fig.layout, -15)
    else
        colgap!(fig.layout, -60)
        rowgap!(fig.layout, 0)
    end
    fig
    save(joinpath(out_path, var_name*"_$(Date(tempo[t_index]))_.png"), fig)
end

with_theme(theme_latexfonts()) do 
    plotMap(name_extensions, "c_Fire_k", out_path_maps, 180; colormap=:haline)
end

# with_theme(theme_latexfonts()) do 
#     plotMap(name_extensions, "c_allocation", out_path_maps, 1; colormap=:haline)
# end

# with_theme(theme_latexfonts()) do 
#     plotMap(name_extensions, "TWS", out_path_maps, 1; colormap=:haline)
# end

# with_theme(theme_latexfonts()) do 
#     plotMap(name_extensions, "c_eco_flow", out_path_maps, 1; colormap=:haline)
# end

# for v_name in nameVariables
#     with_theme(theme_latexfonts()) do 
#         plotMap(name_extensions, v_name, out_path_maps, 180; colormap=:haline)
#     end
# end

