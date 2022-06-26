export doSpinup, getDeltaPool, getSpinupInfo, runSpinup, loopTimeSpinup

"""
getDeltaPool(pool_dat, spinup_info, t)
helper function to run the spinup models and return the delta in a given pool over the simulation. Used in solvers from DifferentialEquations.jl.
"""
function getDeltaPool(pool_dat, spinup_info, t)
    out = spinup_info.init_out;
    out = setTupleSubfield(out, :pools, (spinup_info.pool, pool_dat))
    outsmodel = loopTimeSpinup(spinup_info.sel_spinup_models, spinup_info.sel_spinup_forcing, spinup_info.init_out, spinup_info.helpers)
    # @time outsmodel = runForward(spinup_info.sel_spinup_models, spinup_info.sel_spinup_forcing, spinup_info.init_out, spinup_info.helpers)
    tmp = getfield(outsmodel.pools |> columntable, spinup_info.pool)
    Δpool = tmp - pool_dat
    # Δpool = tmp[end] - pool_dat
    return Δpool
end

"""
getSpinupInfo(sel_spinup_models, sel_spinup_forcing, spinup_pool_name, init_out, modelHelpers)
helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.
"""
function getSpinupInfo(sel_spinup_models, sel_spinup_forcing, spinup_pool_name, init_out, modelHelpers)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name));
    spinup_info = setTupleField(spinup_info, (:init_out, init_out));
    spinup_info = setTupleField(spinup_info, (:sel_spinup_forcing, sel_spinup_forcing));
    spinup_info = setTupleField(spinup_info, (:sel_spinup_models, sel_spinup_models));
    spinup_info = setTupleField(spinup_info, (:helpers, modelHelpers));
    return spinup_info
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:spinup})
do/run the spinup and update the state using a simple timeloop through the input models given in sel_spinup_models. In case of :spinup, only the models chosen as use4spinup in modelStructure.json are run.
"""
function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:spinup})
    out_spin = loopTimeSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo.helpers)
    return out_spin
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:forward})
do/run the spinup and update the state using a simple timeloop through the input models given in sel_spinup_models. In case of :forward, all the models chosen in modelStructure.json are run.
"""
function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:forward})
    out_spin = loopTimeSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo.helpers)
    return out_spin
end


"""
doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:ODE_Tsit5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:ODE_Tsit5})
    for sel_pool in modelInfo.spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models, sel_spinup_forcing, Symbol(sel_pool), init_out, modelInfo.helpers);
        tspan = (0.0, modelInfo.spinup.diffEq.timeJump)
        init_pool = deepcopy(getfield(p_info.init_out[:pools], p_info.pool));
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info);
        ode_sol = solve(ode_prob, Tsit5())#, reltol=modelInfo.spinup.diffEq.reltol, abstol=modelInfo.spinup.diffEq.abstol)
        init_out = setTupleSubfield(init_out, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return init_out
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_DynamicSS_Tsit5})
do/run the spinup using SteadyState solver and DynamicSS with Tsit5 method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_DynamicSS_Tsit5})
    for sel_pool in modelInfo.spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models, sel_spinup_forcing, Symbol(sel_pool), init_out, modelInfo.helpers);
        init_pool = deepcopy(getfield(p_info.init_out[:pools], p_info.pool));
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob,DynamicSS(Tsit5()))
        init_out = setTupleSubfield(init_out, :pools, (p_info.pool, ssp_sol.u))
    end
    return init_out
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_DynamicSS_Tsit5})
do/run the spinup using SteadyState solver and SSRootfind method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_SSRootfind})
    for sel_pool in modelInfo.spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models, sel_spinup_forcing, Symbol(sel_pool), init_out, modelInfo.helpers);
        init_pool = deepcopy(getfield(p_info.init_out[:pools], p_info.pool));
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob,SSRootfind())
        init_out = setTupleSubfield(init_out, :pools, (p_info.pool, ssp_sol.u))
    end
    return init_out
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, init_out, modelInfo, ::Val{:SSP_DynamicSS_Tsit5})
do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the out/land is overwritten with every iteration. Only the state at the end is returned.
"""
function loopTimeSpinup(sel_spinup_models, sel_spinup_forcing, out, modelHelpers)
    tsteps = size(sel_spinup_forcing, 1)
    for t in 1:tsteps
        out = runModels(sel_spinup_forcing[t], sel_spinup_models, out, modelHelpers)
    end
    return out
end

"""
runSpinup(forward_models, forcing, out, modelInfo; spinup_forcing=nothing)
The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using doSpinup functions for different spinup methods.
"""
function runSpinup(forward_models, forcing, init_out, modelInfo; spinup_forcing=nothing)
    if modelInfo.spinup.flags.loadSpinup
        out = init_out
        # TODO replace here by loading spinup from restartFile
        # load(modelInfo.spinup.paths.restartFile)
    end

    #check if the spinup still needs to be done after loading spinup
    if !modelInfo.spinup.flags.doSpinup
        return out
    end

    seqN = 1
    history = modelInfo.spinup.flags.storeSpinupHistory;
    out = deepcopy(init_out)
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
    if history
        @pack_land spinuplog => out.states
    end
    if modelInfo.spinup.flags.saveSpinup
        spin_file = modelInfo.spinup.paths.restartFile
        # TODO save out as spin_file. needs to consider the loading part as well.
    end
    return out
end
