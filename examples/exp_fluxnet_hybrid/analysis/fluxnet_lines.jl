using CairoMakie
using GeoMakie
using Dates
using YAXArrays, Zarr
using Statistics
include("regions.jl")

CairoMakie.activate!()

# path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_fluxnet_local_fire/FLUXNET_Seasfire/data/"
# out_path = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_fluxnet_local_fire/FLUXNET_Seasfire/figure/"
path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_fluxnet_W/FLUXNET_WROASTED/data/"
out_path = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_fluxnet_W/FLUXNET_WROASTED/figure/"

out_path_regions = mkpath(joinpath(out_path, "fluxnet/lines"))

function get_var_names(path_variables)
    return map(name -> match(r"FLUXNET_(.+)\.zarr", name).captures[1], path_variables)
end

_variables = readdir(path_exp)
nameVariables = get_var_names(_variables)
name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))

# tmp_path = joinpath(name_extensions["auto_respiration_f_airT"])
tmp_path = joinpath(name_extensions["c_eco_flow"])

ds_tmp = open_dataset(tmp_path)["layer"]
site_name = ds_tmp.site

# out_path = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_local/FLUXNET_Hybrid_seasfire/figure/"

set_theme!()

# _region = known_regions["Asia"]

function plotFLUXNET(out_path, var_name; colormap=:haline, α = 1.0)
    tmp_path = joinpath(name_extensions[var_name])
    ds_o = open_dataset(tmp_path)["layer"]
    # tempo = lookup(ds_o, :Ti)
    ds_tmp = ds_o
    ds_dims = dims(ds_tmp)
    p_info = ds_o.properties["platform_info"]
    metadata = ds_o.properties

    if length(ds_dims) == 2
        
        fig = Figure(figure_padding=(5, 5, 5,5); size = (1440, 2400), fontsize= 20)
        ax_var = Axis(fig[1,1]; # aspect = DataAspect(),
            xminorgridvisible=true, xminorticksvisible=true,
            yminorgridvisible=true, yminorticksvisible=true,
            ylabel = "site"
            )

        # plt = heatmap!(ax_var, ds_tmp[:, :, 1]; colormap)
        mn = minimum(ds_tmp)
        mx = maximum(ds_tmp)
        d = mx - mn
        l_inc = 0
        for l in 1:100
            ds_l = ds_tmp[:,l]

            normed_data = map(ds_l) do x
                (x - mn)/(α*d) + l_inc
            end
            lines!(ax_var, normed_data; color=:black)
            text!(ax_var, DateTime("2018-06-01"), l_inc,  text= site_name[l],
                align = (:left, :center), offset = (-20, 0))
            l_inc += 1.1
        end
        # hideydecorations!(ax_var)

        Label(fig[0,1], rich("   $var_name [$(metadata["units"])]  \n", font="CMU Serif",  
            #rich("⋅  $(Date(tempo[t_index]))\n", color = :firebrick,
            rich("$(lstrip(join(split(metadata["long_name"], "_"), " ")))", color=:grey45,
            )
            ),
            tellwidth=false, halign=:left)

        hidespines!.([ax_var])
        hideydecorations!(ax_var)

        ylims!(-1, 110.0)
        
        xlims!(ax_var, DateTime("2000-01-01"), DateTime("2020-01-01"))


        Box(fig[end+1,:], color=(0.1colorant"#232e41", 0.95), tellheight=false, tellwidth=false,
                #valign=0.97, 
                # halign=0.5,
                # width=1400, 
                height=30, cornerradius=10,)
        color_pinfo = :grey75
        color_pp = 1.15*colorant"tan1"
        Label(fig[end, :], rich("user ", color = color_pinfo,
            rich("⋅ $(p_info["simulation_by"])", color = color_pp),
            rich("  SindbadCore.jl ", color = color_pinfo,
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
        
        save(joinpath(out_path, var_name*".png"), fig)
    end
end

function plotFLUXNETdepth(out_path, var_name; colormap=:haline)
    tmp_path = joinpath(name_extensions[var_name])
    ds_o = open_dataset(tmp_path)["layer"]
    # tempo = lookup(ds_o, :Ti)
    ds_tmp = ds_o
    ds_dims = dims(ds_tmp)
    p_info = ds_o.properties["platform_info"]
    metadata = ds_o.properties
    
    if length(ds_dims) == 3
        s_depth = size(ds_tmp, 2)
        @show s_depth
        @show size(ds_tmp)
        for d in 1:s_depth
            fig = Figure(figure_padding=(5, 5, 5,5); size = (1440, 1200), fontsize= 20)
            ax_var = Axis(fig[1,1]; # aspect = DataAspect(),
                xminorgridvisible=true, xminorticksvisible=true,
                yminorgridvisible=true, yminorticksvisible=true,
                ylabel = "site"
                )

            # plt = heatmap!(ax_var, ds_tmp[:,d,:, 1]; colormap)
            l_inc = 0
            for l in 1:100
                lines!(ax_var, ds_tmp[:,d, l] .+ l_inc; color=:black)
                # text!(ax_var, ds_tmp, text="a" )
                l_inc += 1.01*maximum(ds_tmp[:,d,l])
            end

            hidespines!.([ax_var])

            Label(fig[0,1], rich("   $var_name [$(metadata["units"])]  ", font="CMU Serif",  
                #rich("⋅  $(Date(tempo[t_index]))\n", color = :firebrick,
                rich("$(lstrip(join(split(metadata["long_name"], "_"), " ")))", color=:grey45,
                )
                ),
                tellwidth=false, halign=:left)

            Box(fig[end+1,:], color=(0.1colorant"#232e41", 0.95),
                    tellheight=false, tellwidth=false,
                    #valign=0.97, 
                    # halign=0.5,
                    # width=1400, 
                    height=30, cornerradius=10,)
            color_pinfo = :grey75
            color_pp = 1.15*colorant"tan1"
            Label(fig[end, :], rich("user ", color = color_pinfo,
                rich("⋅ $(p_info["simulation_by"])", color = color_pp),
                rich("  SindbadCore.jl ", color = color_pinfo,
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
            
            save(joinpath(out_path, var_name*"_depth_$(d)_.png"), fig)
        end
    end
end

with_theme(theme_latexfonts()) do
    for v_name in nameVariables[1:10]
            plotFLUXNET(out_path_regions, v_name;
            colormap= :plasma #:linear_protanopic_deuteranopic_kbjyw_5_95_c25_n256
            )
    end
end

with_theme(theme_latexfonts()) do
    for v_name in nameVariables[1:5]
            plotFLUXNETdepth(out_path_regions, v_name;
            colormap= :plasma #:linear_protanopic_deuteranopic_kbjyw_5_95_c25_n256
            )
    end
end
