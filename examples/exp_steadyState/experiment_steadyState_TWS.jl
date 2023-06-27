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


function (s::Spinupper)(pout, p)
    et = eltype(p)
    n_layer = length(s.land_init.pools.TWS)
    z_soilW = [s.tem_helpers.pools.zix.soilW...]
    n_layer_soilW = length(z_soilW)
    z_groundW = [s.tem_helpers.pools.zix.groundW...]
    n_layer_groundW = length(z_groundW)
    z_surfaceW = [s.tem_helpers.pools.zix.surfaceW...]
    n_layer_surfaceW = length(z_surfaceW)
    z_snowW = [s.tem_helpers.pools.zix.snowW...]
    n_layer_snowW = length(z_snowW)

    land_init = s.land_init
    if land_init.pools.TWS isa SVector
        psv = SVector{n_layer,et}(ntuple(i -> p[i], n_layer))
        land_init = @set land_init.pools.TWS = max.(psv, s.tem_helpers.numbers.𝟘)

        psv = SVector{n_layer_soilW,et}(ntuple(i -> p[z_soilW][i], n_layer_soilW))
        land_init = @set land_init.pools.soilW = max.(psv, s.tem_helpers.numbers.𝟘)

        psv = SVector{n_layer_surfaceW,et}(ntuple(i -> p[z_surfaceW][i], n_layer_surfaceW))
        land_init = @set land_init.pools.surfaceW = max.(psv, s.tem_helpers.numbers.𝟘)

        psv = SVector{n_layer_groundW,et}(ntuple(i -> p[z_groundW][i], n_layer_groundW))
        land_init = @set land_init.pools.groundW = max.(psv, s.tem_helpers.numbers.𝟘)

        psv = SVector{n_layer_snowW,et}(ntuple(i -> p[z_snowW][i], n_layer_snowW))
        land_init = @set land_init.pools.snowW = max.(psv, s.tem_helpers.numbers.𝟘)
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
    s = Spinupper(spinup_models, spinup_forcing, tem_helpers, land_init, land_type, f_one)
    r = fixedpoint(s, Vector(land_init.pools.TWS); method=:trust_region)
    TWS = r.zero
    @pack_land TWS => land_init.pools
    return land_init
end


experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"
out_sp_exp = nothing
arraymethod = "staticarray"
for arraymethod ∈ ("staticarray", "array") #, "staticarray")
    replace_info = Dict("spinup.diffEq.timeJump" => 1,
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
    land_init_for_s = land_init
    @show "NL_solve"
    @time out_sp_nl = doSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        deepcopy(land_init_for_s),
        info.tem.helpers,
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
        out_sp_exp = deepcopy(land_init_for_s)
        @time for nl ∈ 1:tj
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
            title="Steady State Solution - jump => $(tj)")


        @show "Exp_NL"
        sp = :spinup
        out_sp_exp_nl = deepcopy(out_sp_nl)
        @time for nl ∈ 1:tj
            out_sp_exp_nl = ForwardSindbad.doSpinup(spinup_models,
                getfield(spinup_forcing, spinupforc),
                out_sp_exp_nl,
                info.tem.helpers,
                info.tem.spinup,
                land_type,
                f_one,
                Val(sp))
        end
        plot!(getfield(out_sp_exp_nl.pools, sel_pool);
            linewidth=5,
            ls=:dash,
            label="Exp_NL")
        plot!(getfield(out_sp_nl.pools, sel_pool);
            linewidth=5,
            ls=:dot,
            label="NL_Solve",
            xticks=(1:length(xtname) |> collect, string.(xtname)),
            rotation=45)

        savefig("comp_methods_eachpool_$(string(sel_pool))_$(arraymethod)_tj-$(tj).png")
    end

end