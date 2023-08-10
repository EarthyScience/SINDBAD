using Revise
using SindbadTEM
using Plots
toggleStackTraceNT()

experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"
for tj ∈ (10, 100, 1000, 10000)
    # tj = 10000
    replace_info = Dict("spinup.differential_eqn.time_jump" => tj,
        "spinup.differential_eqn.relative_tolerance" => 1e-2,
        "spinup.differential_eqn.absolute_tolerance" => 1,
        "experiment.exe_rules.model_array_type" => "array",
        "experiment.flags.debug_model" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupInfo(info)
    forcing = getForcing(info)




    forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, forcing_one_timestep =
        prepTEM(forcing, info)

    loc_forcing, loc_output = getLocData(output_array, forcing_nt_array, loc_space_maps[1])

    spinupforc = :day_msc
    sel_forcing = getSpinupForcing(loc_forcing, info.tem.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, info.tem)

    land_init = deepcopy(land_init_space[1])
    land_type = typeof(land_init)
    sel_pool = :cEco

    spinup_models = info.tem.models.forward[info.tem.models.is_spinup]
    plt = plot(; legend=:outerbottom, legendcolumns=3, yscale=:log10, size=(2000, 1000))

    plot!(getfield(land_init.pools, sel_pool);
        linewidth=5,
        title="Steady State Solution - jump => $(tj)",
        xaxis="Pool Turnover",
        yaxis="C",
        label="Init",
        yscale=:log10)

    sp = :ODE_Tsit5
    @show "ODE_Init"
    @time out_sp_ode = SindbadTEM.runSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        deepcopy(land_init),
        info.tem.helpers,
        info.tem.spinup,
        land_type,
        forcing_one_timestep,
        Val(sp))
    out_sp_ode_init = deepcopy(out_sp_ode)

    @show "Exp_Init"
    sp = :spinup
    out_sp_exp = land_init
    @time for nl ∈ 1:Int(info.tem.spinup.differential_eqn.time_jump)
        out_sp_exp = SindbadTEM.runSpinup(spinup_models,
            getfield(spinup_forcing, spinupforc),
            deepcopy(out_sp_exp),
            info.tem.helpers,
            info.tem.spinup,
            land_type,
            forcing_one_timestep,
            Val(sp))
    end
    out_sp_exp_init = deepcopy(out_sp_exp)

    sp = :ODE_Tsit5
    @show "ODE_Exp"
    @time out_sp_ode_exp = SindbadTEM.runSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        deepcopy(out_sp_exp),
        info.tem.helpers,
        info.tem.spinup,
        land_type,
        forcing_one_timestep,
        Val(sp))

    @show "Exp_ODE"
    sp = :spinup
    out_sp_exp_ode = out_sp_ode
    @time for nl ∈ 1:Int(info.tem.spinup.differential_eqn.time_jump)
        out_sp_exp_ode = SindbadTEM.runSpinup(spinup_models,
            getfield(spinup_forcing, spinupforc),
            deepcopy(out_sp_exp_ode),
            info.tem.helpers,
            info.tem.spinup,
            land_type,
            forcing_one_timestep,
            Val(sp))
    end

    plot!(getfield(out_sp_ode_init.pools, sel_pool); linewidth=5, label="ODE_Init", yscale=:log10) # legend=false
    plot!(getfield(out_sp_ode_exp.pools, sel_pool); linewidth=5, label="ODE_Exp", yscale=:log10) # legend=false
    plot!(getfield(out_sp_exp_init.pools, sel_pool);
        linewidth=5,
        ls=:dash,
        label="Exp_Init",
        yscale=:log10) # legend=false
    plot!(getfield(out_sp_exp_ode.pools, sel_pool);
        linewidth=5,
        ls=:dash,
        label="Exp_ODE",
        yscale=:log10) # legend=false

    using NLsolve, ComponentArrays

    struct Spinupper{M,F,T,I,L,O}
        models::M
        forcing::F
        tem_helpers::T
        land_init::I
        land_type::L
        forcing_one_timestep::O
    end

    function (s::Spinupper)(pout, p)
        pout .= exp.(p)# .* s.pooldiff
        # s.land_init.pools.TWS .= pout.TWS
        s.land_init.pools.cEco .= pout.cEco
        update_init = timeLoopTEMSpinup(s.models, s.forcing, s.land_init, s.tem_helpers, s.land_type,
            s.forcing_one_timestep)
        # pout.TWS .= update_init.pools.TWS
        pout.cEco .= update_init.pools.cEco
        pout .= log.(pout)# ./ s.pooldiff
        return nothing
        # pout .= exp.(p)# .* s.pooldiff
        # tmp = s.land_init.pools.TWS;
        # helpers = s.tem_helpers;

        # @rep_vec tmp => pout.TWS
        # s = @set s.land_init.pools.TWS = tmp

        # tmp = s.land_init.pools.cEco
        # s = @set s.land_init.pools.cEco = tmp

        # @rep_vec tmp => pout.cEco
        # s = @set s.land_init.pools.cEco = tmp

        # update_init = timeLoopTEMSpinup(s.models, s.forcing, s.land_init, s.tem_helpers, s.land_type, s.forcing_one_timestep)

        # pout = @set pout.TWS = update_init.pools.TWS
        # pout = @set pout.cEco = update_init.pools.cEco
        # pout .= log.(pout)# ./ s.pooldiff
    end

    function runSpinup(spinup_models,
        spinup_forcing,
        land_init,
        tem_helpers,
        _,
        land_type,
        forcing_one_timestep,
        ::Val{:nlsolve})
        s = Spinupper(spinup_models, spinup_forcing, tem_helpers, deepcopy(land_init), land_type, forcing_one_timestep)
        mypools = ComponentArray((
            cEco = deepcopy(land_init.pools.cEco)))
        # mypools = ComponentArray((TWS=deepcopy(land_init.pools.TWS),
        # cEco=deepcopy(land_init.pools.cEco)))
        mypools .= log.(mypools)
        r = fixedpoint(s, mypools; method=:trust_region)

        res = exp.(r.zero)
        li = deepcopy(s.land_init)
        cEco = res.cEco
        # TWS = res.TWS
        @pack_land cEco => li.pools
        # @pack_land TWS => li.pools
        return li
    end

    @show "NL_solve"
    @time out_sp_nl = runSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        deepcopy(land_init),
        info.tem.helpers,
        info.tem.spinup,
        land_type,
        forcing_one_timestep,
        Val(:nlsolve))

    xtl = land_init.cCycleBase.c_τ_eco
    xtname = info.tem.helpers.pools.components.cEco
    plot!(getfield(out_sp_nl.pools, sel_pool);
        linewidth=5,
        ls=:dot,
        label="NL_Solve",
        xticks=(1:length(xtl), string.(xtname) .* "\n" .* string.(xtl)),
        rotation=45) # legend=false

    @show "Exp_NL"
    sp = :spinup
    out_sp_exp_nl = out_sp_nl
    @time for nl ∈ 1:Int(info.tem.spinup.differential_eqn.time_jump)
        out_sp_exp_nl = SindbadTEM.runSpinup(spinup_models,
            getfield(spinup_forcing, spinupforc),
            deepcopy(out_sp_exp_nl),
            info.tem.helpers,
            info.tem.spinup,
            land_type,
            forcing_one_timestep,
            Val(sp))
    end
    plot!(getfield(out_sp_exp_nl.pools, sel_pool);
        linewidth=5,
        ls=:dash,
        label="Exp_NL",
        yscale=:log10) # legend=false

    savefig("comp_methods_eachpool_$(string(sel_pool))_tj-$(tj).png")
end