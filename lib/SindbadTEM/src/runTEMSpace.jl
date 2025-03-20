export coreTEM!
export runTEM!

"""
    coreTEM!(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, loc_land, tem_info, spinup_mode)

Executes the core SINDBAD Terrestrial Ecosystem Model (TEM) for a single location, including precomputations, spinup, and the main time loop.


# Arguments:
- `selected_models`: A tuple of all models selected in the given model structure.
- `loc_forcing`: A forcing NamedTuple containing the time series of environmental drivers for a single location.
- `loc_spinup_forcing`: A forcing NamedTuple for spinup, used to initialize the model to a steady state (only used if spinup is enabled).
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
- `loc_output`: An output array or view for storing the model outputs for a single location.
- `loc_land`: Initial SINDBAD land NamedTuple with all fields and subfields.
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
- `spinup_mode`: A type dispatch that determines whether spinup is included or excluded:

# Details
Executes the main TEM simulation logic with the provided parameters and data. Handles both
regular simulation and spinup modes based on the spinup_mode flag.

# Extended help:
- **Precomputations**:
    - The function runs `precomputeTEM` to prepare the land state for the simulation.
"""
function coreTEM!(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, loc_land, tem_info, spinup_mode)
    # update the loc_forcing with the actual location
    loc_forcing_t = getForcingForTimeStep(loc_forcing, loc_forcing_t, 1, tem_info.vals.forcing_types)
    # run precompute
    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers) 
    # run spinup
    land_spin = spinupTEM(selected_models, loc_spinup_forcing, loc_forcing_t, land_prec, tem_info, spinup_mode)

    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land_spin, tem_info.vals.forcing_types, tem_info.model_helpers, tem_info.vals.output_vars, tem_info.n_timesteps, tem_info.run.debug_model)
    return nothing
end

"""
    parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, parallelization_mode::SindbadParallelizationMethod)

Parallelizes the SINDBAD Terrestrial Ecosystem Model (TEM) across multiple locations using the specified parallelization backend.

# Arguments:
- `selected_models`: A tuple of all models selected in the given model structure.
- `space_forcing`: A collection of forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
- `space_spinup_forcing`: A collection of spinup forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
- `space_output`: A collection of output arrays/views for multiple locations, replicated to avoid data races during parallel execution.
- `space_land`: A collection of initial SINDBAD land NamedTuples for multiple locations, ensuring that the model states for one location do not overwrite those of another.
- `tem_info`: A helper NamedTuple containing necessary objects for model execution and type consistencies.
- `parallelization_mode`: A type dispatch that determines the parallelization backend to use:
    - `UseThreadsParallelization`: Uses Julia's `Threads.@threads` for parallel execution.
    - `UseQbmapParallelization`: Uses `qbmap` for parallel execution.

# Returns:
- `nothing`: The function modifies `space_output` and `space_land` in place to store the results for each location.

# Notes:
- **Thread-based Parallelization**:
    - When `UseThreadsParallelization` is used, the function distributes the locations across threads using `Threads.@threads`.
- **Qbmap-based Parallelization**:
    - When `UseQbmapParallelization` is used, the function distributes the locations using the `qbmap` backend.
- **Core Execution**:
    - For each location, the function calls `coreTEM!` to execute the TEM simulation, including spinup (if enabled) and the main time loop.
- **Data Safety**:
    - The function ensures data safety by replicating forcing, output, and land data for each location, avoiding data races during parallel execution.

# Examples:
1. **Parallelizing TEM using threads**:
    ```julia
    parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, UseThreadsParallelization())
    ```

2. **Parallelizing TEM using qbmap**:
    ```julia
    parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, UseQbmapParallelization())
    ```
"""
parallelizeTEM!

function parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, ::UseThreadsParallelization)
    Threads.@threads for space_index ∈ eachindex(space_forcing)
        coreTEM!(selected_models, space_forcing[space_index], space_spinup_forcing[space_index], loc_forcing_t, space_output[space_index], space_land[space_index], tem_info, tem_info.run.spinup_TEM)
    end
    return nothing
end

function parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, ::UseQbmapParallelization)
    space_index = 1
    qbmap(space_forcing) do _
        coreTEM!(selected_models, space_forcing[space_index], space_spinup_forcing[space_index], loc_forcing_t, space_output[space_index], space_land[space_index], tem_info, tem_info.run.spinup_TEM)
        space_index += 1
    end
    return nothing
end

