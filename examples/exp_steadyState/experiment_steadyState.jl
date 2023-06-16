using Revise
using Sindbad
using ForwardSindbad
using Plots
noStackTrace()
# using Suppressor
# using Optimization
# using Tables:
#     columntable,
#     matrix
# using TableOperations:
#     select

# using Plots

experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"

replace_info = Dict(
    "spinup.diffEq.timeJump" => 100,
    "spinup.diffEq.reltol" => 1e-2,
    "spinup.diffEq.abstol" => 1,
    "modelRun.rules.model_array_type" => "array",
    "modelRun.flags.debugit" => false
);


info = getConfiguration(experiment_json; replace_info=replace_info);
info = setupExperiment(info);
# forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

# land_init = createLandInit(info.tem);
info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
# linit= createLandInit(info.tem);

# Sindbad.eval(:(error_catcher = []))    
loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, land_init_space[1], info.tem.models.forward, forc, forcing.sizes, info.tem);

loc_forcing, loc_output = getLocData(output.data, forc, loc_space_maps[1]);

# selTimeStep = 1
# spinup_forcing = forcing[[selTimeStep]];
spinupforc=:recycleMSC
sel_forcing = getSpinupForcing(loc_forcing, info.tem.helpers, Val(spinupforc));
spinup_forcing = getSpinupForcing(loc_forcing, info.tem);

land_init = land_init_space[1];
land_type = typeof(land_init);
sel_pool = :cEco

spinup_models = info.tem.models.forward[info.tem.models.is_spinup .== 1];

plot(getfield(land_init.pools, sel_pool),linewidth=5,title="Steady State Solution",
     xaxis="Pool#",yaxis="C", label="Init", yscale=:log10) # legend=false
# sel_spinup_models::Tuple, sel_spinup_forcing::NamedTuple, land_in::NamedTuple, tem_helpers::NamedTuple, tem_spinup::NamedTuple, land_type, f_one
sp = :ODE_Tsit5
# doSpinup(sel_spinup_models::Tuple, sel_spinup_forcing::NamedTuple, land_in::NamedTuple, tem_helpers::NamedTuple, tem_spinup::NamedTuple, land_type, f_one, ::Val{:ODE_Tsit5})
@show "ODE_Init"
@time out_sp_ode = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
out_sp_ode_init = deepcopy(out_sp_ode);

# sp = :SSP_DynamicSS_Tsit5
# out_sp = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
# plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

# sp = :SSP_SSRootfind
# out_sp = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
# plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false
@show "Exp_Init"
sp = :spinup
out_sp_exp = land_init;
@time for nl = 1:Int(info.tem.spinup.diffEq.timeJump)
     out_sp_exp = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(out_sp_exp), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
end
out_sp_exp_init = deepcopy(out_sp_exp);


sp = :ODE_Tsit5
# doSpinup(sel_spinup_models::Tuple, sel_spinup_forcing::NamedTuple, land_in::NamedTuple, tem_helpers::NamedTuple, tem_spinup::NamedTuple, land_type, f_one, ::Val{:ODE_Tsit5})
@show "ODE_Exp"
@time out_sp_ode_exp = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(out_sp_exp), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));

@show "Exp_ODE"
sp = :spinup
out_sp_exp_ode = out_sp_ode;
@time for nl = 1:Int(info.tem.spinup.diffEq.timeJump)
     out_sp_exp_ode = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(out_sp_exp_ode), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
end

plot!(getfield(out_sp_ode_init.pools, sel_pool),linewidth=5, label="ODE_Init", yscale=:log10) # legend=false
plot!(getfield(out_sp_ode_exp.pools, sel_pool),linewidth=5, label="ODE_Exp", yscale=:log10) # legend=false
plot!(getfield(out_sp_exp_init.pools, sel_pool),linewidth=5, ls=:dash, label="Exp_Init", yscale=:log10) # legend=false
plot!(getfield(out_sp_exp_ode.pools, sel_pool),linewidth=5, ls=:dash, label="Exp_ODE", yscale=:log10) # legend=false



# outsp_full = ForwardSindbad.runSpinup(info.tem.models.forward, forcing, land_init, info.tem; spinup_forcing=spinup_forcing);
# plot!(getfield(outsp_full.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false







