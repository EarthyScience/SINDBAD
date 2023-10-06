export getDeltaPool
export getSpinupInfo
export spinup
export spinupTEM
export timeLoopTEMSpinup

struct Spinup_TWS{M,F,T,I,O,N}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    forcing_one_timestep::O
    n_timesteps::N
end

struct Spinup_cEco_TWS{M,F,T,I,O,N,TWS}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    forcing_one_timestep::O
    n_timesteps::N
    TWS::TWS
end


struct Spinup_cEco{M,F,T,I,O,N}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    forcing_one_timestep::O
    n_timesteps::N
end


"""
    cEco_spin::Spinup_cEco(pout, p)


"""
function (cEco_spin::Spinup_cEco)(pout, p)
    land = cEco_spin.land
    helpers = cEco_spin.tem_helpers.model_helpers
    n_timesteps = cEco_spin.n_timesteps
    zix = helpers.pools.zix

    pout .= exp.(p)

    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.cCycleBase.c_model)
    update_init = timeLoopTEMSpinup(cEco_spin.models, cEco_spin.forcing, cEco_spin.forcing_one_timestep, land, cEco_spin.tem_helpers, n_timesteps)

    pout .= log.(update_init.pools.cEco)
    return nothing
end


"""
    cEco_TWS_spin::Spinup_cEco_TWS(pout, p)


"""
function (cEco_TWS_spin::Spinup_cEco_TWS)(pout, p)
    land = cEco_TWS_spin.land
    helpers = cEco_TWS_spin.tem_helpers.model_helpers
    n_timesteps = cEco_TWS_spin.n_timesteps
    zix = helpers.pools.zix

    pout .= exp.(p)

    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.cCycleBase.c_model)

    TWS = land.pools.TWS
    TWS_prev = cEco_TWS_spin.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem TWS_prev[l] => (TWS, lc, :TWS)
    end

    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.wCycleBase.w_model)

    update_init = timeLoopTEMSpinup(cEco_TWS_spin.models, cEco_TWS_spin.forcing, cEco_TWS_spin.forcing_one_timestep, land, cEco_TWS_spin.tem_helpers, n_timesteps)

    pout .= log.(update_init.pools.cEco)
    cEco_TWS_spin.TWS .= update_init.pools.TWS
    return nothing
end

"""
    TWS_spin::Spinup_TWS(pout, p)


"""
function (TWS_spin::Spinup_TWS)(pout, p)
    land = TWS_spin.land
    helpers = TWS_spin.tem_helpers.model_helpers
    n_timesteps = TWS_spin.n_timesteps
    zix = helpers.pools.zix

    TWS = land.pools.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem maxZero(p[l]) => (TWS, lc, :TWS)
    end
    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.wCycleBase.w_model)
    update_init = timeLoopTEMSpinup(TWS_spin.models, TWS_spin.forcing, TWS_spin.forcing_one_timestep, land, TWS_spin.tem_helpers, n_timesteps)
    pout .= update_init.pools.TWS
    return nothing
end


"""
    getDeltaPool(pool_dat::AbstractArray, spinup_info, t)

helper function to run the spinup models and return the delta in a given pool over the simulation. Used in solvers from DifferentialEquations.jl.


# Arguments:
- `pool_dat`: DESCRIPTION
- `spinup_info`: DESCRIPTION
- `t`: DESCRIPTION
"""
function getDeltaPool(pool_dat::AbstractArray, spinup_info, _)
    land = spinup_info.land
    tem_helpers = spinup_info.tem_helpers
    spinup_models = spinup_info.spinup_models
    spinup_forcing = spinup_info.spinup_forcing
    forcing_one_timestep = spinup_info.forcing_one_timestep
    n_timesteps = spinup_info.n_timesteps
    land = setTupleSubfield(land, :pools, (spinup_info.pool, pool_dat))

    land = timeLoopTEMSpinup(spinup_models, spinup_forcing, forcing_one_timestep, deepcopy(land), tem_helpers, n_timesteps)
    tmp = getfield(land.pools, spinup_info.pool)
    Δpool = tmp - pool_dat
    return Δpool
