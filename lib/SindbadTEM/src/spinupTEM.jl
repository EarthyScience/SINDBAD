export getDeltaPool
export getSpinupInfo
export spinup
export spinupTEM
export timeLoopTEMSpinup

struct Spinup_TWS{M,F,T,I,O,N}
    models::M
    forcing::F
    tem_info::T
    land::I
    loc_forcing_t::O
    n_timesteps::N
end

struct Spinup_cEco_TWS{M,F,T,I,O,N,TWS}
    models::M
    forcing::F
    tem_info::T
    land::I
    loc_forcing_t::O
    n_timesteps::N
    TWS::TWS
end


struct Spinup_cEco{M,F,T,I,O,N}
    models::M
    forcing::F
    tem_info::T
    land::I
    loc_forcing_t::O
    n_timesteps::N
end



"""
    (cEco_spin::Spinup_cEco)(pout, p)

Custom callable type function for spinning up cEco.

# Arguments
- `pout`: Output pools
- `p`: Input pools

# Note
This method allows a `Spinup_cEco` object to be called as a function, implementing the specific spinup logic for ecosystem carbon pools.
"""
function (cEco_spin::Spinup_cEco)(pout, p)
    land = cEco_spin.land
    helpers = cEco_spin.tem_info.model_helpers
    n_timesteps = cEco_spin.n_timesteps
    zix = helpers.pools.zix

    pout .= exp.(p)

    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] ⇒ (cEco, lc, :cEco)
    end
    @pack_nt cEco ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.models.c_model)
    update_init = timeLoopTEMSpinup(cEco_spin.models, cEco_spin.forcing, cEco_spin.loc_forcing_t, land, cEco_spin.tem_info, n_timesteps)

    pout .= log.(update_init.pools.cEco)
    return nothing
end

"""
    (cEco_TWS_spin::Spinup_cEco_TWS)(pout, p)

Custom callable type function for spinning up cEco and TWS pools.

# Arguments
- `pout`: Output pools
- `p`: Input pools

# Note
This method allows a `Spinup_cEco_TWS` object to be called as a function, implementing the specific spinup logic for ecosystem carbon pools and the terrestrial water storage components.
"""
function (cEco_TWS_spin::Spinup_cEco_TWS)(pout, p)
    land = cEco_TWS_spin.land
    helpers = cEco_TWS_spin.tem_info.model_helpers
    n_timesteps = cEco_TWS_spin.n_timesteps
    zix = helpers.pools.zix

    pout .= exp.(p)

    cEco = land.pools.cEco
    for (lc, l) in enumerate(zix.cEco)
        @rep_elem pout[l] ⇒ (cEco, lc, :cEco)
    end
    @pack_nt cEco ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.models.c_model)

    TWS = land.pools.TWS
    TWS_prev = cEco_TWS_spin.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem TWS_prev[l] ⇒ (TWS, lc, :TWS)
    end

    @pack_nt TWS ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.models.w_model)

    update_init = timeLoopTEMSpinup(cEco_TWS_spin.models, cEco_TWS_spin.forcing, cEco_TWS_spin.loc_forcing_t, land, cEco_TWS_spin.tem_info, n_timesteps)

    pout .= log.(update_init.pools.cEco)
    cEco_TWS_spin.TWS .= update_init.pools.TWS
    return nothing
end


"""
    (TWS_spin::Spinup_TWS)(pout, p)

Custom callable type function for spinning up TWS pools.

# Arguments
- `pout`: Output pools
- `p`: Input pools

# Note
This method allows a `Spinup_TWS` object to be called as a function, implementing the specific spinup logic for the terrestrial water storage components.
"""
function (TWS_spin::Spinup_TWS)(pout, p)
    land = TWS_spin.land
    helpers = TWS_spin.tem_info.model_helpers
    n_timesteps = TWS_spin.n_timesteps
    zix = helpers.pools.zix

    TWS = land.pools.TWS
    for (lc, l) in enumerate(zix.TWS)
        @rep_elem maxZero(p[l]) ⇒ (TWS, lc, :TWS)
    end
    @pack_nt TWS ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.models.w_model)
    update_init = timeLoopTEMSpinup(TWS_spin.models, TWS_spin.forcing, TWS_spin.loc_forcing_t, land, TWS_spin.tem_info, n_timesteps)
    pout .= update_init.pools.TWS
    return nothing
end


