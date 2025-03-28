using CairoMakie
using GeoMakie
using Dates
using YAXArrays, Zarr
using Statistics

CairoMakie.activate!()

path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_global_props/Global_Seasfire/data/"
out_path = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_global_props/Global_Seasfire/figure/"

out_path_regions = mkpath(joinpath(out_path, "regions"))

function get_var_names(path_variables)
    return map(name -> match(r"Global_(.+)\.zarr", name).captures[1], path_variables)
end

_variables = readdir(path_exp)
nameVariables = get_var_names(_variables)
name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))

tmp_path = joinpath(name_extensions["auto_respiration_f_airT"])
ds_tmp = open_dataset(tmp_path)["layer"]
# out_path = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_local/FLUXNET_Hybrid_seasfire/figure/"

set_theme!()

_region = known_regions["Asia"]

function plotLines(out_path, var_name, known_regions;
    t_index=1,
    region = nothing,
    lon_at = nothing, lat_at = nothing,
    colormap=:haline,
    )

    tmp_path = joinpath(name_extensions[var_name])
    ds_o = open_dataset(tmp_path)["layer"]
    tempo = lookup(ds_o, :Ti)
    ds_tmp = nothing
    if !isnothing(region)
        _region = known_regions[region]
        ds_tmp = ds_o[latitude = _region.lat, longitude = _region.lon]
    end

    lon_tmp = lookup(ds_tmp, :longitude)
    lat_tmp = lookup(ds_tmp, :latitude)

    if isnothing(lon_at)
        lon_at = mean(lon_tmp)
    end

    if isnothing(lat_at)
        lat_at = mean(lat_tmp)
    end

    ds_dims = dims(ds_tmp)
    if length(ds_dims) == 3
        p_info = ds_o.properties["platform_info"]
        metadata = ds_o.properties
        color_vlon = :black #:dodgerblue
        color_hlat = :chocolate1

        fig = Figure(figure_padding=(5, 50, 5,5); size = (1440, 760), fontsize= 20)
        ax_var = Axis(fig[1:2,1]; # aspect = DataAspect(),
            xminorgridvisible=true, xminorticksvisible=true,
            yminorgridvisible=true, yminorticksvisible=true,
            xticklabelcolor = color_hlat,
            xtickcolor = color_hlat,
            xminortickcolor = color_hlat,
            yticklabelcolor = color_vlon,
            ytickcolor = color_vlon,
            yminortickcolor = color_vlon
            )

        ax_lat = Axis(fig[1,2]; xminorgridvisible=true, xminorticksvisible=true,
            yminorgridvisible=true, yminorticksvisible=true,
            yticklabelcolor = color_hlat,
            ytickcolor = color_hlat,
            yminortickcolor = color_hlat
            )

        ax_lon = Axis(fig[2,2]; xminorgridvisible=true, xminorticksvisible=true,
            yminorgridvisible=true, yminorticksvisible=true,
            yticklabelcolor = color_vlon,
            ytickcolor = color_vlon,
            yminortickcolor = color_vlon
            )

        dd_lat = ds_tmp[latitude=Near(lat_at)]
        dd_lon = ds_tmp[longitude=Near(lon_at)]
        
        mx_lat = maximum(replace(x -> ismissing(x) || isnan(x) ? -Inf : x, dd_lat))
        mn_lat = minimum(replace(x -> ismissing(x) || isnan(x) ? Inf : x, dd_lat))
        mx_lon = maximum(replace(x -> ismissing(x) || isnan(x) ? -Inf : x, dd_lon))
        mn_lon = minimum(replace(x -> ismissing(x) || isnan(x) ? Inf : x, dd_lon))

        mx = max(mx_lat, mx_lon)
        mn = min(mn_lat, mn_lon)
        if mn == mx
            mx = mn + 0.001
        end
        colorrange = (mn, mx)
        @show colorrange

        plt_lat = heatmap!(ax_lat, dd_lat; colormap, colorrange)
        plt_lon = heatmap!(ax_lon, dd_lon; colormap, colorrange)
        plt = heatmap!(ax_var, ds_tmp[t_index, :, :]; colormap, colorrange)

        hlines!(ax_var, [lat_at]; color=color_hlat)
        vlines!(ax_var, [lon_at]; color=color_vlon) # :royalblue2

        Label(fig[0,1], rich("   $var_name [$(metadata["units"])]  ", font="CMU Serif",  
            rich("⋅  $(Date(tempo[t_index]))\n", color = :firebrick,
            rich("$(lstrip(join(split(metadata["long_name"], "_"), " ")))", color=:grey45,
            ))
            ),
            tellwidth=false, halign=:left)

        Colorbar(fig[0, 2], plt,
            width = Relative(0.95), vertical=false, halign=:right,
            ticksize = 15, height = 15,
            tickalign=1,
            spinewidth=0.5,
            minorticksvisible= true,
            tickcolor = :black,
            minortickcolor = :grey15,
            # spinecolor = :grey45,
            topspinecolor = :grey15,
            bottomspinecolor = :grey15,
            leftspinecolor = :grey15,
            rightspinecolor = :grey15,
        )
        ax_var.ytickformat = "{:.0f}ᵒ"
        ax_var.xtickformat = "{:.0f}ᵒ"

        ax_lon.ytickformat = "{:.0f}ᵒ"
        ax_lat.ytickformat = "{:.0f}ᵒ"

        linkxaxes!([ax_lon, ax_lat]...)
        hidespines!.([ax_var, ax_lon, ax_lat])
        hidexdecorations!(ax_lat, ticks=false,
            grid=false, minorgrid = false)

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
        
        n_path = mkpath(joinpath(out_path, region))

        save(joinpath(n_path, var_name*"_$(Date(tempo[t_index]))_.png"), fig)
    end
end

with_theme(theme_latexfonts()) do
    for v_name in nameVariables
        for r_key in keys(known_regions)
            plotLines(out_path_regions, v_name, known_regions;
            t_index=180,
            region = r_key,
            colormap= :delta #:linear_protanopic_deuteranopic_kbjyw_5_95_c25_n256
            )
        end
    end
end
