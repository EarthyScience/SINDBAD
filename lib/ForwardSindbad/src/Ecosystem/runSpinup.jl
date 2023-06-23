export doSpinup, getDeltaPool, getSpinupInfo, runSpinup, loopTimeSpinup

"""
getDeltaPool(pool_dat, spinup_info, t)
helper function to run the spinup models and return the delta in a given pool over the simulation. Used in solvers from DifferentialEquations.jl.
"""
function getDeltaPool(pool_dat::AbstractArray, spinup_info, t::Any)
    land_spin = spinup_info.land_in
    tem_helpers = spinup_info.tem_helpers
    land_type = spinup_info.land_type
    sel_spinup_models = spinup_info.sel_spinup_models
    sel_spinup_forcing = spinup_info.sel_spinup_forcing
    f_one = spinup_info.f_one
    land_spin = setTupleSubfield(land_spin, :pools, (spinup_info.pool, pool_dat))

    land_spin = loopTimeSpinup(sel_spinup_models,
        sel_spinup_forcing,
        deepcopy(land_spin),
        tem_helpers,
        land_type,
        f_one)
    # land_spin = loopTimeSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem_helpers, land_type, f_one)
    # land_spinsmodel = loopTimeSpinup(spinup_info.sel_spinup_models, spinup_info.sel_spinup_forcing, spinup_info.land_in, spinup_info.helpers)
    # @time land_spinsmodel = runForward(spinup_info.sel_spinup_models, spinup_info.sel_spinup_forcing, spinup_info.land_in, spinup_info.helpers)
    tmp = getfield(land_spin.pools, spinup_info.pool)
    Δpool = tmp - pool_dat
    # Δpool = tmp[end] - pool_dat
    return Δpool
end

"""
getSpinupInfo(sel_spinup_models, sel_spinup_forcing, spinup_pool_name, land_in, tem_helpers)
helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.
"""
function getSpinupInfo(sel_spinup_models,
    sel_spinup_forcing,
    spinup_pool_name,
    land_in,
    tem_helpers,
    tem_spinup,
    land_type,
    f_one)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name))
    spinup_info = setTupleField(spinup_info, (:land_in, land_in))
    spinup_info = setTupleField(spinup_info, (:sel_spinup_forcing, sel_spinup_forcing))
    spinup_info = setTupleField(spinup_info, (:sel_spinup_models, sel_spinup_models))
    spinup_info = setTupleField(spinup_info, (:tem_helpers, tem_helpers))
    spinup_info = setTupleField(spinup_info, (:tem_spinup, tem_spinup))
    spinup_info = setTupleField(spinup_info, (:land_type, land_type))
    spinup_info = setTupleField(spinup_info, (:f_one, f_one))
    return spinup_info
end

"""
doSpinup(_, _, land, helpers, _, _, _, ::Val{:ηScaleAH})
scale the carbon pools using the scalars from cCycleBase
"""
function doSpinup(_, _, land, helpers, _, _, _, ::Val{:ηScaleAH})
    @unpack_land cEco ∈ land.pools
    ηH = helpers.numbers.𝟙
    if :ηH ∈ propertynames(land.cCycleBase)
        ηH = land.cCycleBase.ηH
    end
    ηA = helpers.numbers.𝟙
    if :ηA ∈ propertynames(land.cCycleBase)
        ηA = land.cCycleBase.ηA
    end
    for cSoilZix ∈ helpers.pools.zix.cSoil
        cSoilNew = cEco[cSoilZix] * ηH
        @rep_elem cSoilNew => (cEco, cSoilZix, :cEco)
    end
    for cLitZix ∈ helpers.pools.zix.cLit
        cLitNew = cEco[cLitZix] * ηH
        @rep_elem cLitNew => (cEco, cLitZix, :cEco)
    end
    for cVegZix ∈ helpers.pools.zix.cVeg
        cVegNew = cEco[cVegZix] * ηA
        @rep_elem cVegNew => (cEco, cVegZix, :cEco)
    end
    @pack_land cEco => land.pools
    return land
end


