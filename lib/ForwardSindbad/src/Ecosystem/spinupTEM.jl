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

DOCSTRING
"""
function (cEco_spin::RunSpinup_cEco)(pout, p)
    land = cEco_spin.land
    helpers = cEco_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers

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

DOCSTRING
"""
function (cEco_TWS_spin::RunSpinup_cEco_TWS)(pout, p)
    land = cEco_TWS_spin.land
    helpers = cEco_TWS_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers

    pout .= exp.(p)

    @unpack_land 𝟘 ∈ helpers.numbers
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

DOCSTRING
"""
function (TWS_spin::RunSpinup_TWS)(pout, p)
    land = TWS_spin.land
    helpers = TWS_spin.tem_helpers
    zix = helpers.pools.zix
    @unpack_land 𝟘 ∈ helpers.numbers

    TWS = land.pools.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem max0(p[l]) => (TWS, lc, :TWS)
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

DOCSTRING

# Arguments:
- `pool_dat`: DESCRIPTION
- `spinup_info`: DESCRIPTION
- `t`: DESCRIPTION
"""
function getDeltaPool(pool_dat::AbstractArray, spinup_info, t::Any)
    land_spin = spinup_info.land_in
    tem_helpers = spinup_info.tem_helpers
    sel_spinup_models = spinup_info.sel_spinup_models
    sel_spinup_forcing = spinup_info.sel_spinup_forcing
    forcing_one_timestep = spinup_info.forcing_one_timestep
    land_spin = setTupleSubfield(land_spin, :pools, (spinup_info.pool, pool_dat))

    land_spin = timeLoopTEMSpinup(
        sel_spinup_models,
        sel_spinup_forcing,
        forcing_one_timestep,
        deepcopy(land_spin),
        tem_helpers)
    tmp = getfield(land_spin.pools, spinup_info.pool)
    Δpool = tmp - pool_dat
    return Δpool
end

"""
getSpinupInfo(sel_spinup_models, sel_spinup_forcing, spinup_pool_name, land_in, tem_helpers)
helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.
"""
"""
    getSpinupInfo(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_in, spinup_pool_name, tem_helpers, tem_spinup)

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `spinup_pool_name`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
"""
function getSpinupInfo(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_in,
    spinup_pool_name,
    tem_helpers,
    tem_spinup)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name))
    spinup_info = setTupleField(spinup_info, (:land_in, land_in))
    spinup_info = setTupleField(spinup_info, (:sel_spinup_forcing, sel_spinup_forcing))
    spinup_info = setTupleField(spinup_info, (:sel_spinup_models, sel_spinup_models))
    spinup_info = setTupleField(spinup_info, (:tem_helpers, tem_helpers))
    spinup_info = setTupleField(spinup_info, (:tem_spinup, tem_spinup))
    spinup_info = setTupleField(spinup_info, (:forcing_one_timestep, forcing_one_timestep))
    return spinup_info
end


"""
    loadSpinup(_, tem_spinup, nothing::Val{true})

DOCSTRING

# Arguments:
- `_`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function loadSpinup(_, tem_spinup, ::Val{true}) # when load_spinup is true
    @info "spinupTEM:: loading spinup data from $(tem_spinup.paths.restart_file_in)..."
    restart_data = load(tem_spinup.paths.restart_file_in)
    land_spin = restart_data["land_spin"]
    return land_spin
end

"""
    loadSpinup(land_spin, _, nothing::Val{false})

DOCSTRING

# Arguments:
- `land_spin`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function loadSpinup(land_spin, _, ::Val{false}) # when load_spinup is false
    return land_spin
end

