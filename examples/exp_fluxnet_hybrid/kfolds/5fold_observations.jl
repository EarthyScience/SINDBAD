using GLMakie
using GLMakie.Colors
using StatsBase
using SindbadData
using SindbadData.DimensionalData
using SindbadData.AxisKeys
using SindbadData.YAXArrays
using SindbadTEM
using SindbadML
using SindbadML.JLD2
using ProgressMeter
include("../load_covariates.jl")

# ? do observations now

function countmapPFTs(x)
    x_counts = countmap(x)
    x_keys = collect(keys(x_counts))
    x_vals = collect(values(x_counts))
    return x_counts, x_keys, x_vals
end

file_folds = load(joinpath(@__DIR__, "../nfolds_sites_indices.jld2"))

_nfold = 1
xtrain, xval, xtest = file_folds["unfold_training"][_nfold], file_folds["unfold_validation"][_nfold], file_folds["unfold_tests"][_nfold]

# get all PFTs from dataset
ds = open_dataset(joinpath(@__DIR__, "../../data/FLUXNET_v2023_12_1D.zarr"))
ds.properties["PFT"][[98, 99, 100, 137, 138]] .= ["WET", "WET", "GRA", "WET", "SNO"]
updatePFTs = ds.properties["PFT"]
# ? site names
site_names = ds.site.val
test_pfts = updatePFTs[xtest]
test_names = site_names[xtest]

x_counts, x_keys, x_vals = countmapPFTs(test_pfts)
px = sortperm(x_keys)
u_pfts = unique(test_pfts)
indx_names = [findall(x->x==p, test_pfts) for p in u_pfts]

dict_names = Dict(u_pfts .=> indx_names)

box_colors = repeat([:black], length(u_pfts))

function getPFTsite(set_names, set_pfts)
    return set_pfts[findfirst(site_name, set_names)]
end

with_theme() do 
    fig = Figure(; size=(1200, 600), fontsize=18)
    ax = Axis(fig[1,1]; xgridstyle=:dash, ygridstyle=:dash)
    # ax_gl = GridLayout(fig[2,1]; xgridstyle=:dash, ygridstyle=:dash)

    barplot!(ax, x_vals[px]; color=:transparent, strokewidth=0.65)
    for (i, k) in enumerate(x_keys[px])
        text!(ax, [i], [x_vals[px][i]]; text= join(test_names[dict_names[k]], "\n"), color=:black,
            align=(:center, 1.1), fontsize = 16)
    end
    ax.xticks = (1:length(x_keys), x_keys[px])

    ylims!(ax, -0.15, 9.5)
    hidespines!(ax)
    Label(fig[1,1], "Test split, fold 1", tellwidth=false, tellheight=false,
        halign=1, valign=1, color=:grey25, font=:bold)
    fig 
end

# ? observations
experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"
# for remote node
replace_info = Dict()
info = getExperimentInfo(experiment_json; replace_info=replace_info);
selected_models = info.models.forward

table_parameters = info.optimization.table_parameters;

param_to_index = getParameterIndices(selected_models, table_parameters);
forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
lines(observations.data[1](;site="AR-SLu"))

# f_no_time = [:f_clay, :f_orgm, :f_sand, :f_silt, :f_tree_frac, :f_frac_vegetation, :f_pft]
# f_time = setdiff(forcing.variables, f_no_time)
obs_time = [:gpp, :nee, :reco, :transpiration, :evapotranspiration, :agb, :ndvi]
obs_indx = Dict(observations.variables .=> 1:length(observations.variables))
line_colors = resample_cmap(:tol_muted, 10)

function get_name_units_obs(info_f_vars, _var)
    _unit_data = getproperty(getproperty(info_f_vars, _var), :data)
    _unit = getproperty(_unit_data, :sindbad_unit)
    _standard_name = getproperty(_unit_data, :standard_name)
    return _standard_name, _unit
end

_standard_name, _unit = get_name_units_obs(info.settings.optimization.observations.variables, :ndvi)

with_theme() do
    _site_name = Observable(test_names[1])
    
    fig = Figure(; size=(1200, 1400), fontsize=18)
    menu = Menu(fig, options = test_names, fontsize=16)

    ax = Axis(fig[1,1]; xgridstyle=:dash, ygridstyle=:dash)
    ax_gl = GridLayout(fig[2,1]; xgridstyle=:dash, ygridstyle=:dash)
    [Box(ax_gl[r, 1:7], color=(line_colors[r], 0.1), strokewidth=0) for r in eachindex(obs_time)]

    ax_t = [Axis(ax_gl[r, 1:7], ylabel="", ylabelrotation = 0,
        yticks = WilkinsonTicks(2), #xticks = WilkinsonTicks(2),
        # backgroundcolor = :orange,
        xticklabelcolor=:orangered4, xgridstyle=:dash, ygridstyle=:dash) for r in eachindex(obs_time)]

    barplot!(ax, x_vals[px]; color=:transparent, strokewidth=0.65)

    for (i, k) in enumerate(x_keys[px])
        text!(ax, [i], [x_vals[px][i]]; text= join(test_names[dict_names[k]], "\n"), color=:black,
            align=(:center, 1.1), fontsize = 16)
    end

    for (i, obs_var) in enumerate(obs_time)
        _name, _units = get_name_units_obs(info.settings.optimization.observations.variables, obs_var)
        if isnothing(_units)
            _units = ""
        else
            _units = rich("\n[$(_units)]", color=:steelblue4, font=:regular)
        end
        scatter!(ax_t[i], observations.data[1].time, @lift(observations.data[obs_indx[obs_var]](; site= $(_site_name)));
            markersize=5, color=:black,
            )
        ax_t[i].ylabel = rich("$(obs_var)", font=:bold, _units)
    end
    # xlims!.(ax_t, observations.data[1].time[1], observations.data[1].time[end])
    linkxaxes!.(ax_t...)

    ax.xticks = (1:length(x_keys), x_keys[px])

    ylims!(ax, -0.15, 10.5)

    hidespines!(ax)

    Label(fig[1,1], "Test split, fold 1", tellwidth=false, tellheight=false,
        halign=1, valign=1, color=:grey25, font=:bold)
    Label(fig[1,1], @lift(rich($(_site_name), color=:steelblue, font=:bold)),
        tellwidth=false, tellheight=false,
        halign=0, valign=1,)
    hidespines!.(ax_t)
    hidexdecorations!.(ax_t[1:end-1]; grid=false)
    rowsize!(fig.layout, 2, Auto(2))
    rowgap!(ax_gl, 15)

    fig[1, 1, TopLeft()] = vgrid!(
        GLMakie.Label(fig, "", width = nothing),
        menu; tellheight = false, width = 100, tellwidth=false)
    on(menu.selection) do s
        _site_name[] = s
    end
    fig
end


