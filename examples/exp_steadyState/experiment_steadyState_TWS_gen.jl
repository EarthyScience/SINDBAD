using Revise
using Sindbad
using ForwardSindbad
using Plots
using Accessors
noStackTrace()

using NLsolve, ComponentArrays

struct Spinupper{M,F,T,I,L,O}
    models::M
    forcing::F
    tem_helpers::T
    land_init::I
    land_type::L
    f_one::O
end

function set_elem_components(land_pools,
    land_init,
    ::Val{s_comps},
    ::Val{zix},
    p) where {s_comps,zix}
    output = quote end
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), :tmp, Expr(:., :land_pools, QuoteNode(s_comp))))
        push!(output.args, Expr(:(=), :p_zix, Expr(:., :(helpers.pools.zix), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=), :p_tmp, Expr(:call, :max, Expr(:ref, :p, ix), :(helpers.numbers.𝟘))))
            push!(output.args, Expr(:macrocall, Symbol("@rep_elem"), :(), Expr(:call, :(=>), :p_tmp, Expr(:tuple, :tmp, c_ix, QuoteNode(s_comp)))))
            #= none:1 =#
            c_ix += 1
        end
        return push!(output.args,
            Expr(:(=),
                :land_init,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :(land_init.pools), QuoteNode(s_comp)), :tmp)))) #= none:1 =#
    end
    return output
end
helpers = info.tem.helpers;
set_elem_components(land_init.pools, land_init, Val(info.tem.helpers.pools.components.TWS), Val(info.tem.helpers.pools.zix), rand(10))
function (s::Spinupper)(pout, p)
    helpers = s.tem_helpers
    land_init = s.land_init
    if land_init.pools.TWS isa SVector
        TWS = land_init.pools.TWS
        for i in eachindex(TWS)
            tmp = max(p[i], helpers.numbers.𝟘)
            @rep_elem tmp => (TWS, i, :TWS)
        end
        land_init = @set land_init.pools.TWS = TWS
        set_elem_components(land_init.pools, land_init, Val(helpers.pools.components.TWS), Val(helpers.pools.zix), p)
    else
        land_init.pools.TWS .= max.(p, s.tem_helpers.numbers.𝟘)
    end
    update_init = loopTimeSpinup(s.models, s.forcing, land_init, s.tem_helpers, s.land_type, s.f_one)
    # pout.TWS .= update_init.pools.TWS
    pout .= update_init.pools.TWS
    return nothing
end

function doSpinup(spinup_models,
    spinup_forcing,
    land_init,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:nlsolve})
    s = tem_helpers.spinupper
    r = fixedpoint(s, Vector(land_init.pools.TWS); method=:trust_region)
    TWS = r.zero
    @pack_land TWS => land_init.pools
    return land_init
end


experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"
out_sp_exp = nothing
arraymethod = "staticarray"
for arraymethod ∈ ("staticarray", "array") #, "staticarray")
    replace_info = Dict("spinup.diffEq.timeJump" => tj,
        "spinup.diffEq.reltol" => 1e-2,
        "spinup.diffEq.abstol" => 1,
        "modelRun.rules.model_array_type" => arraymethod,
        "modelRun.flags.debugit" => false)

    info = getConfiguration(experiment_json; replace_info=replace_info)
    info = setupExperiment(info)
    info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))
    output = setupOutput(info)
    xtname = []
    for comp ∈ info.tem.helpers.pools.components.TWS
        zix = getfield(info.tem.helpers.pools.zix, comp)
        for iz in eachindex(zix)
            push!(xtname, string(comp) * "_$(iz)")
        end
    end

    forc = getKeyedArrayFromYaxArray(forcing)

    loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one =
        prepRunEcosystem(output.data,
            output.land_init,
            info.tem.models.forward,
            forc,
            forcing.sizes,
            info.tem)

    loc_forcing, loc_output = getLocData(output.data, forc, loc_space_maps[1])

    spinupforc = :recycleMSC
    sel_forcing = getSpinupForcing(loc_forcing, info.tem.helpers, Val(spinupforc))
    spinup_forcing = getSpinupForcing(loc_forcing, info.tem)

    land_init = deepcopy(land_init_space[1])
    land_type = typeof(land_init)
    sel_pool = :TWS


    spinup_models = info.tem.models.forward[info.tem.models.is_spinup]
    land_init_for_s = deepcopy(land_init_space[1])
    @show "NL_solve"
    s = Spinupper(spinup_models, getfield(spinup_forcing, spinupforc), info.tem.helpers, land_init, land_type, f_one)
    helpers = (; info.tem.helpers..., spinupper=s)
    @time out_sp_nl = doSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        land_init_for_s,
        helpers,
        info.tem.spinup,
        land_type,
        f_one,
        Val(:nlsolve))


    # for tj ∈ (1,)
    for tj ∈ (1, 10, 1000)
        plt = plot(; legend=:outerbottom, size=(900, 600))

        plot!(getfield(land_init.pools, sel_pool);
            linewidth=5,
            xaxis="Pool",
            yaxis="TWS",
            label="Init")

        @show "Exp_Init"
        sp = :spinup
        out_sp_exp = deepcopy(land_init_space[1])
        @time for nl ∈ 1:Int(info.tem.spinup.diffEq.timeJump)
            out_sp_exp = ForwardSindbad.doSpinup(spinup_models,
                getfield(spinup_forcing, spinupforc),
                out_sp_exp,
                info.tem.helpers,
                info.tem.spinup,
                land_type,
                f_one,
                Val(sp))
        end

        plot!(getfield(out_sp_exp.pools, sel_pool);
            linewidth=5,
            label="Exp_Init",
            title="Steady State Solution - jump => $(tj)") # legend=false


        @show "Exp_NL"
        sp = :spinup
        out_sp_exp_nl = out_sp_nl
        @time for nl ∈ 1:Int(info.tem.spinup.diffEq.timeJump)
            out_sp_exp_nl = ForwardSindbad.doSpinup(spinup_models,
                getfield(spinup_forcing, spinupforc),
                deepcopy(out_sp_exp_nl),
                info.tem.helpers,
                info.tem.spinup,
                land_type,
                f_one,
                Val(sp))
        end
        plot!(getfield(out_sp_exp_nl.pools, sel_pool);
            linewidth=5,
            ls=:dash,
            label="Exp_NL") # legend=false
        plot!(getfield(out_sp_nl.pools, sel_pool);
            linewidth=5,
            ls=:dot,
            label="NL_Solve",
            xticks=(1:length(xtname) |> collect, string.(xtname)),
            rotation=45) # legend=false

        savefig("comp_methods_eachpool_$(string(sel_pool))_$(arraymethod)_tj-$(tj).png")
    end

end