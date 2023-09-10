export getDeltaPool
export getSpinupInfo
export runSpinup
export spinupTEM
export timeLoopTEMSpinup

struct RunSpinup_TWS{M,F,T,I,O}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    forcing_one_timestep::O
end

struct RunSpinup_cEco_TWS{M,F,T,I,O,TWS}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    forcing_one_timestep::O
    TWS::TWS
end


struct RunSpinup_cEco{M,F,T,I,O}
    models::M
    forcing::F
    tem_helpers::T
    land::I
    forcing_one_timestep::O
end


"""
    cEco_spin::RunSpinup_cEco(pout, p)


"""
function (cEco_spin::RunSpinup_cEco)(pout, p)
    land = cEco_spin.land
    helpers = cEco_spin.tem_helpers
    zix = helpers.pools.zix

    pout .= exp.(p)

    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] => (cEco, lc, :cEco)
    end
    @pack_land cEco => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.cCycleBase.c_model)
    update_init = timeLoopTEMSpinup(cEco_spin.models, cEco_spin.forcing, cEco_spin.forcing_one_timestep, land, cEco_spin.tem_helpers)

    pout .= log.(update_init.pools.cEco)
    return nothing
end


"""
    cEco_TWS_spin::RunSpinup_cEco_TWS(pout, p)


"""
function (cEco_TWS_spin::RunSpinup_cEco_TWS)(pout, p)
    land = cEco_TWS_spin.land
    helpers = cEco_TWS_spin.tem_helpers
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

    update_init = timeLoopTEMSpinup(cEco_TWS_spin.models, cEco_TWS_spin.forcing, cEco_TWS_spin.forcing_one_timestep, land, cEco_TWS_spin.tem_helpers)

    pout .= log.(update_init.pools.cEco)
    cEco_TWS_spin.TWS .= update_init.pools.TWS
    return nothing
end

"""
    TWS_spin::RunSpinup_TWS(pout, p)


"""
function (TWS_spin::RunSpinup_TWS)(pout, p)
    land = TWS_spin.land
    helpers = TWS_spin.tem_helpers
    zix = helpers.pools.zix

    TWS = land.pools.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem maxZero(p[l]) => (TWS, lc, :TWS)
    end
    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.wCycleBase.w_model)
    update_init = timeLoopTEMSpinup(TWS_spin.models, TWS_spin.forcing, TWS_spin.forcing_one_timestep, land, TWS_spin.tem_helpers)
    pout .= update_init.pools.TWS
    return nothing
end


"""
getDeltaPool(pool_dat, spinup_info, t)
helper function to run the spinup models and return the delta in a given pool over the simulation. Used in solvers from DifferentialEquations.jl.
"""

"""
    getDeltaPool(pool_dat::AbstractArray, spinup_info, t)



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
    land = setTupleSubfield(land, :pools, (spinup_info.pool, pool_dat))

    land = timeLoopTEMSpinup(
        spinup_models,
        spinup_forcing,
        forcing_one_timestep,
        deepcopy(land),
        tem_helpers)
    tmp = getfield(land.pools, spinup_info.pool)
    Δpool = tmp - pool_dat
    return Δpool
end

"""
getSpinupInfo(spinup_models, spinup_forcing, spinup_pool_name, land, tem_helpers)
helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.
"""

"""
    getSpinupInfo(spinup_models, spinup_forcing, forcing_one_timestep, land, spinup_pool_name, tem_helpers, tem_spinup)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten- `spinup_pool_name`: DESCRIPTION
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
"""
function getSpinupInfo(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    spinup_pool_name,
    tem_helpers,
    tem_spinup)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name))
    spinup_info = setTupleField(spinup_info, (:land, land))
    spinup_info = setTupleField(spinup_info, (:spinup_forcing, spinup_forcing))
    spinup_info = setTupleField(spinup_info, (:spinup_models, spinup_models))
    spinup_info = setTupleField(spinup_info, (:tem_helpers, tem_helpers))
    spinup_info = setTupleField(spinup_info, (:tem_spinup, tem_spinup))
    spinup_info = setTupleField(spinup_info, (:forcing_one_timestep, forcing_one_timestep))
    return spinup_info
end


"""
    loadSpinup(_, tem_spinup, ::DoLoadSpinup)



# Arguments:
- `_`: unused argument
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::DoLoadSpinup`: DESCRIPTION
"""
function loadSpinup(_, tem_spinup, ::DoLoadSpinup) # when load_spinup is true
    @info "spinupTEM:: loading spinup data from $(tem_spinup.paths.restart_file_in)..."
    restart_data = load(tem_spinup.paths.restart_file_in)
    land = restart_data["land"]
    return land
end

"""
    loadSpinup(land, _, ::DoNotLoadSpinup)



# Arguments:
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `_`: unused argument
- `::DoNotLoadSpinup`: DESCRIPTION
"""
function loadSpinup(land, _, ::DoNotLoadSpinup) # when load_spinup is false
    return land
end

"""
    runSpinup(_, _, _, land, _, _, _, ::DoNotRunSpinup)



# Arguments:
- `_`: unused argument
- `_`: unused argument
- `_`: unused argument
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `_`: unused argument
- `_`: unused argument
- `_`: unused argument
- `DoNotRunSpinup`: a dispatch to not run spinup
"""
function runSpinup(_, _, _, land, _, _, _, ::DoNotRunSpinup) # dont do the spinup
    return land
end


"""
    runSpinup(selected_models, forcing, forcing_one_timestep, land, tem_helpers, tem_models, tem_spinup, ::DoRunSpinup)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::DoRunSpinup`: DESCRIPTION