"""
    getDeltaPool(pool_dat::AbstractArray, spinup_info, t)

helper function to run the spinup models and return the delta in a given pool over the simulation. Used in solvers from DifferentialEquations.jl.


# Arguments:
- `pool_dat`: new values of the storage pools
- `spinup_info`: NT with all the necessary information to run the spinup models
"""
function getDeltaPool(pool_dat::AbstractArray, spinup_info, _)
    land = spinup_info.land
    tem_info = spinup_info.tem_info
    spinup_models = spinup_info.spinup_models
    spinup_forcing = spinup_info.spinup_forcing
    loc_forcing_t = spinup_info.loc_forcing_t
    n_timesteps = spinup_info.n_timesteps
    land = setTupleSubfield(land, :pools, (spinup_info.pool, pool_dat))

    land = timeLoopTEMSpinup(spinup_models, spinup_forcing, loc_forcing_t, deepcopy(land), tem_info, n_timesteps)
    tmp = getfield(land.pools, spinup_info.pool)
    Δpool = tmp - pool_dat
    return Δpool
end

"""
    getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, spinup_pool_name, tem_info, tem_spinup)

helper function to create a NamedTuple with all the variables needed to run the spinup models in getDeltaPool. Used in solvers from DifferentialEquations.jl.


# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `spinup_pool_name`: name of the land.pool storage component intended for spinup
- `tem_info`: helper NT with necessary objects for model run and type consistencies
"""
function getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, spinup_pool_name, tem_info, n_timesteps)
    spinup_info = (;)
    spinup_info = setTupleField(spinup_info, (:pool, spinup_pool_name))
    spinup_info = setTupleField(spinup_info, (:land, land))
    spinup_info = setTupleField(spinup_info, (:spinup_forcing, spinup_forcing))
    spinup_info = setTupleField(spinup_info, (:spinup_models, spinup_models))
    spinup_info = setTupleField(spinup_info, (:tem_info, tem_info))
    spinup_info = setTupleField(spinup_info, (:loc_forcing_t, loc_forcing_t))
    spinup_info = setTupleField(spinup_info, (:n_timesteps, n_timesteps))
    return spinup_info
end


"""
    spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, spinup_mode::SindbadSpinupMethod)

Runs the spinup process for the SINDBAD Terrestrial Ecosystem Model (TEM) to initialize the model to a steady state. The spinup process updates the state variables (e.g., pools) using various spinup methods.

# Arguments:
- `spinup_models`: A tuple of a subset of all models in the given model structure that are selected for spinup.
- `spinup_forcing`: A forcing NamedTuple containing the time series of environmental drivers for the spinup process.
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every timestep.
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
- `n_timesteps`: The number of timesteps for the spinup process.
- `spinup_mode::SindbadSpinupMethod`: A type dispatch that determines the spinup method to be used. Supported modes include:
    - `SelSpinupModels`: Runs only the models selected for spinup in the model structure. This excludes models that are not used in the spinup process by setting use_in_spinup as `false` in model_structure.json.
    - `AllForwardModels`: Runs all models in the forward mode.
    - `NlsolveFixedpointTrustregionTWS`: Uses a fixed-point solver with trust region for Total Water Storage (TWS).
    - `NlsolveFixedpointTrustregionCEco`: Uses a fixed-point solver with trust region for carbon pools (cEco).
    - `NlsolveFixedpointTrustregionCEcoTWS`: Uses a fixed-point solver with trust region for both cEco and TWS.
    - `ODETsit5`: Uses the Tsit5 method from DifferentialEquations.jl for solving ODEs.
    - `ODEDP5`: Uses the DP5 method from DifferentialEquations.jl for solving ODEs.
    - `ODEAutoTsit5Rodas5`: Uses the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs.
    - `SSPDynamicSSTsit5`: Uses the SteadyState solver with DynamicSS and Tsit5 methods.
    - `SSPSSRootfind`: Uses the SteadyState solver with SSRootfind method.
    - `EtaScaleAH`: Scales carbon pools using diagnostic scalars for ηH and ηA.
    - `EtaScaleA0H`: Scales carbon pools using diagnostic scalars for ηH and c_remain.

# Returns:
- `land`: The updated SINDBAD NamedTuple containing the final state of the model after the spinup process.

# Notes:
- The spinup process can use different methods depending on the `spinup_mode`, including fixed-point solvers, ODE solvers, and steady-state solvers.
- The function dynamically selects the appropriate spinup method based on the `spinup_mode` dispatch type.
- For ODE-based methods, the function uses DifferentialEquations.jl to solve the spinup equations.
- For steady-state solvers, the function uses methods like `DynamicSS` or `SSRootfind` to find equilibrium states.

# Examples:
1. **Running spinup with selected models**:
    ```julia
    land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, SelSpinupModels())
    ```

2. **Running spinup with ODE solver (Tsit5)**:
    ```julia
    land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ODETsit5())
    ```

3. **Running spinup with fixed-point solver for cEco and TWS**:
    ```julia
    land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, NlsolveFixedpointTrustregionCEcoTWS())
    ```

4. **Running spinup with steady-state solver (SSRootfind)**:
    ```julia
    land = spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, SSPSSRootfind())
    ```
"""
spinup