end

"""
    getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, spinup_pool_name, tem_helpers, tem_spinup)

helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.


# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten- `spinup_pool_name`: DESCRIPTION
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, spinup_pool_name, tem_helpers, n_timesteps)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name))
    spinup_info = setTupleField(spinup_info, (:land, land))
    spinup_info = setTupleField(spinup_info, (:spinup_forcing, spinup_forcing))
    spinup_info = setTupleField(spinup_info, (:spinup_models, spinup_models))
    spinup_info = setTupleField(spinup_info, (:tem_helpers, tem_helpers))
    spinup_info = setTupleField(spinup_info, (:forcing_one_timestep, forcing_one_timestep))
    spinup_info = setTupleField(spinup_info, (:n_timesteps, n_timesteps))
    return spinup_info
end

"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, SelSpinupModels)

do/run the spinup and update the state using a simple timeloop through the input models given in spinup_models. In case of :spinup, only the models chosen as use_in_spinup in model_structure.json are run.

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::SelSpinupModels`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::SelSpinupModels)
    land = timeLoopTEMSpinup(spinup_models,
        spinup_forcing,
        forcing_one_timestep,
        land,
        tem_helpers,
        n_timesteps)
    return land
end

"""
spinup(all_models, spinup_forcing, land, tem, ::AllForwardModels})
do/run the spinup and update the state using a simple timeloop through the input models given in spinup_models. In case of :forward, all the models chosen in model_structure.json are run.
"""

"""
    spinup(all_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::AllForwardModels)



# Arguments:
- `all_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::AllForwardModels`: a dispatch type of run all models
"""
function spinup(all_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::AllForwardModels)
    land = timeLoopTEMSpinup(all_models,
        spinup_forcing,
        forcing_one_timestep,
        land,
        tem_helpers,
        n_timesteps)
    return land
end


"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::NlsolveFixedpointTrustregionTWS)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::NlsolveFixedpointTrustregionTWS`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::NlsolveFixedpointTrustregionTWS)
    TWS_spin = Spinup_TWS(spinup_models, spinup_forcing, tem_helpers, land, forcing_one_timestep, n_timesteps)
    r = fixedpoint(TWS_spin, Vector(deepcopy(land.pools.TWS)); method=:trust_region)
    TWS = r.zero
    TWS = oftype(land.pools.TWS, TWS)
    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.wCycleBase.w_model)
    return land
end

"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::NlsolveFixedpointTrustregionCEcoTWS)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::NlsolveFixedpointTrustregionCEcoTWS`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::NlsolveFixedpointTrustregionCEcoTWS)
    cEco_TWS_spin = Spinup_cEco_TWS(spinup_models, spinup_forcing, tem_helpers, deepcopy(land), forcing_one_timestep, n_timesteps, Vector(deepcopy(land.pools.TWS)))
    p_init = log.(Vector(deepcopy(land.pools.cEco)))
    # r = fixedpoint(cEco_TWS_spin, p_init; method=:trust_region)
    # cEco = exp.(r.zero)
    cEco = land.pools.cEco
    try
        r = fixedpoint(cEco_TWS_spin, p_init; method=:trust_region)
        cEco = exp.(r.zero)
    catch
        cEco = land.pools.cEco
    end
    cEco = oftype(land.pools.cEco, cEco)
    @pack_land cEco => land.pools
    TWS_prev = cEco_TWS_spin.TWS
    TWS = oftype(land.pools.TWS, TWS_prev)
    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.cCycleBase.c_model)
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.wCycleBase.w_model)
    return land
end


"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::NlsolveFixedpointTrustregionCEco)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::NlsolveFixedpointTrustregionCEco`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::NlsolveFixedpointTrustregionCEco)
    cEco_spin = Spinup_cEco(spinup_models, spinup_forcing, tem_helpers, deepcopy(land), forcing_one_timestep, n_timesteps)
    p_init = log.(Vector(deepcopy(land.pools.cEco)))
    r = fixedpoint(cEco_spin, p_init; method=:trust_region)
    cEco = exp.(r.zero)
    cEco = oftype(land.pools.cEco, cEco)
    @pack_land cEco => land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.cCycleBase.c_model)
    return land
end



"""
    spinup(_, _, _, land, helpers, _, ::EtaScaleAH)