"""
function runSpinup(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::DoRunSpinup) # do the spinup
    spinup_forcing = getSpinupForcing(forcing, forcing_one_timestep, tem_spinup.sequence, tem_helpers)
    seq_index = 1
    log_index = 1
    for spin_seq ∈ tem_spinup.sequence
        forc_name = spin_seq.forcing
        n_repeat = spin_seq.n_repeat
        spinup_mode = spin_seq.spinup_mode
        sel_forcing = spinup_forcing[forc_name]
        # sel_forcing = getSpinupForcing(forcing, forcing_one_timestep, spin_seq.aggregator, tem_helpers, spin_seq.aggregator_type)
        spinup_models = selected_models
        if spinup_mode == :spinup
            spinup_models = selected_models[tem_models.is_spinup]
        end
        land = inn_loop(spinup_models,
            sel_forcing,
            forcing_one_timestep,
            land,
            tem_helpers,
            tem_spinup,
            spinup_mode,
            n_repeat,
            log_index)
    # for loop_index ∈ 1:n_repeat
    #         land = inn_loop(spinup_models,
    #         sel_forcing,
    #         forcing_one_timestep,
    #         land,
    #         tem_helpers,
    #         tem_spinup,
    #         spinup_mode,
    #         n_repeat)
            # @debug "     sequence: $(seq_index), spinup_mode: $(nameof(typeof(spinup_mode))), forcing: $(forc_name), Loop: $(loop_index)/$(n_repeat)"
            # land = runSpinup(spinup_models,
            #     sel_forcing,
            #     forcing_one_timestep,
            #     land,
            #     tem_helpers,
            #     tem_spinup,
            #     spinup_mode)
            # land = setSpinupLog(land, log_index, tem_helpers.run.spinup.store_spinup)
            log_index += n_repeat
        # end
        seq_index += 1
    end
    return land
end

function inn_loop(spinup_models,
    sel_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_spinup,
    spinup_mode,
    n_repeat,
    log_loop)
    for loop_index ∈ 1:n_repeat
        @debug "     sequence: $(seq_index), spinup_mode: $(nameof(typeof(spinup_mode))), forcing: $(forc_name), Loop: $(loop_index)/$(n_repeat)"
        land = runSpinup(spinup_models,
            sel_forcing,
            forcing_one_timestep,
            land,
            tem_helpers,
            tem_spinup,
            spinup_mode)
        land = setSpinupLog(land, log_loop, tem_helpers.run.spinup.store_spinup)
        log_loop += 1
    end
    return land
end
"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, SelSpinupModels)

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
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::SelSpinupModels)
    land = timeLoopTEMSpinup(spinup_models,
        spinup_forcing,
        forcing_one_timestep,
        land,
        tem_helpers)
    return land
end

"""
runSpinup(all_models, spinup_forcing, land, tem, ::AllForwardModels})
do/run the spinup and update the state using a simple timeloop through the input models given in spinup_models. In case of :forward, all the models chosen in model_structure.json are run.
"""

"""
    runSpinup(all_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::AllForwardModels)