function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::SelSpinupModels)
    land = timeLoopTEMSpinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps)
    return land
end

function spinup(all_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::AllForwardModels)
    land = timeLoopTEMSpinup(all_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps)
    return land
end

function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::NlsolveFixedpointTrustregionTWS)
    TWS_spin = Spinup_TWS(spinup_models, spinup_forcing, tem_info, land, loc_forcing_t, n_timesteps)
    r = fixedpoint(TWS_spin, Vector(deepcopy(land.pools.TWS)); method=:trust_region)
    TWS = r.zero
    TWS = oftype(land.pools.TWS, TWS)
    @pack_nt TWS ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_info.model_helpers, land.models.w_model)
    return land
end

function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::NlsolveFixedpointTrustregionCEcoTWS)
    cEco_TWS_spin = Spinup_cEco_TWS(spinup_models, spinup_forcing, tem_info, deepcopy(land), loc_forcing_t, n_timesteps, Vector(deepcopy(land.pools.TWS)))
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
    @pack_nt cEco ⇒ land.pools
    TWS_prev = cEco_TWS_spin.TWS
    TWS = oftype(land.pools.TWS, TWS_prev)
    @pack_nt TWS ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_info.model_helpers, land.models.c_model)
    land = Sindbad.adjustPackPoolComponents(land, tem_info.model_helpers, land.models.w_model)
    return land
end


function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::NlsolveFixedpointTrustregionCEco)
    cEco_spin = Spinup_cEco(spinup_models, spinup_forcing, tem_info, deepcopy(land), loc_forcing_t, n_timesteps)
    p_init = log.(Vector(deepcopy(land.pools.cEco)))
    r = fixedpoint(cEco_spin, p_init; method=:trust_region)
    cEco = exp.(r.zero)
    cEco = oftype(land.pools.cEco, cEco)
    @pack_nt cEco ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, tem_info.model_helpers, land.models.c_model)
    return land
end

function spinup(_, _, _, land, helpers, _, ::EtaScaleAH)
    @unpack_nt cEco ⇐ land.pools
    helpers = helpers.model_helpers
    cEco_prev = copy(cEco)
    ηH = one(eltype(cEco))
    if :ηH ∈ propertynames(land.diagnostics)
        ηH = land.diagnostics.ηH
    end
    ηA = one(eltype(cEco))
    if :ηA ∈ propertynames(land.diagnostics)
        ηA = land.diagnostics.ηA
    end
    for cSoilZix ∈ helpers.pools.zix.cSoil
        cSoilNew = cEco[cSoilZix] * ηH
        @rep_elem cSoilNew ⇒ (cEco, cSoilZix, :cEco)
    end
    for cLitZix ∈ helpers.pools.zix.cLit
        cLitNew = cEco[cLitZix] * ηH
        @rep_elem cLitNew ⇒ (cEco, cLitZix, :cEco)
    end
    for cVegZix ∈ helpers.pools.zix.cVeg
        cVegNew = cEco[cVegZix] * ηA
        @rep_elem cVegNew ⇒ (cEco, cVegZix, :cEco)
    end
    @pack_nt cEco ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.models.c_model)
    @pack_nt cEco_prev ⇒ land.states
    return land
end


function spinup(_, _, _, land, helpers, _, ::EtaScaleA0H)
    @unpack_nt cEco ⇐ land.pools
    helpers = helpers.model_helpers
    cEco_prev = copy(cEco)
    ηH = one(eltype(cEco))
    c_remain = one(eltype(cEco))
    if :ηH ∈ propertynames(land.diagnostics)
        ηH = land.diagnostics.ηH
        c_remain = land.states.c_remain
    end
    for cSoilZix ∈ helpers.pools.zix.cSoil
        cSoilNew = cEco[cSoilZix] * ηH
        @rep_elem cSoilNew ⇒ (cEco, cSoilZix, :cEco)
    end

    for cLitZix ∈ helpers.pools.zix.cLit
        cLitNew = cEco[cLitZix] * ηH
        @rep_elem cLitNew ⇒ (cEco, cLitZix, :cEco)
    end

    for cVegZix ∈ helpers.pools.zix.cVeg
        cLoss = maxZero(cEco[cVegZix] - c_remain)
        cVegNew = cEco[cVegZix] - cLoss
        @rep_elem cVegNew ⇒ (cEco, cVegZix, :cEco)
    end

    @pack_nt cEco ⇒ land.pools
    land = Sindbad.adjustPackPoolComponents(land, helpers, land.models.c_model)
    @pack_nt cEco_prev ⇒ land.states
    return land
