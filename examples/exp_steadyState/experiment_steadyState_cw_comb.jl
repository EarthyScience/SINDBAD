using Revise
using Sindbad
using ForwardSindbad
using Plots
using Accessors
noStackTrace()

using NLsolve, ComponentArrays

struct SpinupTWS{M,F,T,I,L,O}
    models::M
    forcing::F
    tem_helpers::T
    land_init::I
    land_type::L
    f_one::O
end


struct SpinupCW{M,F,T,I,L,O}
    models::M
    forcing::F
    tem_helpers::T
    land_init::I
    land_type::L
    f_one::O
end

struct SpinupCecoTWS{M,F,T,I,L,O,TWS}
    models::M
    forcing::F
    tem_helpers::T
    land_init::I
    land_type::L
    f_one::O
    TWS::TWS
end


struct SpinupCeco{M,F,T,I,L,O}
    models::M
    forcing::F
    tem_helpers::T
    land_init::I
    land_type::L
    f_one::O
end

function add_c_to_land(pout, land, zix, helpers, 𝟘)
    cVeg = land.pools.cVeg
    for (lc, l) in enumerate(zix.cVeg)
        @rep_elem pout[l] => (cVeg, lc, :cVeg)
    end
    @pack_land cVeg => land.pools

    cVegRoot = land.pools.cVegRoot
    for (lc, l) in enumerate(zix.cVegRoot)
        @rep_elem pout[l] => (cVegRoot, lc, :cVegRoot)
    end
    @pack_land cVegRoot => land.pools

    cVegWood = land.pools.cVegWood
    for (lc, l) in enumerate(zix.cVegWood)
        @rep_elem pout[l] => (cVegWood, lc, :cVegWood)
    end
    @pack_land cVegWood => land.pools

    cVegReserve = land.pools.cVegReserve
    for (lc, l) in enumerate(zix.cVegReserve)
        @rep_elem pout[l] => (cVegReserve, lc, :cVegReserve)
    end
    @pack_land cVegReserve => land.pools

    cVegLeaf = land.pools.cVegLeaf
    for (lc, l) in enumerate(zix.cVegLeaf)
        @rep_elem pout[l] => (cVegLeaf, lc, :cVegLeaf)
    end
    @pack_land cVegLeaf => land.pools

    cLit = land.pools.cLit
    for (lc, l) in enumerate(zix.cLit)
        @rep_elem pout[l] => (cLit, lc, :cLit)
    end
    @pack_land cLit => land.pools

    cLitFast = land.pools.cLitFast
    for (lc, l) in enumerate(zix.cLitFast)
        @rep_elem pout[l] => (cLitFast, lc, :cLitFast)
    end
    @pack_land cLitFast => land.pools

    cLitSlow = land.pools.cLitSlow
    for (lc, l) in enumerate(zix.cLitSlow)
        @rep_elem pout[l] => (cLitSlow, lc, :cLitSlow)
    end
    @pack_land cLitSlow => land.pools

    cSoil = land.pools.cSoil
    for (lc, l) in enumerate(zix.cSoil)
        @rep_elem pout[l] => (cSoil, lc, :cSoil)
    end
    @pack_land cSoil => land.pools

    cSoilSlow = land.pools.cSoilSlow
    for (lc, l) in enumerate(zix.cSoilSlow)
        @rep_elem pout[l] => (cSoilSlow, lc, :cSoilSlow)
    end
    @pack_land cSoilSlow => land.pools

    cSoilOld = land.pools.cSoilOld
    for (lc, l) in enumerate(zix.cSoilOld)
        @rep_elem pout[l] => (cSoilOld, lc, :cSoilOld)
    end
    @pack_land cSoilOld => land.pools
    return land
end

