using Revise
using SindbadTEM
using Plots
toggleStackTraceNT()

tjs = (1_000, 2_000, 5_000)#, 50_000, 100_000, 200_000)
# tjs = (1, 10, 20, 30, 40, 50, 100, 500, 1000)#, 10000)
expSol = zeros(8, length(tjs))
odeSol = zeros(8, length(tjs))
times = zeros(2, length(tjs))
cVeg_names = nothing
for (i, tj) ∈ enumerate(tjs)
    experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"

    replace_info = Dict("spinup.differential_eqn.time_jump" => tj,
        "spinup.differential_eqn.relative_tolerance" => 1e-2,
        "spinup.differential_eqn.absolute_tolerance" => 1,
        "experiment.exe_rules.model_array_type" => "static_array",
        "experiment.flags.debug_model" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupInfo(info)

    forcing = getForcing(info)
    # linit= createLandInit(info.tem);

    run_helpers = prepTEM(forcing, info);
    loc_forcings = run_helpers.loc_forcings;
    spinup_forcing = run_helpers.loc_spinup_forcings;
    forcing_one_timestep = run_helpers.forcing_one_timestep;
    output_array = run_helpers.output_array;
    loc_outputs = run_helpers.loc_outputs;
    land_init_space = run_helpers.land_init_space;
    tem_with_types = run_helpers.tem_with_types;


    spinupforc = :day_MSC
    sel_forcing = getfield(spinup_forcing, spinupforc)


    land_init = run_helpers.land_one
    sel_pool = :cEco

    spinup_models = tem_with_types.models.forward[tem_with_types.models.is_spinup]
    sp = ODETsit5()
    @show "ODE_Init", tj
    @time out_sp_ode = SindbadTEM.runSpinup(
        spinup_models,
        sel_forcing,
        forcing_one_timestep,
        tem_with_types.helpers,
        tem_with_types.spinup,
        deepcopy(land_init),
        sp)

    out_sp_ode_init = deepcopy(out_sp_ode)
    @show "Exp_Init", tj
    sp = selSpinupModels()
    out_sp_exp = land_init
    @time for nl ∈ 1:Int(tem_with_types.spinup.differential_eqn.time_jump)
        out_sp_exp = SindbadTEM.runSpinup(
            spinup_models,
            sel_forcing,
            forcing_one_timestep,
            deepcopy(out_sp_exp),
            tem_with_types.helpers,
            tem_with_types.spinup)
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