"""
doSpinup(_, _, land, helpers, _, _, _, ::Val{:ηScaleA0H})
scale the carbon pools using the scalars from cCycleBase
"""
function doSpinup(_, _, land, helpers, _, _, _, ::Val{:ηScaleA0H})
    @unpack_land cEco ∈ land.pools
    ηH = helpers.numbers.𝟙
    carbon_remain = helpers.numbers.𝟙
    if :ηH ∈ propertynames(land.cCycleBase)
        ηH = land.cCycleBase.ηH
        carbon_remain = land.cCycleBase.carbon_remain
    end

    for cSoilZix ∈ helpers.pools.zix.cSoil
        cSoilNew = cEco[cSoilZix] * ηH
        @rep_elem cSoilNew => (cEco, cSoilZix, :cEco)
    end

    for cLitZix ∈ helpers.pools.zix.cLit
        cLitNew = cEco[cLitZix] * ηH
        @rep_elem cLitNew => (cEco, cLitZix, :cEco)
    end

    for cVegZix ∈ helpers.pools.zix.cVeg
        cLoss = max(cEco[cVegZix] - carbon_remain, helpers.numbers.𝟘)
        cVegNew = cEco[cVegZix] - cLoss
        @rep_elem cVegNew => (cEco, cVegZix, :cEco)
    end

    @pack_land cEco => land.pools
    return land
end


