export coreTEM!
export runTEM!

"""
    coreTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, loc_land, tem_info, _, _, ::DoNotSpinupTEM)

core SINDBAD function that includes the precompute, spinup, and time loop of the model run


# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `_`: unused argument
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `::DoNotSpinupTEM`: a type dispatch to indicate that spinup is excluded
"""
function coreTEM!(selected_models, loc_forcing, _, loc_forcing_t, loc_output, loc_land, tem_info,::DoNotSpinupTEM) # without spinup
    # update the loc_forcing with the actual location
    loc_forcing_t = getForcingForTimeStep(loc_forcing, loc_forcing_t, 1, tem_info.vals.forcing_types)
    # run precompute
    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers)

    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land_prec, tem_info.vals.forcing_types, tem_info.model_helpers, tem_info.vals.output_vars, tem_info.n_timesteps, tem_info.run.debug_model)
    return nothing
end


"""
    coreTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, loc_land, tem_info, tem_spinup, ::DoSpinupTEM)

core SINDBAD function that includes the precompute, spinup, and time loop of the model run

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::DoSpinupTEM`: a type dispatch to indicate that spinup is included
"""
function coreTEM!(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, loc_land, tem_info, ::DoSpinupTEM)
    # update the loc_forcing with the actual location
    loc_forcing_t = getForcingForTimeStep(loc_forcing, loc_forcing_t, 1, tem_info.vals.forcing_types)
    # run precompute
    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers) 
    # run spinup
    land_spin = spinupTEM(selected_models, loc_spinup_forcing, loc_forcing_t, land_prec, tem_info)

    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land_spin, tem_info.vals.forcing_types, tem_info.model_helpers, tem_info.vals.output_vars, tem_info.n_timesteps, tem_info.run.debug_model)
    return nothing
end


"""
    parallelizeTEM!(selected_models, space_forcing, loc_forcing_t, space_output, space_land, tem_info, tem_spinup, ::UseThreadsParallelization)

parallelize SINDBAD TEM using threads as backend

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `space_forcing`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `space_output`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `space_land`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::UseThreadsParallelization`: type defining dispatch for threads based parallelization
"""
function parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, ::UseThreadsParallelization)
    Threads.@threads for space_index ∈ eachindex(space_forcing)
        coreTEM!(selected_models, space_forcing[space_index], space_spinup_forcing[space_index], loc_forcing_t, space_output[space_index], space_land[space_index], tem_info, tem_info.run.spinup_TEM)
    end
    return nothing
end

"""
    parallelizeTEM!(selected_models, space_forcing, loc_forcing_t, space_output, space_land, tem_info, tem_spinup, ::UseQbmapParallelization)

parallelize SINDBAD TEM using qbmap as backend

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `space_forcing`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `space_output`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `space_land`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::UseQbmapParallelization`: type defining dispatch for qbmap based parallelization
"""
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

a function to run SINDBAD Terrestrial Ecosystem Model that simulates all locations and time using preallocated array as model data backend, with with only info and forcing as input, and model simulation output as arrays 

# Arguments:
- `forcing`: a tuple of models selected for the given model structure
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment    
"""
function runTEM!(selected_models, forcing::NamedTuple, info::NamedTuple)
    run_helpers = prepTEM(selected_models, forcing, info)
    runTEM!(selected_models, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    return run_helpers.output_array
end

"""
    runTEM!(forcing::NamedTuple, info::NamedTuple)

a function to run SINDBAD Terrestrial Ecosystem Model that simulates all locations and time using preallocated array as model data backend, with with only info and forcing as input, and model simulation output as arrays 

# Arguments:
- `forcing`: a tuple of models selected for the given model structure
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment    
"""
function runTEM!(forcing::NamedTuple, info::NamedTuple)
    run_helpers = prepTEM(forcing, info)
    runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    return run_helpers.output_array
end

"""
    runTEM!(selected_models, forcing_nt_array::NamedTuple, space_forcing, loc_forcing_t, space_output, space_land, tem_info::NamedTuple)

a function to run SINDBAD Terrestrial Ecosystem Model that simulates all locations and time using preallocated array as model data backend, with precomputed helper objects for efficient runs during optimization

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `space_forcing`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `space_output`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `space_land`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `tem_info`: a prepTEM revised info.tem where types are defined and added to the fields for dispatch based on types
"""
function runTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info::NamedTuple)
    parallelizeTEM!(selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info, tem_info.run.parallelization)
    return nothing
end


"""
    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, tem_info, ::DoNotDebugModel)

time loop of the model run where forcing for the time step is used to run model compute function, whose output are assigned to preallocated output array

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: a type dispatching for the models should NOT be debugged and run for only ALL time steps
"""
function timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, n_timesteps, ::DoNotDebugModel) # do not debug the models
    # n_timesteps=1
    for ts ∈ 1:n_timesteps
        land = timeStepTEM(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, ts)#::typeof(land)
    end
end


"""
    timeLoopTEM!(selected_models, loc_forcing, loc_forcing_t, loc_output, land, tem_info, DoDebugModel)

time loop of the model run where forcing for ONE time step is used to run model compute function, save the output, and display debugging information on allocations and time


# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: a type dispatching for the models should be debugged and run for only one time step
"""
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

function timeStepTEM(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, ts)
    f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, ts, forcing_types)
    land = computeTEM(selected_models, f_ts, land, model_helpers)
    setOutputForTimeStep!(loc_output, land, ts, output_vars)
    return land
end

function timeStepTEMTest(selected_models, loc_forcing, loc_forcing_t, loc_output, land, forcing_types, model_helpers, output_vars, ts)
    @show "get forc"
    @time f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, ts, forcing_types)
    @show "compute"
    @time land = computeTEM(selected_models, f_ts, land, model_helpers)
    @show "set out"
    @time setOutputForTimeStep!(loc_output, land, ts, output_vars)
    @show "done"
    return land
end
