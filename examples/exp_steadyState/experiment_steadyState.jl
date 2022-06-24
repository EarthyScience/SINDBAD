using Revise
using Sindbad
# using Suppressor
# using Optimization
using Tables:
    columntable,
    matrix
using TableOperations:
    select


expFilejs = "exp_steadyState/settings_steadyState/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);
info = setupModel!(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));

out = createInitOut(info);
sel_pool = :TWS;
sel_pool = :cEco;

# selTimeStep = 1
# spinup_forcing = forcing[[selTimeStep]];
spinup_forcing = getSpinupForcing(forcing, info);
init_out = runPrecompute(forcing[1], info.tem.models.forward, out, info.tem.helpers);

doSpinup(info.tem.models.forward, spinup_forcing.yearOne, init_out, info.tem, Val(:ODE_Tsit5));
doSpinup(info.tem.models.forward, spinup_forcing.yearOne, init_out, info.tem, Val(:SSP_DynamicSS_Tsit5));
doSpinup(info.tem.models.forward, spinup_forcing.yearOne, init_out, info.tem, Val(:SSP_SSRootfind));
runSpinup(info.tem.models.forward, forcing, out, info.tem; spinup_forcing=spinup_forcing);


p_info = getSpinupInfo(info.tem, spinup_forcing, sel_pool, out);
init_pool = getfield(p_info.out_prec[:pools], sel_pool);
tspan = (0.0,10000.0);
ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info);
sol = solve(ode_prob, Tsit5())#, reltol=1e-8, abstol=1e-8)

ss_prob = SteadyStateProblem(get_delta_pool, init_pool, p_info)

sol1 = solve(ss_prob,DynamicSS(Tsit5()))

sol2 = solve(ss_prob,SSRootfind())

using Plots
# f(u,p,t) = 1.01*u
# u0 = 1/2
# tspan = (0.0,1.0)
# prob = ODEProblem(f,u0,tspan)
# sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

using Plots
plot(sol1,linewidth=5,title="Steady State Solution",
     xaxis="Time (t)",yaxis="Pool", label="SS(DSS)") # legend=false
plot!(sol2,linewidth=5, label="SS(RF)") # legend=false
plot!(sol.u[end],linewidth=5, label="ODE") # legend=false



obsV = :gpp;
modelVarInfo = [:fluxes, :gpp];
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

using Plots
plot(ŷ)
plot!(y)
plot!(yσ)

states = outsmodel.states |> columntable;
pools = outsmodel.pools |> columntable;
fluxes = outsmodel.fluxes |> columntable;

using Plots
plot(fluxes.NEE)
plot!(observations.nee)