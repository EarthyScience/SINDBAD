using Revise
using Sindbad
# using Suppressor
# using Optimization
using Tables:
    columntable,
    matrix
using TableOperations:
    select

using Plots

experiment_json = "exp_steadyState/settings_steadyState/experiment.json"


info = getConfiguration(experiment_json);
info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

land_init = createLandInit(info);

# selTimeStep = 1
# spinup_forcing = forcing[[selTimeStep]];
spinup_forcing = getSpinupForcing(forcing, info.tem);

land_init = runPrecompute(forcing[1], info.tem.models.forward, out, info.tem.helpers);
sel_pool = :cEco

spinup_models = info.tem.models.forward[info.tem.models.is_spinup .== 1];

plot(getfield(land_init.pools, sel_pool),linewidth=5,title="Steady State Solution",
     xaxis="Pool#",yaxis="C", label="Init") # legend=false

sp = :ODE_Tsit5
out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem, Val(sp));
plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

sp = :SSP_DynamicSS_Tsit5
out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem, Val(sp));
plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false

sp = :SSP_SSRootfind
out_sp = doSpinup(spinup_models, spinup_forcing.yearOne, deepcopy(land_init), info.tem, Val(sp));
plot!(getfield(out_sp.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false


outsp_full = runSpinup(info.tem.models.forward, forcing, land_init, info.tem; spinup_forcing=spinup_forcing);
plot!(getfield(outsp_full.pools, sel_pool),linewidth=5, label=string(sp)) # legend=false