end


function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::ODEAutoTsit5Rodas5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, Symbol(sel_pool), tem_info, n_timesteps)
        tspan = (0.0, tem_info.numbers.num_type(tem_spinup.differential_eqn.time_jump))
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

function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::ODEDP5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, Symbol(sel_pool), tem_info, n_timesteps)
        tspan = (0.0, tem_info.numbers.num_type(tem_spinup.differential_eqn.time_jump))
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


function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::ODETsit5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, Symbol(sel_pool), tem_info, n_timesteps)
        tspan = (0.0, tem_info.numbers.num_type(tem_spinup.differential_eqn.time_jump))
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


function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::SSPDynamicSSTsit5)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, Symbol(sel_pool), tem_info, n_timesteps)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, DynamicSS(Tsit5()))
        land = setTupleSubfield(land, :pools, (p_info.pool, ssp_sol.u))
    end
    return land
end


function spinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps, ::SSPSSRootfind)
    for sel_pool ∈ tem_spinup.differential_eqn.pools
        p_info = getSpinupInfo(spinup_models, spinup_forcing, loc_forcing_t, land, Symbol(sel_pool), tem_info, n_timesteps)
        tspan = (0.0, tem_spinup.differential_eqn.time_jump)
        init_pool = deepcopy(getfield(p_info.land[:pools], p_info.pool))
        ssp_prob = SteadyStateProblem(getDeltaPool, init_pool, p_info)
        ssp_sol = solve(ssp_prob, SSRootfind())
        land = setTupleSubfield(land, :pools, (p_info.pool, ssp_sol.u))
    end
    return land
end

"""
    sequenceForcing(spinup_forcings::NamedTuple, forc_name::Symbol)

Processes and sequences forcing data for spinup simulations.

# Arguments
- `spinup_forcings::NamedTuple`: A named tuple containing the forcing data for different spinup sequence
- `forc_name::Symbol`: Symbol indicating the name of the forcing data set to be extracted from the NT for the given sequence
"""
function sequenceForcing(spinup_forcings::NamedTuple, forc_name::Symbol)
    return spinup_forcings[forc_name]::NamedTuple
end

"""
    setSpinupLog(land, log_index, spinup_log_mode)

Stores or skips the spinup log during the spinup process, depending on the specified `spinup_log_mode`.

# Arguments:
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every timestep.
- `log_index`: The index in the spinup log where the current state of `land.pools` will be stored.
- `spinup_log_mode`: A type dispatch that determines whether to store the spinup log:
    - `DoStoreSpinup`: Enables storing the spinup log at the specified `log_index`. Set the `store_spinup` flag to `true` in flag section of experiment_json.
    - `DoNotStoreSpinup`: Skips storing the spinup log. Set the `store_spinup` flag to `false` in flag section of experiment_json.

# Returns:
- `land`: The updated SINDBAD NamedTuple, potentially with the spinup log stored.

# Notes:
- When `DoStoreSpinup` is used:
    - The function stores the current state of `land.pools` in `land.states.spinuplog` at the specified `log_index`.
- When `DoNotStoreSpinup` is used:
    - The function does nothing and simply returns the input `land`.

# Examples:
1. **Storing the spinup log**:
    ```julia
    land = (pools = ..., states = (spinuplog = Vector{Any}(undef, 10)))
    log_index = 1
    land = setSpinupLog(land, log_index, DoStoreSpinup())
    ```

2. **Skipping the spinup log**:
    ```julia
    land = (pools = ..., states = (spinuplog = Vector{Any}(undef, 10)))
    log_index = 1
    land = setSpinupLog(land, log_index, DoNotStoreSpinup())
    ```
"""
setSpinupLog

function setSpinupLog(land, log_index, ::DoStoreSpinup)
    land.states.spinuplog[log_index] = land.pools
    return land
end

function setSpinupLog(land, _, ::DoNotStoreSpinup)
    return land
end

