using Revise
using Sindbad
using ForwardSindbad
using Plots
using Accessors
noStackTrace()
using NLsolve, ComponentArrays

struct Spinup_TWS{M,F,T,I,L,O}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    land_type::L
    f_one::O
end



struct Spinup_cEco_TWS{M,F,T,I,L,O,TWS}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    land_type::L
    f_one::O
    TWS::TWS
end


struct Spinup_cEco{M,F,T,I,L,O}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    land_type::L
    f_one::O
end



function (TWS_spin::Spinup_TWS)(pout, p)
    land = TWS_spin.land
    helpers = TWS_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers

    TWS = land.pools.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem max(p[l], 𝟘) => (TWS, lc, :TWS)
    end
    @pack_land TWS => land.pools
    set_component_from_main_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
    update_init = loopTimeSpinup(TWS_spin.models, TWS_spin.forcing, land, TWS_spin.tem_helpers, TWS_spin.land_type, TWS_spin.f_one)
    pout .= update_init.pools.TWS
    return nothing
end



function (cEco_spin::Spinup_cEco)(pout, p)
    land = cEco_spin.land
    helpers = cEco_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers

    pout .= exp.(p)

    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    set_component_from_main_pool(land, helpers, helpers.pools.vals.self.cEco, helpers.pools.vals.all_components.cEco, helpers.pools.vals.zix.cEco)

    update_init = loopTimeSpinup(cEco_spin.models, cEco_spin.forcing, land, cEco_spin.tem_helpers, cEco_spin.land_type, cEco_spin.f_one)

    pout .= log.(update_init.pools.cEco)
    return nothing
end


function (cEco_TWS_spin::Spinup_cEco_TWS)(pout, p)
    land = cEco_TWS_spin.land
    helpers = cEco_TWS_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers

    pout .= exp.(p)

    @unpack_land 𝟘 ∈ helpers.numbers
    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    set_component_from_main_pool(land, helpers, helpers.pools.vals.self.cEco, helpers.pools.vals.all_components.cEco, helpers.pools.vals.zix.cEco)

    TWS = land.pools.TWS
    TWS_prev = cEco_TWS_spin.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem TWS_prev[l] => (TWS, lc, :TWS)
    end

    @pack_land TWS => land.pools
    set_component_from_main_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)

    update_init = loopTimeSpinup(cEco_TWS_spin.models, cEco_TWS_spin.forcing, land, cEco_TWS_spin.tem_helpers, cEco_TWS_spin.land_type, cEco_TWS_spin.f_one)

    pout .= log.(update_init.pools.cEco)
    cEco_TWS_spin.TWS .= update_init.pools.TWS
    return nothing
end


function doSpinup(spinup_models,
    spinup_forcing,
    land,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsove_fixedpoint_trustregion_TWS})
    TWS_spin = Spinup_TWS(spinup_models, spinup_forcing, tem_helpers, land, land_type, f_one)
    r = fixedpoint(TWS_spin, Vector(deepcopy(land.pools.TWS)); method=:trust_region)
    TWS = r.zero
    TWS = oftype(land.pools.TWS, TWS)
    @pack_land TWS => land.pools
    set_component_from_main_pool(land, tem_helpers, tem_helpers.pools.vals.self.TWS, tem_helpers.pools.vals.all_components.TWS, tem_helpers.pools.vals.zix.TWS)
    return land
end


function doSpinup(spinup_models,
    spinup_forcing,
    land,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsove_fixedpoint_trustregion_cEco_TWS})
    cEco_TWS_spin = Spinup_cEco_TWS(spinup_models, spinup_forcing, tem_helpers, deepcopy(land), land_type, f_one, Vector(deepcopy(land.pools.TWS)))
    p_init = log.(Vector(deepcopy(land.pools.cEco)))
    r = fixedpoint(cEco_TWS_spin, p_init; method=:trust_region)
    cEco = exp.(r.zero)
    cEco = oftype(land.pools.cEco, cEco)
    @pack_land cEco => land.pools
    TWS_prev = cEco_TWS_spin.TWS
    TWS = oftype(land.pools.TWS, TWS_prev)
    @pack_land TWS => land.pools
    set_component_from_main_pool(land, tem_helpers, tem_helpers.pools.vals.self.cEco, tem_helpers.pools.vals.all_components.cEco, tem_helpers.pools.vals.zix.cEco)
    set_component_from_main_pool(land, tem_helpers, tem_helpers.pools.vals.self.TWS, tem_helpers.pools.vals.all_components.TWS, tem_helpers.pools.vals.zix.TWS)
    return land
end


function doSpinup(spinup_models,
    spinup_forcing,
    land,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsove_fixedpoint_trustregion_cEco})
    cEco_spin = Spinup_cEco(spinup_models, spinup_forcing, tem_helpers, deepcopy(land), land_type, f_one)
    p_init = log.(Vector(deepcopy(land.pools.cEco)))
    r = fixedpoint(cEco_spin, p_init; method=:trust_region)
    cEco = exp.(r.zero)
    cEco = oftype(land.pools.cEco, cEco)
    @pack_land cEco => land.pools
    set_component_from_main_pool(land, tem_helpers, tem_helpers.pools.vals.self.cEco, tem_helpers.pools.vals.all_components.cEco, tem_helpers.pools.vals.zix.cEco)
    return land
end


function plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname, plot_elem, plot_var, tj, arraymethod)
    plot_elem = string(plot_elem)
    if plot_var == :cEco
        plt = plot(; legend=:outerbottom, size=(1200, 900), yscale=:log10)
        ylims!(0.01, 1e7)
    else
        plt = plot(; legend=:outerbottom, size=(1200, 900))
    end
    plot!(getfield(land.pools, plot_var);
        linewidth=5,
        xaxis="Pool",
        label="Init")

    plot!(getfield(out_sp_exp.pools, plot_var);
        linewidth=5,
        label="Exp_Init",
        title="SU: $(plot_elem) - $(plot_var):: jump => $(tj), $(arraymethod)")
    plot!(getfield(out_sp_exp_nl.pools, plot_var);
        linewidth=5,
        ls=:dash,
        label="Exp_NL")
    plot!(getfield(out_sp_nl.pools, plot_var);
        linewidth=5,
        ls=:dot,
        label="NL_Solve",
        xticks=(1:length(xtname) |> collect, string.(xtname)),
        rotation=45)

    savefig("$(string(plot_var))_gen_explicit_$(plot_elem)_$(arraymethod)_tj-$(tj).png")
    return nothing

end

function get_xtick_names(info, land_for_s, look_at)
    xtname = []
    xtl = nothing
    if look_at == :cEco
        xtl = land_for_s.cCycleBase.p_annk
    end
    for (i, comp) ∈ enumerate(getfield(info.tem.helpers.pools.components, look_at))
        zix = getfield(info.tem.helpers.pools.zix, comp)
        for iz in eachindex(zix)
            if look_at == :cEco
                push!(xtname, string(comp) * "\n" * string(xtl[i]))
            else
                push!(xtname, string(comp) * "_$(iz)")
            end
        end
    end
    return xtname
end
experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"
out_sp_exp = nothing
arraymethod = "staticarray"
tjs = (1, 100, 1_000)#, 10_000)
# tjs = (1000,)
# tjs = (100,)
nLoop_pre_spin = 10
# for arraymethod ∈ ("staticarray",)
# for arraymethod ∈ ("array",) #, "staticarray")
for arraymethod ∈ ("staticarray", "array") #, "staticarray")
    replace_info = Dict("spinup.differential_eqn.time_jump" => 1,
        "spinup.differential_eqn.relative_tolerance" => 1e-2,
        "spinup.differential_eqn.absolute_tolerance" => 1,
        "model_run.rules.model_array_type" => arraymethod,
        "model_run.flags.debug_model" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupExperiment(info)
    info, forcing = getForcing(info, Val(Symbol(info.model_run.rules.data_backend)))
    output = setupOutput(info)

    forc = getKeyedArrayFromYaxArray(forcing)

    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_space, tem_vals, f_one =
        prepRunEcosystem(output, forc, info.tem)


    loc_forcing, loc_output = getLocData(output.data, forc, loc_space_maps[1])

    spinupforc = :recycleMSC
    sel_forcing = getSpinupForcing(loc_forcing, tem_vals.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, tem_vals)
    theforcing = getfield(spinup_forcing, spinupforc)

    spinup_models = tem_vals.models.forward[tem_vals.models.is_spinup]
    # for sel_pool in (:cEco_TWS,)
    # for sel_pool in (:cEco,)
    # for sel_pool in (:TWS,)
    for sel_pool in (:TWS, :cEco, :cEco_TWS)

        look_at = sel_pool

        if sel_pool in (:cEco_TWS,)
            look_at = :cEco
        end
        land_for_s = deepcopy(land_space[1])
        land_type = typeof(land_for_s)

        xtname_c = get_xtick_names(info, land_for_s, :cEco)
        xtname_w = get_xtick_names(info, land_for_s, :TWS)

        @time for nl ∈ 1:nLoop_pre_spin
            land_for_s = ForwardSindbad.doSpinup(spinup_models,
                theforcing,
                land_for_s,
                tem_vals.helpers,
                tem_vals.spinup,
                land_type,
                f_one,
                Val(:spinup))
        end


        # sel_pool = :TWS
        sp_method = Symbol("nlsove_fixedpoint_trustregion_$(string(sel_pool))")
        @show "NL_solve"
        @time out_sp_nl = doSpinup(spinup_models,
            theforcing,
            deepcopy(land_for_s),
            tem_vals.helpers,
            tem_vals.spinup,
            land_type,
            f_one,
            Val(sp_method))


        for tj ∈ tjs
            land = deepcopy(land_space[1])

            @show "Exp_Init"
            sp = :spinup
            out_sp_exp = deepcopy(land_for_s)
            @time for nl ∈ 1:tj
                out_sp_exp = ForwardSindbad.doSpinup(spinup_models,
                    theforcing,
                    out_sp_exp,
                    tem_vals.helpers,
                    tem_vals.spinup,
                    land_type,
                    f_one,
                    Val(sp))
            end

            @show "Exp_NL"
            sp = :spinup
            out_sp_exp_nl = deepcopy(out_sp_nl)
            @time for nl ∈ 1:tj
                spinup_models
                out_sp_exp_nl = ForwardSindbad.doSpinup(spinup_models,
                    theforcing,
                    out_sp_exp_nl,
                    tem_vals.helpers,
                    tem_vals.spinup,
                    land_type,
                    f_one,
                    Val(sp))
            end
            if sel_pool in (:cEco_TWS,)
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, sel_pool, :cEco, tj, arraymethod)
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, sel_pool, :TWS, tj, arraymethod)
            elseif sel_pool == :cEco
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, :C, :cEco, tj, arraymethod)
            else
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, :W, :TWS, tj, arraymethod)
            end
        end
    end

end