function add_w_to_land(p, land, zix, helpers, 𝟘)

    snowW = land.pools.snowW
    for (lc, l) in enumerate(zix.snowW)
        @rep_elem max0(p[l]) => (snowW, lc, :snowW)
    end
    @pack_land snowW => land.pools

    soilW = land.pools.soilW
    for (lc, l) in enumerate(zix.soilW)
        @rep_elem max0(p[l]) => (soilW, lc, :soilW)
    end
    @pack_land soilW => land.pools

    groundW = land.pools.groundW
    for (lc, l) in enumerate(zix.groundW)
        @rep_elem max0(p[l]) => (groundW, lc, :groundW)
    end
    @pack_land groundW => land.pools

    surfaceW = land.pools.surfaceW
    for (lc, l) in enumerate(zix.surfaceW)
        @rep_elem max0(p[l]) => (surfaceW, lc, :surfaceW)
    end
    @pack_land surfaceW => land.pools
    return land
end


function (TWS_spin::SpinupTWS)(pout, p)
    land = TWS_spin.land_init
    helpers = TWS_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers
    TWS = land.pools.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem max0(p[l]) => (TWS, lc, :TWS)
    end
    @pack_land TWS => land.pools
    land = add_w_to_land(p, land, zix, helpers, 𝟘)
    update_init = loopTimeSpinup(TWS_spin.models, TWS_spin.forcing, land, TWS_spin.tem_helpers, TWS_spin.land_type, TWS_spin.f_one)
    pout .= update_init.pools.TWS
    return nothing
end



function (cEco_spin::SpinupCeco)(pout, p)
    land = cEco_spin.land_init
    helpers = cEco_spin.tem_helpers

    pout .= exp.(p)
    # pout .= max.(p, land.wCycleBase.z_zero)
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers
    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    land = add_c_to_land(pout, land, zix, helpers, 𝟘)
    update_init = loopTimeSpinup(cEco_spin.models, cEco_spin.forcing, land, cEco_spin.tem_helpers, cEco_spin.land_type, cEco_spin.f_one)
    # pout .= update_init.pools.cEco
    pout .= log.(update_init.pools.cEco)
    return nothing
end


function (cEcoTWS_spin::SpinupCecoTWS)(pout, p)
    land = cEcoTWS_spin.land_init
    helpers = cEcoTWS_spin.tem_helpers

    pout .= exp.(p)
    # pout .= max.(p, land.wCycleBase.z_zero)
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers
    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    land = add_c_to_land(pout, land, zix, helpers, 𝟘)
    # tcPrint(("in", land.pools.cEco))

    TWS = land.pools.TWS
    TWS_prev = cEcoTWS_spin.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem TWS_prev[l] => (TWS, lc, :TWS)
    end

    @pack_land TWS => land.pools
    land = add_w_to_land(TWS, land, zix, helpers, 𝟘)
    # tcPrint(("TWS_prev", cEcoTWS_spin.TWS, land.pools))

    update_init = loopTimeSpinup(cEcoTWS_spin.models, cEcoTWS_spin.forcing, land, cEcoTWS_spin.tem_helpers, cEcoTWS_spin.land_type, cEcoTWS_spin.f_one)
    # pout .= update_init.pools.cEco
    pout .= log.(update_init.pools.cEco)
    cEcoTWS_spin.TWS .= update_init.pools.TWS
    # tcPrint(("out", update_init.pools.cEco))
    # println("-------------------------------------------------------------------------------------------------------------------")
    return nothing
end

function (CW_spin::SpinupCW)(pout, p)
    land = CW_spin.land_init
    helpers = CW_spin.tem_helpers

    pout.cEco .= exp.(p.cEco)
    # pout .= max.(p, land.wCycleBase.z_zero)
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers
    cEco = land.pools.cEco
    ptmp = pout.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem ptmp[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    land = add_c_to_land(ptmp, land, zix, helpers, 𝟘)

    pout.TWS .= max.(p.TWS, 𝟘)
    TWS = land.pools.TWS
    ptmp = pout.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem ptmp[l] => (TWS, lc, :TWS)
    end
    @pack_land TWS => land.pools
    land = add_w_to_land(ptmp, land, zix, helpers, 𝟘)

    update_init = loopTimeSpinup(CW_spin.models, CW_spin.forcing, land, CW_spin.tem_helpers, CW_spin.land_type, CW_spin.f_one)
    # pout .= update_init.pools.cEco
    pout.cEco .= log.(update_init.pools.cEco)
    pout.TWS .= update_init.pools.TWS
    return nothing
end

function doSpinup(spinup_models,
    spinup_forcing,
    land_init,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsolve_TWS})
    TWS_spin = SpinupTWS(spinup_models, spinup_forcing, tem_helpers, land_init, land_type, f_one)
    r = fixedpoint(TWS_spin, Vector(deepcopy(land_init.pools.TWS)); method=:trust_region)
    TWS = r.zero
    TWS = oftype(land_init.pools.TWS, TWS)
    @pack_land TWS => land_init.pools
    land_init = add_w_to_land(TWS, land_init, tem_helpers.pools.zix, tem_helpers, tem_helpers.numbers.𝟘)
    return land_init
