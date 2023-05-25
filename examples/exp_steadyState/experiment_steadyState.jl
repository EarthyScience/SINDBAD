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


info = getConfiguration(experiment_json);
info = setupExperiment(info);
# forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

# land_init = createLandInit(info.tem);
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
# linit= createLandInit(info.tem);

# Sindbad.eval(:(error_catcher = []))    
loc_space_maps, land_init_space, f_one, loc_forcing, loc_output  = prepRunEcosystem(output.data, info.tem.models.forward, forc, info.tem);

# selTimeStep = 1
# spinup_forcing = forcing[[selTimeStep]];
spinupforc=:yearOne
sel_forcing = getSpinupForcing(loc_forcing, info.tem.helpers, Val(spinupforc));
spinup_forcing = getSpinupForcing(loc_forcing, info.tem);

land_init = land_init_space[1];
land_type = typeof(land_init);
sel_pool = :cEco

spinup_models = info.tem.models.forward[info.tem.models.is_spinup .== 1];

plot(getfield(land_init.pools, sel_pool),linewidth=5,title="Steady State Solution",
     xaxis="Pool#",yaxis="C", label="Init") # legend=false
# sel_spinup_models::Tuple, sel_spinup_forcing::NamedTuple, land_in::NamedTuple, tem_helpers::NamedTuple, tem_spinup::NamedTuple, land_type, f_one
sp = :ODE_Tsit5
out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

sp = :SSP_DynamicSS_Tsit5
out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

sp = :SSP_SSRootfind
out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem.helpers, info.tem.spinup, land_type, f_one, Val(sp));
plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false


outsp_full = runSpinup(info.tem.models.forward, forcing, land_init, info.tem; spinup_forcing=spinup_forcing);
plot!(getfield(outsp_full.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false
