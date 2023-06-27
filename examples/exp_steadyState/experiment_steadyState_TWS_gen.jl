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
    land = s.land_init
    helpers = s.tem_helpers
    if land.pools.TWS isa SVector
        psv = SVector{n_layer,et}(ntuple(i -> p[i], n_layer))
        land = @set land.pools.TWS = max.(psv, s.tem_helpers.numbers.𝟘)
        # TWS = land.pools.TWS
        # soilW = land.pools.soilW
        # soilW = (Sindbad.rep_elem)(soilW, TWS[1], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
        # soilW = (Sindbad.rep_elem)(soilW, TWS[2], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 2)
        # soilW = (Sindbad.rep_elem)(soilW, TWS[3], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 3)
        # soilW = (Sindbad.rep_elem)(soilW, TWS[4], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 4)
        # land = (land..., pools=(; land.pools..., soilW=soilW))
        # groundW = land.pools.groundW
        # groundW = (Sindbad.rep_elem)(groundW, TWS[5], helpers.pools.zeros.groundW, helpers.pools.ones.groundW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
        # land = (land..., pools=(; land.pools..., groundW=groundW))
        # snowW = land.pools.snowW
        # snowW = (Sindbad.rep_elem)(snowW, TWS[6], helpers.pools.zeros.snowW, helpers.pools.ones.snowW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
        # land = (land..., pools=(; land.pools..., snowW=snowW))
        # surfaceW = land.pools.surfaceW
        # surfaceW = (Sindbad.rep_elem)(surfaceW, TWS[7], helpers.pools.zeros.surfaceW, helpers.pools.ones.surfaceW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
        # land = (land..., pools=(; land.pools..., surfaceW=surfaceW))
        set_pool_components(land, helpers, Val(:TWS), Val(helpers.pools.all_components.TWS), Val(helpers.pools.zix))
        # set_elem_components(land, helpers, Val(helpers.pools.components.TWS), Val(helpers.pools.zix), p)
    else
        land.pools.TWS .= max.(p, helpers.numbers.𝟘)
    end
    update = loopTimeSpinup(s.models, s.forcing, land, s.tem_helpers, s.land_type, s.f_one)
    # pout.TWS .= update.pools.TWS
    pout .= update.pools.TWS
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
# include("set_elem_components.jl")
# land = land_init_space[1];
# helpers = info.tem.helpers;
# set_pool_components(land, helpers, Val(:TWS), Val(info.tem.helpers.pools.all_components.TWS), Val(info.tem.helpers.pools.zix))

experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"
# out_sp_exp = nothing

# # arraymethod = "staticarray"
# info = getConfiguration(experiment_json);
# info = setupExperiment(info);
# info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# output = setupOutput(info);

# forc = getKeyedArrayFromYaxArray(forcing);

# loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one =
#     prepRunEcosystem(output.data,
#         output.land_init,
#         info.tem.models.forward,
#         forc,
#         forcing.sizes,
#         info.tem);
# land_init = land_init_space[1];
# set_pool_components(land_init, info.tem.helpers, Val(info.tem.helpers.pools.components.TWS), Val(info.tem.helpers.pools.zix), land_init.pools.TWS)
# set_pool_components(:TWS, Val(info.tem.helpers.pools.all_components.TWS), Val(info.tem.helpers.pools.zix))
# set_pool_components(:cEco, Val(info.tem.helpers.pools.all_components.cEco), Val(info.tem.helpers.pools.zix))
# set_pool_components(:cVeg, Val(info.tem.helpers.pools.components.cVeg), Val(info.tem.helpers.pools.zix))
# set_pool_components(:cLit, Val(info.tem.helpers.pools.components.cLit), Val(info.tem.helpers.pools.zix))
# set_pool_components(:cSoil, Val(info.tem.helpers.pools.components.cSoil), Val(info.tem.helpers.pools.zix))


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
    land_init_for_s = deepcopy(land_init_space[1])
    @show "NL_solve"
    @time out_sp_nl = doSpinup(spinup_models,
        getfield(spinup_forcing, spinupforc),
        land_init_for_s,
        info.tem.helpers,
        info.tem.spinup,
        land_type,
        f_one,
        Val(:nlsolve))


    for tj ∈ (1,)
        # for tj ∈ (1, 10, 1000)
        plt = plot(; legend=:outerbottom, size=(900, 600))

        plot!(getfield(land_init.pools, sel_pool);
            linewidth=5,
            xaxis="Pool",
            yaxis="TWS",
            label="Init")

        @show "Exp_Init"
        sp = :spinup
        out_sp_exp = deepcopy(land_init_space[1])
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
                out_sp_exp,
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

        savefig("gen_comp_methods_eachpool_$(string(sel_pool))_$(arraymethod)_tj-$(tj).png")
    end

end