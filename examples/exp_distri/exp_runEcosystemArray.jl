using SindbadExperiment
toggleStackTraceNT()
experiment_json = "../exp_distri/settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupInfo(info);

forcing = getForcing(info);
forc = (; Pair.(forcing.variables, forcing.data)...);

#observations = getObservation(info, forcing.helpers);

obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

run_helpers = prepTEM(forcing, info);

@time runTEM!(info.tem.models.forward,
    run_helpers.loc_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)

#@time output_default = runExperimentForward(experiment_json);
#@time out_params = runExperimentOpti(experiment_json);

using SindbadVisuals

tempo = string.(forc.Tair.time);
sites_f = forc.Tair.site
out_names = info.optimization.observational_constraints
op = (; data=run_helpers.output_array);

with_theme(theme_ggplot2()) do 
    plot_output(op, out_names, sites_f, sites_f, tempo)
end

using AxisKeys

ks = keys(forc)
for k in keys(forc)
    if in(:time, AxisKeys.dimnames(forc[k]))
        println("yes")
    end
end

function split_variables(nt_forcing)
    ks = keys(nt_forcing)
    vars_time = Symbol[]
    vars_pools = Symbol[]
    for k in ks
        if in(:depth_soilGrids, AxisKeys.dimnames(nt_forcing[k]))
            push!(vars_pools, k)
        elseif in(:time, AxisKeys.dimnames(nt_forcing[k]))
            push!(vars_time, k)
        end
    end
    s_time = nt_forcing[vars_time[1]].time |> length
    s_depth = nt_forcing[vars_pools[1]].depth_soilGrids |> length 
    return (; s_time, vars_time), (; s_depth, vars_pools)
end

info_time, info_pools = split_variables(forc);

alloc_atime = [zeros(info_time.s_time, 1) .+ randn(info_time.s_time,) for _ in 1:length(info_time.vars_time)]
alloc_atime = Observable.(alloc_atime);

alloc_pools = [zeros(info_pools.s_depth, 1) .+ randn(info_pools.s_depth,) for _ in 1:length(info_pools.vars_pools)]
alloc_pools = Observable.(alloc_pools);

#heatmap(rand(10,1))

using GLMakie, Colors

function sindbad_board(output, out_names, site_names, tempo)

    f = Figure(; resolution=(1200, 600))

    subgl_left = GridLayout()
    axs_l = [Axis(f) for i in 1:11]
    subgl_left[1:11, 1] = axs_l
    [heatmap!(axs_l[i], alloc_atime[i]) for i in 1:length(info_time.vars_time)]

    subgl_right = GridLayout()
    axs_r =  [Axis(f) for i in 1:4]
    subgl_right[1:4, 1] = axs_r
    [heatmap!(axs_r[i], alloc_pools[i]) for i in 1:length(info_pools.vars_pools)]

    f.layout[1, 1] = subgl_left
    f.layout[1, 2] = subgl_right

    hidedecorations!.(axs_l)
    hidespines!.(axs_l)
    rowgap!(subgl_left, 0.5)

    hidedecorations!.(axs_r)
    hidespines!.(axs_r)
    rowgap!(subgl_right, 0.5)

    menu = Menu(f;
        options=out_names,
        cell_color_hover=RGB(0.7, 0.3, 0.25),
        cell_color_active=RGB(0.2, 0.3, 0.5)
        )
    menu_sites = Menu(f;
        options=site_names,
        )

    toggle_fix = Toggle(f, active = false)
    label_fix = Label(f, "Fix limits")

    ax = Axis(fig[2:4, 1])

    f[2, 2] = vgrid!(Label(f, "Variables"; width=nothing, font=:bold, fontsize=18,
                color=:orangered),
            menu;
            tellheight=false,
            width=150,
            valign=:top)

    f[3, 2] = vgrid!(Label(f, "Site"; width=nothing, font=:bold, fontsize=18,color=:dodgerblue),
        menu_sites;
        tellheight=false,
        width=150,
        valign=:top)

    f[4, 2] = grid!(hcat(toggle_fix, label_fix), tellheight = false)

    colsize!(f.layout,  1, Relative(7/8))

    f
end

sindbad_board()

for i in 1:11
    alloc_atime[i][] = randn(info_time.s_time,1)
    sleep(0.05)
end
f
