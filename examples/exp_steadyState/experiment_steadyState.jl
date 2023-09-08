using Revise
using SindbadTEM
using SindbadData
using Plots
using Accessors
toggleStackTraceNT()
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
function plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname, plot_elem, plot_var, tj, model_array_type, out_path)
    plot_elem = string(plot_elem)
    if plot_var == :cEco
        plt = plot(; legend=:outerbottom, legendcolumns=4, size=(1800, 1200), yscale=:log10, left_margin=1Plots.cm)
        ylims!(0.00000001, 1e9)
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
    # title="SU: $(plot_elem) - $(plot_var):: jump => $(tj), $(model_array_type)")
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

    savefig(joinpath(out_path, "$(string(plot_var))_sin_explicit_$(plot_elem)_$(model_array_type)_tj-$(tj).png"))
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
model_array_type = "static_array"
tjs = (1, 100, 1_000, 10_000)
# tjs = (1000,)
# tjs = (10_000,)
nLoop_pre_spin = 10
# for model_array_type ∈ ("static_array",)
# for model_array_type ∈ ("array",) #, "static_array")
setLogLevel(:warn)
for model_array_type ∈ ("static_array", "array") #, "static_array")
    replace_info = Dict("spinup.differential_eqn.time_jump" => 1,
        "spinup.differential_eqn.relative_tolerance" => 1e-2,
        "spinup.differential_eqn.absolute_tolerance" => 1,
        "experiment.exe_rules.model_array_type" => model_array_type,
        "experiment.flags.debug_model" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupInfo(info)
    forcing = getForcing(info)




    run_helpers = prepTEM(forcing, info);

    loc_forcings = run_helpers.loc_forcings;
    forcing_one_timestep = run_helpers.forcing_one_timestep;
    output_array = run_helpers.output_array;
    loc_outputs = run_helpers.loc_outputs;
    land_init_space = run_helpers.land_init_space;
    tem_with_types = run_helpers.tem_with_types;

    spinup_forcing = getSpinupForcing(run_helpers.loc_forcings[1], forcing_one_timestep, tem_with_types.spinup.sequence, tem_with_types.helpers)


    spinupforc = :day_MSC
    theforcing = getfield(spinup_forcing, spinupforc)

    spinup_models = tem_with_types.models.forward[tem_with_types.models.is_spinup]
    out_path = info.output.figure
    for sel_pool in (:cEco_TWS,)
    # for sel_pool in (:cEco,)
    # for sel_pool in (:TWS,)
    # for sel_pool in (:cEco,)
        # for sel_pool in (:TWS, :cEco, :cEco_TWS)

        look_at = sel_pool

        if sel_pool in (:cEco_TWS,)
            look_at = :cEco
        end
        land_for_s = deepcopy(run_helpers.land_one)
        land_type = typeof(land_for_s)

        xtname_c = get_xtick_names(info, land_for_s, :cEco)
        xtname_w = get_xtick_names(info, land_for_s, :TWS)
        # spinup_models,
        # spinup_forcing,
        # forcing_one_timestep,
        # land,
        # Symbol(sel_pool),
        # tem_helpers,
        # tem_spinup)

        @time for nl ∈ 1:nLoop_pre_spin
            land_for_s = SindbadTEM.runSpinup(
                spinup_models,
                theforcing,
                forcing_one_timestep,
                land_for_s,
                tem_with_types.helpers,
                tem_with_types.spinup,
                SelSpinupModels())
        end


        # sel_pool = :TWS
        sp_method = getfield(SindbadSetup, toUpperCaseFirst("nlsolve_fixedpoint_trustregion_$(string(sel_pool))"))()
        @show "NL_solve"
        @time out_sp_nl = SindbadTEM.runSpinup(
            spinup_models,
            theforcing,
            forcing_one_timestep,
            deepcopy(land_for_s),
            tem_with_types.helpers,
            tem_with_types.spinup,
            sp_method)


        for tj ∈ tjs
            land = deepcopy(run_helpers.land_one)

            @show "Exp_Init"
            sp = SelSpinupModels()
            out_sp_exp = deepcopy(land_for_s)
            @time for nl ∈ 1:tj
                out_sp_exp = SindbadTEM.runSpinup(
                    spinup_models,
                    theforcing,
                    forcing_one_timestep,
                    out_sp_exp,
                    tem_with_types.helpers,
                    tem_with_types.spinup,
                    sp)
            end

            @show "Exp_NL"
            out_sp_exp_nl = deepcopy(out_sp_nl)
            @time for nl ∈ 1:tj
                out_sp_exp_nl = SindbadTEM.runSpinup(spinup_models,
                    theforcing,
                    forcing_one_timestep,
                    out_sp_exp_nl,
                    tem_with_types.helpers,
                    tem_with_types.spinup,
                    sp)
            end
            if sel_pool in (:cEco_TWS,)
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, sel_pool, :cEco, tj, model_array_type, out_path)
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, sel_pool, :TWS, tj, model_array_type, out_path)
            elseif sel_pool == :cEco
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_c, :C, :cEco, tj, model_array_type, out_path)
            else
                plot_and_save(land, out_sp_exp, out_sp_exp_nl, out_sp_nl, xtname_w, :W, :TWS, tj, model_array_type, out_path)
            end
        end
    end

end