"""
    spinupSequence(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_index, n_repeat, spinup_mode)

Executes a sequence of model spinup iterations for the Terrestrial Ecosystem Model (TEM).

# Arguments
- `spinup_models`: Collection of model configurations for spinup
- `sel_forcing`: Selected forcing data
- `loc_forcing_t`: Localized forcing data with temporal component
- `land`: Land surface parameters
- `tem_info`: TEM model information and parameters
- `n_timesteps`: Number of timesteps for the spinup
- `log_index`: Index for logging purposes
- `n_repeat`: Number of times to repeat the spinup sequence
- `spinup_mode`: Mode of spinup operation (e.g., "normal", "accelerated")

# Description
Performs model spinup by running multiple iterations of the TEM model to achieve
steady state conditions. The function handles different spinup modes and manages
the sequence of model runs according to specified parameters.

# Returns
land with the updated pools after the spinup sequence.
"""
function spinupSequence(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_index, n_repeat, spinup_mode)
    land = spinupSequenceLoop(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_index, n_repeat, spinup_mode)
    # end
    return land
end


"""
    spinupSequenceLoop(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_loop, n_repeat, spinup_mode)

Runs sequential loops for model spin-up simulations for each repeat of a spinup sequence.

# Arguments
- `spinup_models`: Collection of spin-up model instances
- `sel_forcing`: Selected forcing data
- `loc_forcing_t`: Localized forcing data in temporal dimension
- `land`: Land surface parameters/conditions
- `tem_info`: Model configuration and parameters for TEM
- `n_timesteps`: Number of timesteps to simulate
- `log_loop`: Boolean flag for logging loop information
- `n_repeat`: Number of times to repeat the spin-up loop
- `spinup_mode`: Mode of spin-up simulation (e.g., "normal", "accelerated")
"""
function spinupSequenceLoop(spinup_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_loop, n_repeat, spinup_mode)
    for loop_index ∈ 1:n_repeat
        @debug "        Loop: $(loop_index)/$(n_repeat)"
        land = spinup(spinup_models,
            sel_forcing,
            loc_forcing_t,
            land,
            tem_info,
            n_timesteps,
            spinup_mode)
        # land = setSpinupLog(land, log_loop, tem_info.run.store_spinup)
        log_loop += 1
    end
    return land
end


"""
    spinupTEM(selected_models, forcing, loc_forcing_t, land, tem_info, spinup_mode)

The main spinup function that handles the spinup method based on inputs from spinup.json. Either the spinup is loaded or/and run using spinup functions for different spinup methods.

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `spinup_mode`: A type dispatch that determines whether spinup is included or excluded:
    - `::DoSpinupTEM`: Runs the spinup process before the main simulation. Set `spinup_TEM` to `true` in the flag section of experiment_json.
    - `::DoNotSpinupTEM`: Skips the spinup process and directly runs the main simulation. Set `spinup_TEM` to `false` in the flag section of experiment_json.

# Notes:
- When `DoSpinupTEM` is used:
    - The function runs the spinup sequences
- When `DoNotSpinupTEM` is used:
    - The function skips the spinup process returns the land as is`
"""
spinupTEM

function spinupTEM(selected_models, spinup_forcings, loc_forcing_t, land, tem_info, ::DoSpinupTEM)
    log_index = 1
    for spin_seq ∈ tem_info.spinup_sequence
        forc_name = spin_seq.forcing
        n_timesteps = spin_seq.n_timesteps
        n_repeat = spin_seq.n_repeat
        spinup_mode = spin_seq.spinup_mode
        @debug "Spinup: \n         spinup_mode: $(nameof(typeof(spinup_mode))), forcing: $(forc_name)"
        sel_forcing = sequenceForcing(spinup_forcings, forc_name)
        land = spinupSequence(selected_models, sel_forcing, loc_forcing_t, land, tem_info, n_timesteps, log_index, n_repeat, spinup_mode)
        log_index += n_repeat
    end
    return land
end

function spinupTEM(selected_models, spinup_forcings, loc_forcing_t, land, tem_info, ::DoNotSpinupTEM)
    return land
end


"""
    timeLoopTEMSpinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps)

do/run the time loop of the spinup models to update the pool. Note that, in this function, the time series is not stored and the land/land is overwritten with every iteration. Only the state at the end is returned

# Arguments:
- `spinup_models`: a tuple of a subset of all models in the given model structure that is selected for spinup
- `spinup_forcing`: a selected/sliced/computed forcing time series for running the spinup sequence for a location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land`: SINDBAD NT input to the spinup of TEM during which subfield(s) of pools are overwritten
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `n_timesteps`: number of time steps
"""
function timeLoopTEMSpinup(spinup_models, spinup_forcing, loc_forcing_t, land, tem_info, n_timesteps)
    for ts ∈ 1:n_timesteps
        f_ts = getForcingForTimeStep(spinup_forcing, loc_forcing_t, ts, tem_info.vals.forcing_types)
        land = computeTEM(spinup_models, f_ts, land, tem_info.model_helpers)
    end
    return land
end