# land_spin = deepcopy(land_init)
# function get_target_tolerance(spinup_models, spinup_forcing, land_init, info, land_type, f_one)
#      land_spin = deepcopy(land_init)
#      @time for i in 1:10000
#           @show land_spin.pools.cVeg
#           land_spin = loopTimeSpinup(spinup_models, getfield(spinup_forcing, spinupforc), land_spin, info.tem.helpers, land_type, f_one)
#      end
#      land_spin_old = deepcopy(land_spin)
#      land_spin_new = loopTimeSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(land_spin), info.tem.helpers, land_type, f_one)
#      land_spin_old, land_spin_new
# end



# a1, a2 = get_target_tolerance(spinup_models, spinup_forcing, land_init, info, land_type, f_one)

# reltol(a1,a2) = max(1e-10,abs((a1-a2)/a2))

# extract_pool_component(x) = ComponentArray((TWS=x.pools.TWS, cEco=x.pools.cEco))

# pooldiff = reltol.(extract_pool_component.((a1,a2))...)

using NLsolve, ComponentArrays

struct Spinupper{M,F,T,I,L, O}
     models::M
     forcing::F
     tem_helpers::T
     land_init::I
     land_type::L
     f_one::O
end



function (s::Spinupper)(pout, p)
     pout .= exp.(p)# .* s.pooldiff
     s.land_init.pools.TWS .= pout.TWS
     s.land_init.pools.cEco .= pout.cEco
     update_init = loopTimeSpinup(s.models, s.forcing, s.land_init, s.tem_helpers, s.land_type, s.f_one)
     pout.TWS .= update_init.pools.TWS
     pout.cEco .= update_init.pools.cEco
     pout .= log.(pout)# ./ s.pooldiff
     nothing
     # pout .= exp.(p)# .* s.pooldiff
     # tmp = s.land_init.pools.TWS;
     # helpers = s.tem_helpers;
     
     # @rep_vec tmp => pout.TWS
     # s = @set s.land_init.pools.TWS = tmp
     
     # tmp = s.land_init.pools.cEco
     # s = @set s.land_init.pools.cEco = tmp

     # @rep_vec tmp => pout.cEco
     # s = @set s.land_init.pools.cEco = tmp

     # update_init = loopTimeSpinup(s.models, s.forcing, s.land_init, s.tem_helpers, s.land_type, s.f_one)

     # pout = @set pout.TWS = update_init.pools.TWS
     # pout = @set pout.cEco = update_init.pools.cEco
     # pout .= log.(pout)# ./ s.pooldiff
end

function doSpinup(spinup_models, spinup_forcing, land_init, tem_helpers, _, land_type, f_one, ::Val{:nlsolve})

     s = Spinupper(spinup_models, spinup_forcing, tem_helpers, deepcopy(land_init), land_type, f_one);
     mypools = ComponentArray((TWS = deepcopy(land_init.pools.TWS), cEco = deepcopy(land_init.pools.cEco)))
     mypools .= log.(mypools)
     r = fixedpoint(s, mypools, method=:trust_region)

     res = exp.(r.zero)
     li = deepcopy(s.land_init)
     cEco = res.cEco
     TWS = res.TWS
     @pack_land cEco => li.pools
     @pack_land TWS => li.pools
     li
end

out_sp_nl = doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(:nlsolve));
xtl = land_init.cCycleBase.p_annk;
plot!(getfield(out_sp_nl.pools, sel_pool),linewidth=5, ls=:dot, label="NL_Solve", xticks=(1:length(xtl), string.(xtl)), rotation=45) # legend=false



@show "Exp_NL"
sp = :spinup
out_sp_exp_nl = out_sp_nl;
@time for nl = 1:Int(info.tem.spinup.diffEq.timeJump)
     out_sp_exp_nl = ForwardSindbad.doSpinup(spinup_models, getfield(spinup_forcing, spinupforc), deepcopy(out_sp_exp_nl), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
end
plot!(getfield(out_sp_exp_nl.pools, sel_pool),linewidth=5, ls=:dash, label="Exp_NL", yscale=:log10) # legend=false
