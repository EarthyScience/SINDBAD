using Revise
using Sindbad
using ForwardSindbad
using Plots
using Accessors
noStackTrace()
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
function plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname, plot_elem, plot_var, tj, arraymethod, out_path)
    plot_elem = string(plot_elem)
    if plot_var == :cEco
        plt = plot(; legend=:outerbottom, legendcolumns=4, size=(1800, 1200), yscale=:log10, left_margin=1Plots.cm)
        ylims!(0.00000001, 1e5)
    else
        plt = plot(; legend=:outerbottom, legendcolumns=4, size=(1800, 1200), left_margin=1Plots.cm)
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

    savefig(joinpath(out_path, "$(string(plot_var))_sin_explicit_$(plot_elem)_$(arraymethod)_tj-$(tj).png"))
    return nothing
end

function get_xtick_names(info, land_for_s, look_at)
    xtname = []
    xtl = nothing
    if look_at == :cEco
        xtl = land_for_s.cCycleBase.c_τ_eco
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
# tjs = (10_000,)
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
    output = setupOutput(info)

    forc = getKeyedArrayWithNames(forcing)

    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_space, tem_with_vals, f_one =
        prepRunEcosystem(output, forc, info.tem)


    loc_forcing, loc_output = getLocData(output.data, forc, loc_space_maps[1])

    spinupforc = :day_msc
    sel_forcing = getSpinupForcing(loc_forcing, tem_with_vals.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, tem_with_vals)
    theforcing = getfield(spinup_forcing, spinupforc)

    spinup_models = tem_with_vals.models.forward[tem_with_vals.models.is_spinup]
    # for sel_pool in (:cEco_TWS,)
    # for sel_pool in (:cEco,)
    # for sel_pool in (:TWS,)
    out_path = info.output.figure
    for sel_pool in (:cEco,)
        # for sel_pool in (:TWS, :cEco, :cEco_TWS)

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
                tem_with_vals.helpers,
                tem_with_vals.spinup,
                land_type,
                f_one,
                Val(:spinup))
        end


        # sel_pool = :TWS
        sp_method = Symbol("nlsove_fixedpoint_trustregion_$(string(sel_pool))")
        @show "NL_solve"
        @time out_sp_nl = ForwardSindbad.doSpinup(spinup_models,
            theforcing,
            deepcopy(land_for_s),
            tem_with_vals.helpers,
            tem_with_vals.spinup,
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
                out_sp_exp_nl = ForwardSindbad.doSpinup(spinup_models,
                    theforcing,
                    out_sp_exp_nl,
                    tem_with_vals.helpers,
                    tem_with_vals.spinup,
                    land_type,
                    f_one,
                    Val(sp))
            end
            if sel_pool in (:cEco_TWS,)
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, sel_pool, :cEco, tj, arraymethod, out_path)
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, sel_pool, :TWS, tj, arraymethod, out_path)
            elseif sel_pool == :cEco
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, :C, :cEco, tj, arraymethod, out_path)
            else
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, :W, :TWS, tj, arraymethod, out_path)
            end
        end
    end

end