"""
    runTEM!(selected_models, forcing::NamedTuple, info::NamedTuple)
    runTEM!(forcing::NamedTuple, info::NamedTuple)
    runTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info::NamedTuple)

Runs the SINDBAD Terrestrial Ecosystem Model (TEM) for all locations and time steps using preallocated arrays as the model data backend. This function supports multiple configurations for efficient execution.

# Arguments:
1. **For the first variant**:
    - `selected_models`: A tuple of all models selected in the given model structure.
    - `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
    - `info::NamedTuple`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.

2. **For the second variant**:
    - `forcing::NamedTuple`: A forcing NamedTuple containing the time series of environmental drivers for all locations.
    - `info::NamedTuple`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.

3. **For the third variant**:
    - `selected_models`: A tuple of all models selected in the given model structure.
    - `space_forcing`: A collection of forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
    - `space_spinup_forcing`: A collection of spinup forcing NamedTuples for multiple locations, replicated to avoid data races during parallel execution.
    - `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
    - `space_output`: A collection of output arrays/views for multiple locations, replicated to avoid data races during parallel execution.
    - `space_land`: A collection of initial SINDBAD land NamedTuples for multiple locations, ensuring that the model states for one location do not overwrite those of another.
    - `tem_info::NamedTuple`: A helper NamedTuple containing necessary objects for model execution and type consistencies.

# Returns:
- `output_array`: A preallocated array containing the simulation results for all locations and time steps.

# Notes:
- **Precomputations**:
    - The function uses `prepTEM` to prepare the necessary inputs and configurations for the simulation.
- **Parallel Execution**:
    - The function uses `parallelizeTEM!` to distribute the simulation across multiple locations using the specified parallelization backend (`Threads.@threads` or `qbmap`).
- **Core Execution**:
    - For each location, the function calls `coreTEM!` to execute the TEM simulation, including spinup (if enabled) and the main time loop.
- **Data Safety**:
    - The function ensures data safety by replicating forcing, output, and land data for each location, avoiding data races during parallel execution.

# Examples:
1. **Running TEM with preallocated arrays**:
    ```julia
    output_array = runTEM!(selected_models, forcing, info)
    ```

2. **Running TEM with parallelization**:
    ```julia
    output_array = runTEM!(forcing, info)
    ```

3. **Running TEM with precomputed helpers**:
    ```julia
    runTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info)
    ```
"""
runTEM!

function runTEM!(selected_models, forcing::NamedTuple, info::NamedTuple)
    run_helpers = prepTEM(selected_models, forcing, info)
    runTEM!(selected_models, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    return run_helpers.output_array
end

function runTEM!(forcing::NamedTuple, info::NamedTuple)
    run_helpers = prepTEM(forcing, info)
    runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    return run_helpers.output_array
end

function runTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info::NamedTuple)
    parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, tem_info.run.parallelization)
    return nothing
end

"""
    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, debug_mode)

Executes the time loop for the SINDBAD Terrestrial Ecosystem Model (TEM), running the model for each time step and storing the outputs in preallocated arrays.

# Arguments:
- `selected_models`: A tuple of all models selected in the given model structure.
- `loc_forcing`: A forcing NamedTuple containing the time series of environmental drivers for a single location.
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
- `loc_output`: A preallocated output array or view for storing the model outputs for a single location.
- `land`: A SINDBAD NamedTuple containing all variables for a given time step, which is overwritten at every time step.
- `forcing_types`: A NamedTuple specifying the types of forcing variables (e.g., time-dependent or constant).
- `model_helpers`: A NamedTuple containing helper functions and configurations for model execution.
- `output_vars`: A list of output variables to be stored for each time step.
- `n_timesteps`: The total number of time steps to run the simulation.
- `debug_mode`: A type dispatch that determines whether debugging is enabled or disabled:
    - `DoDebugModel`: Runs the model for a single time step and logs debugging information (e.g., allocations, execution time). Set`debug_model` to `true` in flag section of experiment_json.
    - `DoNotDebugModel`: Runs the model for all time steps without debugging. Set`debug_model` to `false` in flag section of experiment_json.

# Returns:
- `nothing`: The function modifies `loc_output` in place to store the results for each time step.

# Notes:
- **Forcing Retrieval**:
    - For each time step, the function retrieves the forcing data using `getForcingForTimeStep`.
- **Model Execution**:
    - The model is executed using `computeTEM`, which updates the land state.
- **Output Storage**:
    - The updated land state is stored in the preallocated `loc_output` array using `setOutputForTimeStep!`.
- **Debugging**:
    - When `DoDebugModel` is used, the function logs detailed debugging information for a single time step, including execution time and memory allocations.

# Examples:
1. **Running the time loop without debugging**:
    ```julia
    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, DoNotDebugModel())
    ```

2. **Running the time loop with debugging**:
    ```julia
    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, DoDebugModel())
    ```
"""
timeLoopTEM!

function timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, ::DoNotDebugModel) # do not debug the models
    # n_timesteps=1
    for ts ∈ 1:n_timesteps
        f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, ts, forcing_types)
        land = computeTEM(selected_models, f_ts, land, model_helpers)
        setOutputForTimeStep!(loc_output, land, ts, output_vars)
    end
end


function timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, _, ::DoDebugModel) # debug the models
    @info "\nforc\n"
    @time f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, 1, forcing_types)
    @info "\n-------------\n"
    @info "\neach model\n"
    @time land = computeTEM(selected_models, f_ts, land, model_helpers, DoDebugModel())
    @info "\n-------------\n"
    @info "\nall models\n"
    @time land = computeTEM(selected_models, f_ts, land, model_helpers)
    @info "\n-------------\n"
    @info "\nset output\n"
    @time setOutputForTimeStep!(loc_output, land, 1, output_vars)
    @info "\n-------------\n"
    return nothing
end

