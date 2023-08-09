using Revise
using SindbadTEM
using Plots
noStackTrace()

tjs = (1_000, 2_000, 5_000)#, 50_000, 100_000, 200_000)
# tjs = (1, 10, 20, 30, 40, 50, 100, 500, 1000)#, 10000)
expSol = zeros(8, length(tjs))
odeSol = zeros(8, length(tjs))
cInit = nothing
times = zeros(2, length(tjs))
cVeg_names = nothing
for (i, tj) ∈ enumerate(tjs)
    experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"

    replace_info = Dict("spinup.differential_eqn.time_jump" => tj,
        "spinup.differential_eqn.relative_tolerance" => 1e-2,
        "spinup.differential_eqn.absolute_tolerance" => 1,
        "experiment.exe_rules.model_array_type" => "staticarray",
        "experiment.flags.debug_model" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupExperiment(info)

    forcing = getForcing(info)




    # linit= createLandInit(info.tem);

    loc_space_maps,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    tem_with_vals,
    forcing_one_timestep = prepTEM(forcing, info)

    loc_forcing, loc_output = getLocData(output_array, forcing_nt_array, loc_space_maps[1])

    spinupforc = :day_msc
    sel_forcing = getSpinupForcing(loc_forcing, tem_with_vals.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, tem_with_vals)

    land_init = land_init_space[1]
    land_type = typeof(land_init)
    sel_pool = :cEco

    spinup_models = tem_with_vals.models.forward[tem_with_vals.models.is_spinup]
    cInit = deepcopy(getfield(land_init.pools, sel_pool))
    sp = :ODE_Tsit5
    @show "ODE_Init", tj
    @time out_sp_ode = SindbadTEM.runSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        deepcopy(land_init),
        tem_with_vals.helpers,
        tem_with_vals.spinup,
        land_type,
        forcing_one_timestep,
        Val(sp))

    out_sp_ode_init = deepcopy(out_sp_ode)
    @show "Exp_Init", tj
    sp = :spinup
    out_sp_exp = land_init
    @time for nl ∈ 1:Int(tem_with_vals.spinup.differential_eqn.time_jump)
        out_sp_exp = SindbadTEM.runSpinup(spinup_models,
            getfield(spinup_forcing, spinupforc),
            deepcopy(out_sp_exp),
            tem_with_vals.helpers,
            tem_with_vals.spinup,
            land_type,
            forcing_one_timestep,
            Val(sp))
    end
    out_sp_exp_init = deepcopy(out_sp_exp)
    expSol[:, i] = getfield(out_sp_ode_init.pools, sel_pool)
    odeSol[:, i] = getfield(out_sp_exp_init.pools, sel_pool)
    cVeg_names = info.pools.carbon.components.cEco

end

a = 100 .* (odeSol .- expSol) ./ expSol

# all pools
plt = plot(; legend=:outerbottom, legendcolumns=3, yscale=:log10, xscale=:log10, size=(2000, 1000))
xlabel!("Explicit")
ylabel!("ODE")
markers = (:d, :hex, :circle, :x, :cross, :ltriangle, :rtriangle, :star5, :star4);
for c ∈ eachindex(tjs)
    plot!(expSol[:, c], odeSol[:, c]; lw=0, marker=markers[c], label=tjs[c])
end

x_lims = min.(minimum(expSol), minimum(odeSol)), max.(maximum(expSol), maximum(odeSol));
xlims!(x_lims);
plot!([x_lims...], [x_lims...]; color=:grey, label="1:1");
plt
savefig("scatter_allpool.png")

# one subplot per pool
pltall = [];
for (i, cp) ∈ enumerate(cVeg_names)
    p = plot(expSol[i, :], odeSol[i, :]; lw=0, marker=:o, size=(600, 900))
    title!("$(i): $(string(cp))")
    x_lims = min.(minimum(expSol[i, :]), minimum(odeSol[i, :])),
    max.(maximum(expSol[i, :]), maximum(odeSol[i, :]))
    xlims!(x_lims)
    plot!([x_lims...], [x_lims...]; color=:grey)
    plot!(; legend=nothing)
    push!(pltall, p)
end
plot(pltall...; layout=(4, 2))

savefig("scatter_eachpool.png")
