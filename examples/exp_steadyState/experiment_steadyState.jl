using Revise
using Sindbad
using ForwardSindbad
using Plots
#noStackTrace()
# using Suppressor
# using Optimization
# using Tables:
#     columntable,
#     matrix
# using TableOperations:
#     select

# using Plots

experiment_json = "../exp_steadyState/settings_steadyState/experiment.json"


info = getConfiguration(experiment_json);
info = setupExperiment(info);
# forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

# land_init = createLandInit(info.tem);
info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
# linit= createLandInit(info.tem);

# Sindbad.eval(:(error_catcher = []))    
loc_space_maps, land_init_space, f_one  = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

loc_forcing, loc_output = getLocData(output.data, forc, loc_space_maps[1]);

# selTimeStep = 1
# spinup_forcing = forcing[[selTimeStep]];
spinupforc=:yearOne
sel_forcing = getSpinupForcing(loc_forcing, info.tem.helpers, Val(spinupforc));
spinup_forcing = getSpinupForcing(loc_forcing, info.tem);

land_init = land_init_space[1];
land_type = typeof(land_init);
sel_pool = :cEco

spinup_models = info.tem.models.forward[info.tem.models.is_spinup .== 1];

# plot(getfield(land_init.pools, sel_pool),linewidth=5,title="Steady State Solution",
#      xaxis="Pool#",yaxis="C", label="Init") # legend=false
# # sel_spinup_models::Tuple, sel_spinup_forcing::NamedTuple, land_in::NamedTuple, tem_helpers::NamedTuple, tem_spinup::NamedTuple, land_type, f_one
# sp = :ODE_Tsit5
# out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
# plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

# sp = :SSP_DynamicSS_Tsit5
# out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
# plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

# sp = :SSP_SSRootfind
# out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
# plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

# sp = :spinup
# out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
# plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

# outsp_full = runSpinup(info.tem.models.forward, forcing, land_init, info.tem; spinup_forcing=spinup_forcing);
# plot!(getfield(outsp_full.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false







# land_spin = deepcopy(land_init)
# function get_target_tolerance(spinup_models, spinup_forcing, land_init, info, land_type, f_one)
#      land_spin = deepcopy(land_init)
#      @time for i in 1:10000
#           @show land_spin.pools.cVeg
#           land_spin = loopTimeSpinup(spinup_models, spinup_forcing.yearOne, land_spin, info.tem.helpers, land_type, f_one)
#      end
#      land_spin_old = deepcopy(land_spin)
#      land_spin_new = loopTimeSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_spin), info.tem.helpers, land_type, f_one)
#      land_spin_old, land_spin_new
# end



# a1, a2 = get_target_tolerance(spinup_models, spinup_forcing, land_init, info, land_type, f_one)

# reltol(a1,a2) = max(1e-10,abs((a1-a2)/a2))

# extract_pool_component(x) = ComponentArray((TWS=x.pools.TWS, cEco=x.pools.cEco))

# pooldiff = reltol.(extract_pool_component.((a1,a2))...)

using NLsolve, ComponentArrays

struct Spinupper{M,F,T,I,L,O}
     models::M
     forcing::F
     tem_helpers::T
     land_init::I
     land_type::L
     f_one::O
end



function (s::Spinupper)(pout,p)
     pout .= exp.(p)# .* s.pooldiff
     s.land_init.pools.TWS .= pout.TWS
     s.land_init.pools.cEco .= pout.cEco
     update_init = loopTimeSpinup(s.models, s.forcing, s.land_init, s.tem_helpers, s.land_type, s.f_one)
     pout.TWS .= update_init.pools.TWS
     pout.cEco .= update_init.pools.cEco
     pout .= log.(pout)# ./ s.pooldiff
     nothing
end

function doSpinup(spinup_models, spinup_forcing, land_init, tem_helpers, _, land_type, f_one, ::Val{:nlsolve})

     s = Spinupper(spinup_models, spinup_forcing, tem_helpers, deepcopy(land_init),land_type, f_one);
     mypools = ComponentArray((TWS = deepcopy(land_init.pools.TWS), cEco = deepcopy(land_init.pools.cEco)))
     mypools .= log.(mypools)
     r = fixedpoint(s,mypools,method=:trust_region)

     res = exp.(r.zero)
     li = deepcopy(s.land_init)
     li.pools.cEco .= res.cEco
     li.pools.TWS .= res.TWS
     li
end

out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(:nlsolve));