end


function doSpinup(spinup_models,
    spinup_forcing,
    land_init,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsolve_cEcoTWS})
    cEcoTWS_spin = SpinupCecoTWS(spinup_models, spinup_forcing, tem_helpers, deepcopy(land_init), land_type, f_one, Vector(deepcopy(land_init.pools.TWS)))
    p_init = log.(Vector(deepcopy(land_init.pools.cEco)))
    # p_init = Vector(deepcopy(land_init.pools.cEco))
    r = fixedpoint(cEcoTWS_spin, p_init; method=:trust_region)
    # r = fixedpoint(cEcoTWS_spin, p_init; method=:newton)
    # cEco = r.zero
    cEco = exp.(r.zero)
    cEco = oftype(land_init.pools.cEco, cEco)
    @pack_land cEco => land_init.pools
    TWS_prev = cEcoTWS_spin.TWS
    TWS = oftype(land_init.pools.TWS, TWS_prev)
    @pack_land TWS => land_init.pools
    land_init = add_c_to_land(cEco, land_init, tem_helpers.pools.zix, tem_helpers, tem_helpers.numbers.𝟘)
    land_init = add_w_to_land(TWS, land_init, tem_helpers.pools.zix, tem_helpers, tem_helpers.numbers.𝟘)
    return land_init
end


function doSpinup(spinup_models,
    spinup_forcing,
    land_init,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsolve_cEco})
    cEco_spin = SpinupCeco(spinup_models, spinup_forcing, tem_helpers, deepcopy(land_init), land_type, f_one)
    p_init = log.(Vector(deepcopy(land_init.pools.cEco)))
    # p_init = Vector(deepcopy(land_init.pools.cEco))
    r = fixedpoint(cEco_spin, p_init; method=:trust_region)
    cEco = exp.(r.zero)
    cEco = oftype(land_init.pools.cEco, cEco)
    @pack_land cEco => land_init.pools
    land_init = add_c_to_land(cEco, land_init, tem_helpers.pools.zix, tem_helpers, tem_helpers.numbers.𝟘)
    return land_init
end


function doSpinup(spinup_models,
    spinup_forcing,
    land_init,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsolve_CW})
    CW_spin = SpinupCW(spinup_models, spinup_forcing, tem_helpers, deepcopy(land_init), land_type, f_one)
    p_init = ComponentArray(
        cEco=log.(Vector(deepcopy(land_init.pools.cEco))),
        TWS=Vector(deepcopy(land_init.pools.TWS))
    )
    # p_init = Vector(deepcopy(land_init.pools.cEco))
    r = fixedpoint(CW_spin, p_init; method=:trust_region)
    pout = r.zero
    cEco = exp.(pout.cEco)
    TWS = pout.TWS
    cEco = oftype(land_init.pools.cEco, cEco)
    TWS = oftype(land_init.pools.TWS, TWS)
    @pack_land (TWS, cEco) => land_init.pools
    land_init = add_c_to_land(cEco, land_init, tem_helpers.pools.zix, tem_helpers, tem_helpers.numbers.𝟘)
    land_init = add_w_to_land(land_init.pools.TWS, land_init, tem_helpers.pools.zix, tem_helpers, tem_helpers.numbers.𝟘)
    return land_init
end

function plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname, plot_elem, plot_var, tj, arraymethod, out_path)
    plot_elem = string(plot_elem)
    if plot_var == :cEco
        plt = plot(; legend=:outerbottom, size=(1800, 1200), yscale=:log10)
        ylims!(0.01, 1e7)
    else
        plt = plot(; legend=:outerbottom, size=(1800, 1200))
        ylims!(10, 2000)
    end
    plot!(getfield(land.pools, plot_var);
        linewidth=5,
        xaxis="Pool",
        label="Init")

    plot!(getfield(out_sp_exp.pools, plot_var);
        linewidth=5,
        label="Exp_Init")
    # title="SU: $(plot_elem) - $(plot_var):: jump => $(tj), $(arraymethod)")
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

    savefig("$(string(plot_var))_explicit_$(plot_elem)_$(arraymethod)_tj-$(tj).png")
    return nothing

end

function get_xtick_names(info, land_init_for_s, look_at)
    xtname = []
    xtl = nothing
    if look_at == :cEco
        xtl = land_init_for_s.cCycleBase.c_τ_eco
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
    forcing = getForcing(info)




    forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
        prepRunEcosystem(forcing, info)

    loc_forcing, loc_output = getLocData(output_array, forcing_nt_array, loc_space_maps[1])

    spinupforc = :day_msc
    sel_forcing = getSpinupForcing(loc_forcing, tem_with_vals.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, tem_with_vals)
    theforcing = getfield(spinup_forcing, spinupforc)

    spinup_models = tem_with_vals.models.forward[tem_with_vals.models.is_spinup]
    for sel_pool in (:cEcoTWS,)
        # for sel_pool in (:cEco,)
        # for sel_pool in (:TWS,)
        # for sel_pool in (:CW, :TWS, :cEco, :cEcoTWS)

        # for sel_pool in (:CW,)
        look_at = sel_pool

        if sel_pool in (:CW, :cEcoTWS)
            look_at = :cEco
        end
        land_init_for_s = deepcopy(land_init_space[1])
        land_type = typeof(land_init_for_s)

        xtname_c = get_xtick_names(info, land_init_for_s, :cEco)
        xtname_w = get_xtick_names(info, land_init_for_s, :TWS)

        @time for nl ∈ 1:nLoop_pre_spin
            land_init_for_s = ForwardSindbad.doSpinup(spinup_models,
                theforcing,
                land_init_for_s,
                tem_with_vals.helpers,
                tem_with_vals.spinup,
                land_type,
                f_one,
                Val(:spinup))
        end


        # sel_pool = :TWS
        sp_method = Symbol("nlsolve_$(string(sel_pool))")
        @show "NL_solve"
        @time out_sp_nl = doSpinup(spinup_models,
            theforcing,
            deepcopy(land_init_for_s),
            tem_with_vals.helpers,
            tem_with_vals.spinup,
            land_type,
            f_one,
            Val(sp_method))
        @show out_sp_nl.pools.cEco


        for tj ∈ tjs
            land_init = deepcopy(land_init_space[1])

            @show "Exp_Init"
            sp = :spinup
            out_sp_exp = deepcopy(land_init_for_s)
            @time for nl ∈ 1:tj
                out_sp_exp = ForwardSindbad.doSpinup(spinup_models,
                    theforcing,
                    out_sp_exp,
                    tem_with_vals.helpers,
                    tem_with_vals.spinup,
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
                    tem_with_vals.helpers,
                    tem_with_vals.spinup,
                    land_type,
                    f_one,
                    Val(sp))
            end
            if sel_pool in (:CW, :cEcoTWS)
                plot_and_save(land_init, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, sel_pool, :cEco, tj, arraymethod, out_path)
                plot_and_save(land_init, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, sel_pool, :TWS, tj, arraymethod, out_path)
            elseif sel_pool == :cEco
                plot_and_save(land_init, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, :C, :cEco, tj, arraymethod, out_path)
            else
                plot_and_save(land_init, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, :W, :TWS, tj, arraymethod, out_path)
            end
        end
    end

end