"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:spinup})
do/run the spinup and update the state using a simple timeloop through the input models given in sel_spinup_models. In case of :spinup, only the models chosen as use4spinup in modelStructure.json are run.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:spinup})
    land_spin = loopTimeSpinup(sel_spinup_models,
        sel_spinup_forcing,
        land_in,
        tem_helpers,
        land_type,
        f_one)
    return land_spin
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:forward})
do/run the spinup and update the state using a simple timeloop through the input models given in sel_spinup_models. In case of :forward, all the models chosen in modelStructure.json are run.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    _,
    land_type,
    f_one,
    ::Val{:forward})
    land_spin = loopTimeSpinup(sel_spinup_models,
        sel_spinup_forcing,
        land_in,
        tem_helpers,
        land_type,
        f_one)
    return land_spin
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:ODE_Tsit5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    tem_spinup,
    land_type,
    f_one,
    ::Val{:ODE_Tsit5})
    for sel_pool ∈ tem_spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models,
            sel_spinup_forcing,
            Symbol(sel_pool),
            land_in,
            tem_helpers,
            tem_spinup,
            land_type,
            f_one)
        tspan = (tem_helpers.numbers.𝟘, tem_helpers.numbers.sNT(tem_spinup.diffEq.timeJump))
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        # maxIter = tem_spinup.diffEq.timeJump
        maxIter = max(ceil(tem_spinup.diffEq.timeJump) / 100, 100)
        ode_sol = solve(ode_prob, Tsit5(); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.diffEq.reltol, abstol=tem_spinup.diffEq.abstol, maxiters=maxIter)
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land_in
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:ODE_DP5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    tem_spinup,
    land_type,
    f_one,
    ::Val{:ODE_DP5})
    for sel_pool ∈ tem_spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models,
            sel_spinup_forcing,
            Symbol(sel_pool),
            land_in,
            tem_helpers,
            tem_spinup,
            land_type,
            f_one)
        tspan = (tem_helpers.numbers.𝟘, tem_helpers.numbers.sNT(tem_spinup.diffEq.timeJump))
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        maxIter = tem_spinup.diffEq.timeJump
        maxIter = max(ceil(tem_spinup.diffEq.timeJump) / 100, 100)
        ode_sol = solve(ode_prob, DP5(); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.diffEq.reltol, abstol=tem_spinup.diffEq.abstol, maxiters=maxIter)
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land_in
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:ODE_AutoTsit5_Rodas5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    tem_spinup,
    land_type,
    f_one,
    ::Val{:ODE_AutoTsit5_Rodas5})
    for sel_pool ∈ tem_spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models,
            sel_spinup_forcing,
            Symbol(sel_pool),
            land_in,
            tem_helpers,
            tem_spinup,
            land_type,
            f_one)
        tspan = (tem_helpers.numbers.𝟘, tem_helpers.numbers.sNT(tem_spinup.diffEq.timeJump))
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        maxIter = tem_spinup.diffEq.timeJump
        # maxIter = max(ceil(tem_spinup.diffEq.timeJump) / 100, 100)
        ode_sol = solve(ode_prob, AutoVern7(Rodas5()); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.diffEq.reltol, abstol=tem_spinup.diffEq.abstol, maxiters=maxIter)
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land_in
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:SSP_DynamicSS_Tsit5})
do/run the spinup using SteadyState solver and DynamicSS with Tsit5 method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    tem_spinup,
    land_type,
    f_one,
    ::Val{:SSP_DynamicSS_Tsit5})
    for sel_pool ∈ tem_spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models,
            sel_spinup_forcing,
            Symbol(sel_pool),
            land_in,
            tem_helpers,
            tem_spinup,
            land_type,
            f_one)
        tspan = (0.0, tem_spinup.diffEq.timeJump)
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, DynamicSS(Tsit5()))
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ssp_sol.u))
    end
    return land_in
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:SSP_DynamicSS_Tsit5})
do/run the spinup using SteadyState solver and SSRootfind method of DifferentialEquations.jl.
"""
function doSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_in,
    tem_helpers,
    tem_spinup,
    land_type,
    f_one,
    ::Val{:SSP_SSRootfind})
    for sel_pool ∈ tem_spinup.diffEq.pools
        p_info = getSpinupInfo(sel_spinup_models,
            sel_spinup_forcing,
            Symbol(sel_pool),
            land_in,
            tem_helpers,
            tem_spinup,
            land_type,
            f_one)
        tspan = (0.0, tem_spinup.diffEq.timeJump)
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, SSRootfind())
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ssp_sol.u))
    end
    return land_in
end

"""
runModels(forcing, models, out)
"""
function runSpinupModels!(out, forcing, models, tem_helpers, _)
    return foldl_unrolled(models; init=out) do o, model
        return o = Models.compute(model, forcing, o, tem_helpers)
    end
end

"""
doSpinup(sel_spinup_models, sel_spinup_forcing, land_spin, tem)
do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the land_spin/land is overwritten with every iteration. Only the state at the end is returned.
"""
function loopTimeSpinup(sel_spinup_models,
    sel_spinup_forcing,
    land_spin,
    tem_helpers,
    land_type,
    f_one)
    time_steps = getForcingTimeSize(sel_spinup_forcing, Val(keys(sel_spinup_forcing)))
    for t ∈ 1:time_steps
        f = getForcingForTimeStep(sel_spinup_forcing, Val(keys(sel_spinup_forcing)), t, f_one)
        land_spin = runSpinupModels!(land_spin, f, sel_spinup_models, tem_helpers, land_type)
    end
    return land_spin#::land_type
end

"""
runSpinup(forward_models, forcing, land_spin, tem; spinup_forcing=nothing)
The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using doSpinup functions for different spinup methods.
"""
function runSpinup(forward_models,
    forcing,
    land_in,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_type,
    f_one;
    spinup_forcing=nothing)
    #todo probably the load and save spinup have to move outside. As of now, only pixel values are saved as the data reaching here are mapped through mapEco or mapOpt or runEcosystem. Need to figure out...
    land_spin = land_in
    if tem_spinup.flags.loadSpinup
        @info "runSpinup:: loading spinup data from $(tem_spinup.paths.restartFileIn)..."
        restart_data = load(tem_spinup.paths.restartFileIn)
        land_spin = restart_data["land_spin"]
    end

    #check if the spinup still needs to be done after loading spinup
    if !tem_spinup.flags.doSpinup
        return land_spin
    end

    seqN = 1
    history = tem_spinup.flags.storeSpinupHistory
    land_spin = land_in
    # land_spin = deepcopy(land_in)
    spinuplog = history ? [values(land_spin)[1:length(land_spin.pools)]] : nothing
    # @info "runSpinup:: running spinup sequences..."
    for spin_seq ∈ tem_spinup.sequence
        forc = Symbol(spin_seq.forcing)
        nLoops = spin_seq.nLoops
        spinupMode = Symbol(spin_seq.spinupMode)

        sel_forcing = forcing
        if isnothing(spinup_forcing)
            sel_forcing = getSpinupForcing(forcing, tem_helpers, Val(forc))
            # sel_forcing = getSpinupForcing(forcing, tem_helpers, f_one, Val(forc))
        else
            sel_forcing = spinup_forcing[forc]
        end

        spinup_models = forward_models
        if spinupMode == :spinup
            spinup_models = forward_models[tem_models.is_spinup]
        end
        # if !tem_helpers.run.runOpti
        #     @info "     sequence: $(seqN), spinupMode: $(spinupMode), forcing: $(forc)"
        # end
        for nL ∈ 1:nLoops
            # @showprogress "Computing nLoops..." for nL in 1:nLoops
            # if !tem_helpers.run.runOpti
            #     println("         Loop: $(nL)/$(nLoops)")
            # end
            land_spin = doSpinup(spinup_models,
                sel_forcing,
                land_spin,
                tem_helpers,
                tem_spinup,
                land_type,
                f_one,
                Val(spinupMode))
            if history
                push!(spinuplog, values(deepcopy(land_spin))[1:length(land_spin.pools)])
            end
        end
        seqN += 1
    end
    if history
        @pack_land spinuplog => land_spin.states
    end
    if tem_spinup.flags.saveSpinup
        spin_file = tem_spinup.paths.restartFileOut
        @info "runSpinup:: saving spinup data to $(spin_file)..."
        @save spin_file land_spin
    end
    return land_spin
end