"""
    runSpinup(_, _, _, land_spin, _, _, _, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `land_spin`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(_, _, _, land_spin, _, _, _, ::Val{:false}) # dont do the spinup
    return land_spin
end

"""
    runSpinup(forward_models, forcing, forcing_one_timestep, land_spin, tem_helpers, tem_models, tem_spinup, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `forward_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_spin`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_models`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(forward_models, forcing, forcing_one_timestep, land_spin, tem_helpers, tem_models, tem_spinup, ::Val{:true}) # do the spinup
    @info "spinupTEM:: running spinup sequences..."
    # spinup_forcing = getSpinupForcing(forcing, forcing_one_timestep, tem_spinup.sequence, tem_helpers)
    seq_index = 1
    log_index = 1
    for spin_seq ∈ tem_spinup.sequence
        forc_name = valToSymbol(spin_seq.forcing)
        n_repeat = spin_seq.n_repeat
        spinup_mode = spin_seq.spinup_mode
        # sel_forcing = spinup_forcing[forc_name]
        sel_forcing = getSpinupForcing(forcing, forcing_one_timestep, spin_seq.aggregator, tem_helpers, spin_seq.aggregator_type)
        spinup_models = forward_models
        if spinup_mode == :spinup
            spinup_models = forward_models[tem_models.is_spinup]
        end
        for loop_index ∈ 1:n_repeat
            @debug "     sequence: $(seq_index), spinup_mode: $(spinup_mode), forcing: $(forc_name), Loop: $(loop_index)/$(n_repeat)"
            land_spin = runSpinup(spinup_models,
                sel_forcing,
                forcing_one_timestep,
                land_spin,
                tem_helpers,
                tem_spinup,
                spinup_mode)
            land_spin = setSpinupLog(land_spin, log_index, tem_helpers.run.spinup.store_spinup)
            log_index += 1
        end
        seq_index += 1
    end
    return land_spin
end



"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:spinup})
do/run the spinup and update the state using a simple timeloop through the input models given in sel_spinup_models. In case of :spinup, only the models chosen as use4spinup in model_structure.json are run.
"""
"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, nothing::Val{:spinup})

DOCSTRING

# Arguments:
- `spinup_models`: DESCRIPTION
- `spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::Val{:spinup})
    land_spin = timeLoopTEMSpinup(spinup_models,
        spinup_forcing,
        forcing_one_timestep,
        land,
        tem_helpers)
    return land_spin
end

"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:forward})
do/run the spinup and update the state using a simple timeloop through the input models given in sel_spinup_models. In case of :forward, all the models chosen in model_structure.json are run.
"""
"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, nothing::Val{:forward})

DOCSTRING

# Arguments:
- `spinup_models`: DESCRIPTION
- `spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::Val{:forward})
    land_spin = timeLoopTEMSpinup(spinup_models,
        spinup_forcing,
        forcing_one_timestep,
        land,
        tem_helpers)
    return land_spin
end


"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, nothing::Val{:nlsove_fixedpoint_trustregion_TWS})

DOCSTRING

# Arguments:
- `spinup_models`: DESCRIPTION
- `spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::Val{:nlsove_fixedpoint_trustregion_TWS})
    TWS_spin = RunSpinup_TWS(spinup_models, spinup_forcing, tem_helpers, land, forcing_one_timestep)
    r = fixedpoint(TWS_spin, Vector(deepcopy(land.pools.TWS)); method=:trust_region)
    TWS = r.zero
    TWS = oftype(land.pools.TWS, TWS)
    @pack_land TWS => land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_helpers, land.wCycleBase.w_model)
    return land
end

"""
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, nothing::Val{:nlsove_fixedpoint_trustregion_cEco_TWS})

DOCSTRING

# Arguments:
- `spinup_models`: DESCRIPTION
- `spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::Val{:nlsove_fixedpoint_trustregion_cEco_TWS})
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
    runSpinup(spinup_models, spinup_forcing, forcing_one_timestep, land, tem_helpers, _, nothing::Val{:nlsove_fixedpoint_trustregion_cEco})

DOCSTRING

# Arguments:
- `spinup_models`: DESCRIPTION
- `spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    spinup_models,
    spinup_forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    _,
    ::Val{:nlsove_fixedpoint_trustregion_cEco})
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
runSpinup(_, _, _, land, helpers, _, ::Val{:ηScaleAH})
scale the carbon pools using the scalars from cCycleBase
"""

"""
    runSpinup(_, _, _, land, helpers, _, nothing::Val{:ηScaleAH})

DOCSTRING