# Arguments:
- `all_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::AllForwardModels`: a dispatch type of run all models
"""
function runSpinup(
    all_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::AllForwardModels)
    land = timeLoopTEMSpinup(all_models,
        spinup_forcing,
        forcing_one_timestep,
        land,
        tem_helpers)
    return land
end


"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::NlsolveFixedpointTrustregionTWS)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::NlsolveFixedpointTrustregionTWS`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::NlsolveFixedpointTrustregionTWS)
    TWS_spin = RunSpinup_TWS(spinup_models, spinup_forcing, tem_helpers, land, forcing_one_timestep)
    r = fixedpoint(TWS_spin, Vector(deepcopy(land.pools.TWS)); method=:trust_region)
    TWS = r.zero
    TWS = oftype(land.pools.TWS, TWS)
    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.wCycleBase.w_model)
    return land
end

"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::NlsolveFixedpointTrustregionCEcoTWS)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::NlsolveFixedpointTrustregionCEcoTWS`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::NlsolveFixedpointTrustregionCEcoTWS)
    cEco_TWS_spin = RunSpinup_cEco_TWS(spinup_models, spinup_forcing, tem_helpers, deepcopy(land), forcing_one_timestep, Vector(deepcopy(land.pools.TWS)))
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
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, ::NlsolveFixedpointTrustregionCEco)



# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::NlsolveFixedpointTrustregionCEco`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::NlsolveFixedpointTrustregionCEco)
    cEco_spin = RunSpinup_cEco(spinup_models, spinup_forcing, tem_helpers, deepcopy(land), forcing_one_timestep)
    p_init = log.(Vector(deepcopy(land.pools.cEco)))
    r = fixedpoint(cEco_spin, p_init; method=:trust_region)
    cEco = exp.(r.zero)
    cEco = oftype(land.pools.cEco, cEco)
    @pack_land cEco => land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.cCycleBase.c_model)
    return land
end



"""
    runSpinup(_, _, _, land, helpers, _, ::EtaScaleAH)

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
function runSpinup(_, _, _, land, helpers, _, ::EtaScaleAH)
    @unpack_land cEco ∈ land.pools
    cEco_prev = copy(cEco)
    ηH = land.wCycleBase.o_one
    if :ηH ∈ propertynames(land.cCycleBase)
        ηH = land.cCycleBase.ηH
    end
    ηA = land.wCycleBase.o_one
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
    runSpinup(_, _, _, land, helpers, _, ::EtaScaleA0H)

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
function runSpinup(_, _, _, land, helpers, _, ::EtaScaleA0H)
    @unpack_land cEco ∈ land.pools
    cEco_prev = copy(cEco)
    ηH = land.wCycleBase.o_one
    c_remain = land.wCycleBase.o_one
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
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::ODEAutoTsit5Rodas5)

do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::ODEAutoTsit5Rodas5`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_spinup,
    ::ODEAutoTsit5Rodas5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            spinup_models,
            spinup_forcing,
            forcing_one_timestep,
            land,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
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
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::ODEDP5)

do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::ODEDP5`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_spinup,
    ::ODEDP5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            spinup_models,
            spinup_forcing,
            forcing_one_timestep,
            land,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
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
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::ODETsit5)

do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::ODETsit5`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_spinup,
    ::ODETsit5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            spinup_models,
            spinup_forcing,
            forcing_one_timestep,
            land,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
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
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::SSPDynamicSSTsit5)

do/run the spinup using SteadyState solver and DynamicSS with Tsit5 method of DifferentialEquations.jl

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::SSPDynamicSSTsit5`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_spinup,
    ::SSPDynamicSSTsit5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            spinup_models,
            spinup_forcing,
            forcing_one_timestep,
            land,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, DynamicSS(Tsit5()))
        land = setTupleSubfield(land, :pools, (p_info.pool, ssp_sol.u))
    end
    return land
end


"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, tem_spinup, ::SSPSSRootfind)

do/run the spinup using SteadyState solver and SSRootfind method of DifferentialEquations.jl

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::SSPSSRootfind`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_spinup,
    ::SSPSSRootfind)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            spinup_models,
            spinup_forcing,
            forcing_one_timestep,
            land,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, SSRootfind())
        land = setTupleSubfield(land, :pools, (p_info.pool, ssp_sol.u))
    end
    return land
end

=#



"""
    spinupTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, tem_models, tem_spinup)

The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using runSpinup functions for different spinup methods.

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
"""
function spinupTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    tem_models,
    tem_spinup)

    #todo probably the load and save spinup have to move outside. As of now, only pixel values are saved as the data reaching here are mapped through mapEco or mapOpt or runTEM!. Need to figure out but not critical as long as the spinup is not the bottleneck...
    land = loadSpinup(land, tem_spinup, tem_helpers.run.spinup.load_spinup)

    #check if the spinup still needs to be done after loading spinup
    land = runSpinup(selected_models, forcing, forcing_one_timestep, land, tem_helpers, tem_models, tem_spinup, tem_helpers.run.spinup.run_spinup)

    saveSpinup(land, tem_spinup, tem_helpers.run.spinup.save_spinup)
    return land
end

"""
    saveSpinup(land, tem_spinup, ::DoSaveSpinup)



# Arguments:
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::DoSaveSpinup`: DESCRIPTION
"""
function saveSpinup(land, tem_spinup, ::DoSaveSpinup) # save the spinup
    spin_file = tem_spinup.paths.restart_file_out
    @info "spinupTEM:: saving spinup data to $(spin_file)..."
    @save spin_file land
    return nothing
end

"""
    saveSpinup(_, _, ::DoNotSaveSpinup)



# Arguments:
- `_`: unused argument
- `_`: unused argument
- `::DoNotSaveSpinup`: DESCRIPTION
"""
function saveSpinup(_, _, ::DoNotSaveSpinup) # dont save the spinup
    return nothing
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


"""
    timeLoopTEMSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers)

do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the land/land is overwritten with every iteration. Only the state at the end is returned

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function timeLoopTEMSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers)
    for ts ∈ eachindex(spinup_forcing[1])
        f_ts = getForcingForTimeStep(spinup_forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(spinup_models, f_ts, land, tem_helpers)
    end
    return land
end