scale the carbon pools using the scalars from cCycleBase

# Arguments:
- `_`: unused argument
- `_`: unused argument
- `_`: unused argument
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::EtaScaleAH`: DESCRIPTION
"""
function spinup(_, _, _, land, helpers, _, ::EtaScaleAH)
    @unpack_land cEco ∈ land.pools
    helpers = helpers.model_helpers
    cEco_prev = copy(cEco)
    ηH = one(eltype(cEco))
    if :ηH ∈ propertynames(land.cCycleBase)
        ηH = land.cCycleBase.ηH
    end
    ηA = one(eltype(cEco))
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
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.cCycleBase.c_model)
    @pack_land cEco_prev => land.states
    return land
end


"""
    spinup(_, _, _, land, helpers, _, ::EtaScaleA0H)

scale the carbon pools using the scalars from cCycleBase

# Arguments:
- `_`: unused argument
- `_`: unused argument
- `_`: unused argument
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `EtaScaleA0H`: DESCRIPTION
"""
function spinup(_, _, _, land, helpers, _, ::EtaScaleA0H)
    @unpack_land cEco ∈ land.pools
    helpers = helpers.model_helpers
    cEco_prev = copy(cEco)
    ηH = one(eltype(cEco))
    c_remain = one(eltype(cEco))
    if :ηH ∈ propertynames(land.cCycleBase)
        ηH = land.cCycleBase.ηH
        c_remain = land.cCycleBase.c_remain
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
        cLoss = maxZero(cEco[cVegZix] - c_remain)
        cVegNew = cEco[cVegZix] - cLoss
        @rep_elem cVegNew => (cEco, cVegZix, :cEco)
    end

    @pack_land cEco => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.cCycleBase.c_model)
    @pack_land cEco_prev => land.states
    return land
end

#=


"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::ODEAutoTsit5Rodas5)

do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::ODEAutoTsit5Rodas5`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::ODEAutoTsit5Rodas5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, Symbol(sel_pool), tem_helpers, n_timesteps)
        tspan = (0.0, tem_helpers.numbers.sNT(tem_spinup.differential_eqn.time_jump))
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        maxIter = tem_spinup.differential_eqn.time_jump
        # maxIter = max(ceil(tem_spinup.differential_eqn.time_jump) / 100, 100)
        ode_sol = solve(ode_prob, AutoVern7(Rodas5()); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.differential_eqn.relative_tolerance, abstol=tem_spinup.differential_eqn.absolute_tolerance, maxiters=maxIter)
        land = setTupleSubfield(land, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land
end


"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::ODEDP5)

do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::ODEDP5`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::ODEDP5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, Symbol(sel_pool), tem_helpers, n_timesteps)
        tspan = (0.0, tem_helpers.numbers.sNT(tem_spinup.differential_eqn.time_jump))
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        maxIter = tem_spinup.differential_eqn.time_jump
        maxIter = max(ceil(tem_spinup.differential_eqn.time_jump) / 100, 100)
        ode_sol = solve(ode_prob, DP5(); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.differential_eqn.relative_tolerance, abstol=tem_spinup.differential_eqn.absolute_tolerance, maxiters=maxIter)
        land = setTupleSubfield(land, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land
end



"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::ODETsit5)

do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::ODETsit5`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::ODETsit5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, Symbol(sel_pool), tem_helpers, n_timesteps)
        tspan = (0.0, tem_helpers.numbers.sNT(tem_spinup.differential_eqn.time_jump))
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        # maxIter = tem_spinup.differential_eqn.time_jump
        maxIter = max(ceil(tem_spinup.differential_eqn.time_jump) / 100, 100)
        ode_sol = solve(ode_prob, Tsit5(); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.differential_eqn.relative_tolerance, abstol=tem_spinup.differential_eqn.absolute_tolerance, maxiters=maxIter)
        land = setTupleSubfield(land, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land
end


"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::SSPDynamicSSTsit5)

do/run the spinup using SteadyState solver and DynamicSS with Tsit5 method of DifferentialEquations.jl

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::SSPDynamicSSTsit5`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::SSPDynamicSSTsit5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, Symbol(sel_pool), tem_helpers, n_timesteps)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, DynamicSS(Tsit5()))
        land = setTupleSubfield(land, :pools, (p_info.pool, ssp_sol.u))
    end
    return land
end


"""
    spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::SSPSSRootfind)

do/run the spinup using SteadyState solver and SSRootfind method of DifferentialEquations.jl

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::SSPSSRootfind`: DESCRIPTION
"""
function spinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, ::SSPSSRootfind)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, Symbol(sel_pool), tem_helpers, n_timesteps)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, SSRootfind())
        land = setTupleSubfield(land, :pools, (p_info.pool, ssp_sol.u))
    end
    return land
end

=#

function sequenceForcing(spinup_forcings::NamedTuple, forc_name::Symbol)
    return spinup_forcings[forc_name]::NamedTuple
end


function sequenceLoop(spinup_models, sel_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, log_loop, n_repeat, spinup_mode)
    for loop_index ∈ 1:n_repeat
        @debug "        Loop: $(loop_index)/$(n_repeat)"
        land = spinup(spinup_models,
            sel_forcing,
            forcing_one_timestep,
            land,
            tem_helpers,
            n_timesteps,
            spinup_mode)
        # land = setSpinupLog(land, log_loop, tem_helpers.run.store_spinup)
        log_loop += 1
    end
    return land
end


"""
    setSpinupLog(land, log_index, ::DoStoreSpinup)



# Arguments:
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `log_index`: DESCRIPTION
- `::DoStoreSpinup`: DESCRIPTION
"""
function setSpinupLog(land, log_index, ::DoStoreSpinup)
    land.states.spinuplog[log_index] = land.pools
    return land
end

"""
    setSpinupLog(land, _, ::DoNotStoreSpinup)



# Arguments:
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `_`: unused argument
- `::DoNotStoreSpinup`: DESCRIPTION
"""
function setSpinupLog(land, _, ::DoNotStoreSpinup)
    return land
end

function spinupSequence(spinup_models, sel_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, log_index, n_repeat, spinup_mode)
    land = sequenceLoop(spinup_models, sel_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, log_index, n_repeat, spinup_mode)
    # end
    return land
end


"""
    spinupTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, tem_spinup)

The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using spinup functions for different spinup methods.

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
"""
function spinupTEM(selected_models, spinup_forcings, forcing_one_timestep, land, tem_helpers, tem_spinup)
    log_index = 1
    for spin_seq ∈ tem_spinup.sequence
        forc_name = spin_seq.forcing
        n_timesteps = spin_seq.n_timesteps
        n_repeat = spin_seq.n_repeat
        spinup_mode = spin_seq.spinup_mode
        @debug "Spinup: \n         spinup_mode: $(nameof(typeof(spinup_mode))), forcing: $(forc_name)"
        sel_forcing = sequenceForcing(spinup_forcings, forc_name)
        land = spinupSequence(selected_models, sel_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps, log_index, n_repeat, spinup_mode)
        log_index += n_repeat
    end
    return land
end



"""
    timeLoopTEMSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps)

do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the land/land is overwritten with every iteration. Only the state at the end is returned

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `n_timesteps`: number of time steps
"""
function timeLoopTEMSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, n_timesteps)
    for ts ∈ 1:n_timesteps
        f_ts = getForcingForTimeStep(spinup_forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_types)
        land = computeTEM(spinup_models, f_ts, land, tem_helpers.model_helpers)
    end
    return land
end