# Arguments:
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `land`: DESCRIPTION
- `helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(_, _, _, land, helpers, _, ::Val{:ηScaleAH})
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
runSpinup(_, _, _, land, helpers, _, ::Val{:ηScaleA0H})
scale the carbon pools using the scalars from cCycleBase
"""
"""
    runSpinup(_, _, _, land, helpers, _, nothing::Val{:ηScaleA0H})

DOCSTRING

# Arguments:
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `land`: DESCRIPTION
- `helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(_, _, _, land, helpers, _, ::Val{:ηScaleA0H})
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
        cLoss = max0(cEco[cVegZix] - c_remain)
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
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:ODE_AutoTsit5_Rodas5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
"""
    runSpinup(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_in, tem_helpers, tem_spinup, nothing::Val{:ODE_AutoTsit5_Rodas5})

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_in,
    tem_helpers,
    tem_spinup,
    ::Val{:ODE_AutoTsit5_Rodas5})
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            sel_spinup_models,
            sel_spinup_forcing,
            forcing_one_timestep,
            land_in,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (tem_helpers.numbers.𝟘, tem_helpers.numbers.sNT(tem_spinup.differential_eqn.time_jump))
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        maxIter = tem_spinup.differential_eqn.time_jump
        # maxIter = max(ceil(tem_spinup.differential_eqn.time_jump) / 100, 100)
        ode_sol = solve(ode_prob, AutoVern7(Rodas5()); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.differential_eqn.relative_tolerance, abstol=tem_spinup.differential_eqn.absolute_tolerance, maxiters=maxIter)
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land_in
end

"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:ODE_DP5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
"""
    runSpinup(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_in, tem_helpers, tem_spinup, nothing::Val{:ODE_DP5})

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_in,
    tem_helpers,
    tem_spinup,
    ::Val{:ODE_DP5})
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            sel_spinup_models,
            sel_spinup_forcing,
            forcing_one_timestep,
            land_in,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (tem_helpers.numbers.𝟘, tem_helpers.numbers.sNT(tem_spinup.differential_eqn.time_jump))
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        maxIter = tem_spinup.differential_eqn.time_jump
        maxIter = max(ceil(tem_spinup.differential_eqn.time_jump) / 100, 100)
        ode_sol = solve(ode_prob, DP5(); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.differential_eqn.relative_tolerance, abstol=tem_spinup.differential_eqn.absolute_tolerance, maxiters=maxIter)
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land_in
end


"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:ODE_Tsit5})
do/run the spinup using ODE solver and Tsit5 method of DifferentialEquations.jl.
"""
"""
    runSpinup(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_in, tem_helpers, tem_spinup, nothing::Val{:ODE_Tsit5})

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_in,
    tem_helpers,
    tem_spinup,
    ::Val{:ODE_Tsit5})
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            sel_spinup_models,
            sel_spinup_forcing,
            forcing_one_timestep,
            land_in,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (tem_helpers.numbers.𝟘, tem_helpers.numbers.sNT(tem_spinup.differential_eqn.time_jump))
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ode_prob = ODEProblem(getDeltaPool, init_pool, tspan, p_info)
        # maxIter = tem_spinup.differential_eqn.time_jump
        maxIter = max(ceil(tem_spinup.differential_eqn.time_jump) / 100, 100)
        ode_sol = solve(ode_prob, Tsit5(); maxiters=maxIter)
        # ode_sol = solve(ode_prob, Tsit5(), reltol=tem_spinup.differential_eqn.relative_tolerance, abstol=tem_spinup.differential_eqn.absolute_tolerance, maxiters=maxIter)
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ode_sol.u[end]))
    end
    return land_in
end


"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:SSP_DynamicSS_Tsit5})
do/run the spinup using SteadyState solver and DynamicSS with Tsit5 method of DifferentialEquations.jl.
"""
"""
    runSpinup(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_in, tem_helpers, tem_spinup, nothing::Val{:SSP_DynamicSS_Tsit5})

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_in,
    tem_helpers,
    tem_spinup,
    ::Val{:SSP_DynamicSS_Tsit5})
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            sel_spinup_models,
            sel_spinup_forcing,
            forcing_one_timestep,
            land_in,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, DynamicSS(Tsit5()))
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ssp_sol.u))
    end
    return land_in
