using Revise
using Sindbad
using ForwardSindbad
using Plots
noStackTrace()

tjs = (1_000, 2_000, 5_000)#, 50_000, 100_000, 200_000)
# tjs = (1, 10, 20, 30, 40, 50, 100, 500, 1000)#, 10000)
expSol = zeros(8, length(tjs))
odeSol = zeros(8, length(tjs))
cInit = nothing
for (i, tj) ∈ enumerate(tjs)
    experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"

    replace_info = Dict("spinup.diffEq.timeJump" => tj,
        "spinup.diffEq.reltol" => 1e-2,
        "spinup.diffEq.abstol" => 1,
        "modelRun.rules.model_array_type" => "staticarray",
        "modelRun.flags.debugit" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupExperiment(info)

    info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))

    output = setupOutput(info)

    forc = getKeyedArrayFromYaxArray(forcing)
    # linit= createLandInit(info.tem);

    loc_space_maps,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one = prepRunEcosystem(output.data,
        output.land_init,
        info.tem.models.forward,
        forc,
        forcing.sizes,
        info.tem)

    loc_space_maps,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one = prepRunEcosystem(output.data,
        land_init_space[1],
        info.tem.models.forward,
        forc,
        forcing.sizes,
        info.tem)

    loc_forcing, loc_output = getLocData(output.data, forc, loc_space_maps[1])

    spinupforc = :recycleMSC
    sel_forcing = getSpinupForcing(loc_forcing, info.tem.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, info.tem)

    land_init = land_init_space[1]
    land_type = typeof(land_init)
    sel_pool = :cEco

    spinup_models = info.tem.models.forward[info.tem.models.is_spinup.==1]
    cInit = deepcopy(getfield(land_init.pools, sel_pool))
    sp = :ODE_DP5
    @show "ODE_Init", tj
    @time out_sp_ode = ForwardSindbad.doSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        deepcopy(land_init),
        info.tem.helpers,
        info.tem.spinup,
        land_type,
        f_one,
        Val(sp))

    out_sp_ode_init = deepcopy(out_sp_ode)
    @show "Exp_Init", tj
    sp = :spinup
    out_sp_exp = land_init
    @time for nl ∈ 1:Int(info.tem.spinup.diffEq.timeJump)
        out_sp_exp = ForwardSindbad.doSpinup(spinup_models,
            getfield(spinup_forcing, spinupforc),
            deepcopy(out_sp_exp),
            info.tem.helpers,
            info.tem.spinup,
            land_type,
            f_one,
            Val(sp))
    end
    out_sp_exp_init = deepcopy(out_sp_exp)
    expSol[:, i] = getfield(out_sp_ode_init.pools, sel_pool)
    odeSol[:, i] = getfield(out_sp_exp_init.pools, sel_pool)
end

a = 100 .* (odeSol .- expSol) ./ expSol

# all pools
plt = plot(; legend=:outerbottom, legendcolumns=3, yscale=:log10, xscale=:log10)
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
cpnames = info.pools.carbon.components.cEco;
for (i, cp) ∈ enumerate(cpnames)
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
