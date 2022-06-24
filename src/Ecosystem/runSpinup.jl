export doSpinup, getDeltaPool, getSpinupInfo, runSpinup

function getDeltaPool(pool_dat, spinup_info, t)
    out = spinup_info.init_out;
    pool_array = getfield(out.pools, spinup_info.pool)
    pool_array .= pool_dat
    @time outsmodel = loopTimeSpinup(spinup_info.sel_spinup_models, spinup_info.sel_spinup_forcing, spinup_info.init_out, spinup_info.helpers)
    tmp = getfield(outsmodel.pools, spinup_info.pool)
    # Δpool = tmp[end] - pool_dat
    Δpool = pool_dat - tmp
    return Δpool
end

function getSpinupInfo(sel_spinup_models, sel_spinup_forcing, spinup_pool_name, init_out, modelHelpers)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name));
    spinup_info = setTupleField(spinup_info, (:init_out, init_out));
    spinup_info = setTupleField(spinup_info, (:sel_spinup_forcing, sel_spinup_forcing));
    spinup_info = setTupleField(spinup_info, (:sel_spinup_models, sel_spinup_models));
    spinup_info = setTupleField(spinup_info, (:helpers, modelHelpers));
    return spinup_info
end

function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:forward})
    # out_spin = runForward(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo.variables, modelInfo.helpers)
    out_spin = loopTimeSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo.helpers)
    return out_spin
end

function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:ODE_Tsit5})
    for sel_pool in modelInfo.spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models, sel_spinup_forcing, Symbol(sel_pool), init_out, modelInfo.helpers);
        tspan = (0.0, modelInfo.spinup.diffEq.timeJump)
        init_pool = getfield(p_info.init_out[:pools], p_info.pool);
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info);
        ode_sol = solve(ode_prob, Tsit5())#, reltol=modelInfo.spinup.diffEq.reltol, abstol=modelInfo.spinup.diffEq.abstol)
        init_pool .= ode_sol.u[end]
    end
    return init_out
end

function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_DynamicSS_Tsit5})
    for sel_pool in modelInfo.spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models, sel_spinup_forcing, Symbol(sel_pool), init_out, modelInfo.helpers);
        init_pool = getfield(p_info.init_out[:pools], p_info.pool);
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob,DynamicSS(Tsit5()))
        init_pool .= ssp_sol
    end
    return init_out
end


function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_SSRootfind})
    for sel_pool in modelInfo.spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models, sel_spinup_forcing, Symbol(sel_pool), init_out, modelInfo.helpers);
        init_pool = getfield(p_info.init_out[:pools], p_info.pool);
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob,SSRootfind())
        init_pool .= ssp_sol
    end
    return init_out
end

function loopTimeSpinup(sel_spinup_models, sel_spinup_forcing, out, modelHelpers)
    tsteps = size(sel_spinup_forcing, 1)
    for t in 1:tsteps
        out = runModels(sel_spinup_forcing[t], sel_spinup_models, out, modelHelpers)
    end
    return out
end

"""
runSpinup(forward_models, forcing, out, modelInfo; spinup_forcing=nothing)
"""
function runSpinup(forward_models, forcing, out, modelInfo; spinup_forcing=nothing)
    seqN = 1
    # out = runPrecompute(forcing[1], modelInfo.models.forward, out, modelInfo.helpers);
    history = modelInfo.spinup.flags.storeSpinupHistory;
    spinuplog = history ? [values(out)[1:length(out.pools)]] : nothing
    for spin_seq in modelInfo.spinup.sequence
        forc = Symbol(spin_seq["forcing"])
        nLoops = spin_seq["nLoops"]
        spinupMode = Symbol(spin_seq["spinupMode"])

        sel_forcing = forcing
        if !isnothing(spinup_forcing)
            sel_forcing = spinup_forcing[forc]
        end

        if spinupMode == :forward
            spinup_models = forward_models
        else
            spinup_models = forward_models[modelInfo.models.is_spinup.==1]
        end
        for nL in 1:nLoops
            @info "Spinup:: sequence: $(seqN), spinupMode: $(spinupMode), forcing: $(forc), Loop: $(nL)"
            out = doSpinup(spinup_models, sel_forcing, out, modelInfo, Val(spinupMode))
            if history
                push!(spinuplog, values(deepcopy(out))[1:length(out.pools)])
            end
        end
        seqN += 1
    end
    return (out, spinuplog)
end