end

"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_in, tem, ::Val{:SSP_DynamicSS_Tsit5})
do/run the spinup using SteadyState solver and SSRootfind method of DifferentialEquations.jl.
"""
"""
    runSpinup(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_in, tem_helpers, tem_spinup, nothing::Val{:SSP_SSRootfind})

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runSpinup(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_in,
    tem_helpers,
    tem_spinup,
    ::Val{:SSP_SSRootfind})
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(
            sel_spinup_models,
            sel_spinup_forcing,
            forcing_one_timestep,
            land_in,
            Symbol(sel_pool),
            tem_helpers,
            tem_spinup)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land_in[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, SSRootfind())
        land_in = setTupleSubfield(land_in, :pools, (p_info.pool, ssp_sol.u))
    end
    return land_in
end

=#



"""
spinupTEM(forward_models, forcing, land_spin, tem)
The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using runSpinup functions for different spinup methods.
"""
"""
    spinupTEM(forward_models, forcing, forcing_one_timestep, land_in, tem_helpers, tem_models, tem_spinup)

DOCSTRING

# Arguments:
- `forward_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_in`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_models`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
"""
function spinupTEM(
    forward_models,
    forcing,
    forcing_one_timestep,
    land_in,
    tem_helpers,
    tem_models,
    tem_spinup)

    #todo probably the load and save spinup have to move outside. As of now, only pixel values are saved as the data reaching here are mapped through mapEco or mapOpt or runTEM!. Need to figure out but not critical as long as the spinup is not the bottleneck...
    land_spin = loadSpinup(land_in, tem_spinup, tem_helpers.run.spinup.load_spinup)

    #check if the spinup still needs to be done after loading spinup
    land_spin = runSpinup(forward_models, forcing, forcing_one_timestep, land_spin, tem_helpers, tem_models, tem_spinup, tem_helpers.run.spinup.run_spinup)

    saveSpinup(land_spin, tem_spinup, tem_helpers.run.spinup.save_spinup)
    return land_spin
end

"""
    saveSpinup(land_spin, tem_spinup, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `land_spin`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function saveSpinup(land_spin, tem_spinup, ::Val{:true}) # save the spinup
    spin_file = tem_spinup.paths.restart_file_out
    @info "spinupTEM:: saving spinup data to $(spin_file)..."
    @save spin_file land_spin
    return nothing
end

"""
    saveSpinup(_, _, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function saveSpinup(_, _, ::Val{:false}) # dont save the spinup
    return nothing
end


"""
    setSpinupLog(land_spin, log_index, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `land_spin`: DESCRIPTION
- `log_index`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function setSpinupLog(land_spin, log_index, ::Val{:true})
    land_spin.states.spinuplog[log_index] = land_spin.pools
    return land_spin
end

"""
    setSpinupLog(land_spin, _, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `land_spin`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function setSpinupLog(land_spin, _, ::Val{:false})
    return land_spin
end


"""
runSpinup(sel_spinup_models, sel_spinup_forcing, land_spin, tem)
do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the land_spin/land is overwritten with every iteration. Only the state at the end is returned.
"""
"""
    timeLoopTEMSpinup(sel_spinup_models, sel_spinup_forcing, forcing_one_timestep, land_spin, tem_helpers)

DOCSTRING

# Arguments:
- `sel_spinup_models`: DESCRIPTION
- `sel_spinup_forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_spin`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
"""
function timeLoopTEMSpinup(
    sel_spinup_models,
    sel_spinup_forcing,
    forcing_one_timestep,
    land_spin,
    tem_helpers)
    num_timesteps = getForcingTimeSize(sel_spinup_forcing, tem_helpers.vals.forc_vars)
    for ts ∈ 1:num_timesteps
        f_ts = getForcingForTimeStep(sel_spinup_forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land_spin = computeTEM(sel_spinup_models, f_ts, land_spin, tem_helpers)
    end
    return land_spin
end