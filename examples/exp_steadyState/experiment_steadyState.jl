using Revise
using Sindbad
# using Suppressor
# using Optimization
using Tables:
    columntable,
    matrix
using TableOperations:
    select

using DifferentialEquations

expFilejs = "exp_steadyState/settings_steadyState/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);
info = setupModel!(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));



function get_steady_state(pool_dat, p_info, t)
    out = p_info.init_out;
    out = setTupleSubfield(out, :pools, (p_info.pool, pool_dat));
    outsmodel = runForward(p_info.spinup_models, p_info.spinup_forcing, out, p_info.info.variables, p_info.info.helpers)
    # @time outsmodel = runForward(p_info.spinup_models, p_info.spinup_forcing, out, p_info.info.variables, p_info.info.helpers)
    states = outsmodel.states |> columntable;
    tmp = getfield(states, p_info.Δpool)
    Δpool = tmp[1]
    return Δpool
end

function set_spinup_info(info_reduced, forcing_spinup, spinup_pool_name, spinup_delta_pool_name, init_out)
    p_info = (;)
    spinup_models = info_reduced.models.forward[info_reduced.models.is_spinup.==1];
    out_prec = runPrecompute(spinup_forcing[1], info_reduced.models.forward, init_out, info_reduced.helpers);
    p_info = setTupleField(p_info, (:pool, spinup_pool_name));
    p_info = setTupleField(p_info, (:Δpool, spinup_delta_pool_name));
    p_info = setTupleField(p_info, (:init_out, out_prec));
    p_info = setTupleField(p_info, (:spinup_forcing, spinup_forcing));
    p_info = setTupleField(p_info, (:spinup_models, spinup_models));
    p_info = setTupleField(p_info, (:info, info.tem));
    return p_info
end

out = createInitOut(info);
sel_pool = :TWS;
sel_pool_delta = :ΔTWS_copy;
sel_pool = :cEco;
sel_pool_delta = :ΔcEco;

# selTimeStep = 1
# spinup_forcing = forcing[[selTimeStep]];
selTimeStep = 1:365
spinup_forcing = forcing[selTimeStep];

init_pool = getfield(out_prec.pools, sel_pool);
tspan = (0.0,1000.0);
ode_prob = ODEProblem(get_steady_state, init_pool, tspan, p_info);
sol = solve(ode_prob, Tsit5())#, reltol=1e-8, abstol=1e-8)
@time get_steady_state(init_pool, p_info, 0)

prob = SteadyStateProblem(get_steady_state, cEco_0, p_info)

sol = solve(prob,DynamicSS(Tsit5()))

using Plots
# f(u,p,t) = 1.01*u
# u0 = 1/2
# tspan = (0.0,1.0)
# prob = ODEProblem(f,u0,tspan)
# sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

# using Plots
plot(sol,linewidth=5,title="Solution to the linear ODE with a thick line",
     xaxis="Time (t)",yaxis="u(t) (in μm)") # legend=false
plot!(sol.t, t->0.5*exp(1.01t),lw=3,ls=:dash,label="True Solution!")



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