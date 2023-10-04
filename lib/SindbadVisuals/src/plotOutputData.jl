export plot_output

"""
    plot_output(output, out_names, cov_sites, sites_f, tempo)

"""
function plot_output(output, out_names, cov_sites, sites_f, tempo)
    #pair_names = output.variables
    #out_names = [p[2] for p in pair_names]
    snames = length(out_names)
    names_pair = Dict(out_names .=> 1:snames)
    cmap = resample_cmap(:ground_cover, snames)

    lentime = length(tempo)
    slice_dates = range(1, lentime, step=lentime ÷ 8)

    site_name = Observable(cov_sites[1])
    s = @lift(siteNameToID($site_name, sites_f)[1][2])

    var_index = Observable(1)
    #var_info = @lift(getVariableInfo(output.variables[$var_index], "day"))

    v_data = @lift(output.data[$var_index]);
    #s = Observable(9)
    v_site = @lift($v_data[:, 1, $s])
    v_name = @lift(out_names[$var_index])
    # obs_site = @lift(getproperty(obs, Symbol($v_name)))
    # data_site  = @lift($obs_site(site=$site_name))

    fig = Figure(; resolution=(1200, 600))
    menu = Menu(fig;
        options=out_names,
        cell_color_hover=RGB(0.7, 0.3, 0.25),
        cell_color_active=RGB(0.2, 0.3, 0.5))
    menu_sites = Menu(fig;
        options=cov_sites)

    toggle_fix = Toggle(fig, active = false)
    label_fix = Label(fig, "Fix limits")

    ax = Axis(fig[1:3, 1]; #ylabel = @lift("$($var_info["long_name"]) ($($var_info["units"]))"),
        ytickalign=1, xtickalign=1,
        yticksize =10, xticksize=10,
        xgridstyle = :dashdot,
        ygridstyle = :dashdot)

    plt = lines!(ax, v_site; color = cmap[1])
    #scatter!(ax, data_site; color =:black, markersize = 8)

    ax.xticks = (slice_dates, tempo[slice_dates])
    ax.xticklabelrotation = π / 4
    ax.xticklabelalign = (:right, :center)

    fig[1, 2] = vgrid!(Label(fig, "Variables"; width=nothing, font=:bold, fontsize=18,
            color=:orangered),
        menu;
        tellheight=false,
        width=150,
        valign=:top)

    fig[2, 2] = vgrid!(Label(fig, "Site"; width=nothing, font=:bold, fontsize=18,color=:dodgerblue),
        menu_sites;
        tellheight=false,
        width=150,
        valign=:top)

    fig[3, 2] = grid!(hcat(toggle_fix, label_fix), tellheight = false)

    on(menu_sites.selection) do s
        site_name[] = s
        return !toggle_fix.active[] ? autolimits!(ax) : nothing
    end

    on(menu.selection) do s
        idx = names_pair[s]
        var_index[] = idx
        plt.color[] = cmap[idx]
        return autolimits!(ax)
    end
    #connect!(to_fix, toggle_fix.active)
    fig
end

"""
    plot_output(output, obs, out_names, cov_sites, sites_f, tempo)

"""
function plot_output(output, obs, out_names, cov_sites, sites_f, tempo)
    #pair_names = output.variables
    #out_names = [p[2] for p in pair_names]
    snames = length(out_names)
    names_pair = Dict(out_names .=> 1:snames)
    cmap = resample_cmap(:ground_cover, snames)

    lentime = length(tempo)
    slice_dates = range(1, lentime, step=lentime ÷ 8)

    site_name = Observable(cov_sites[1])
    s = @lift(siteNameToID($site_name, sites_f)[1][2])

    var_index = Observable(1)
    #var_info = @lift(getVariableInfo(output.variables[$var_index], "day"))

    v_data = @lift(output.data[$var_index]);
    #s = Observable(9)
    v_site = @lift($v_data[:, 1, $s])
    v_name = @lift(out_names[$var_index])
    obs_site = @lift(getproperty(obs, Symbol($v_name)))
    data_site  = @lift($obs_site(site=$site_name))

    fig = Figure(; resolution=(1200, 600))
    menu = Menu(fig;
        options=out_names,
        cell_color_hover=RGB(0.7, 0.3, 0.25),
        cell_color_active=RGB(0.2, 0.3, 0.5))
    menu_sites = Menu(fig;
        options=cov_sites)

    toggle_fix = Toggle(fig, active = false)
    label_fix = Label(fig, "Fix limits")

    ax = Axis(fig[1:3, 1]; #ylabel = @lift("$($var_info["long_name"]) ($($var_info["units"]))"),
        ytickalign=1, xtickalign=1,
        yticksize =10, xticksize=10,
        xgridstyle = :dashdot,
        ygridstyle = :dashdot)

    plt = lines!(ax, v_site; color = cmap[1])
    scatter!(ax, data_site; color =(:grey50, 0.5), markersize = 8, strokewidth=0.5, strokecolor=:white)

    ax.xticks = (slice_dates, tempo[slice_dates])
    ax.xticklabelrotation = π / 4
    ax.xticklabelalign = (:right, :center)

    fig[1, 2] = vgrid!(Label(fig, "Variables"; width=nothing, font=:bold, fontsize=18,
            color=:orangered),
        menu;
        tellheight=false,
        width=150,
        valign=:top)

    fig[2, 2] = vgrid!(Label(fig, "Site"; width=nothing, font=:bold, fontsize=18,color=:dodgerblue),
        menu_sites;
        tellheight=false,
        width=150,
        valign=:top)

    fig[3, 2] = grid!(hcat(toggle_fix, label_fix), tellheight = false)

    on(menu_sites.selection) do s
        site_name[] = s
        return !toggle_fix.active[] ? autolimits!(ax) : nothing
    end

    on(menu.selection) do s
        idx = names_pair[s]
        var_index[] = idx
        plt.color[] = cmap[idx]
        return autolimits!(ax)
    end
    #connect!(to_fix, toggle_fix.active)
    fig
end