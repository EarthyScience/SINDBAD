export coreTEM
export runTEM

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, _, _, DoNotSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `_`: unused argument
- `DoNotSpinupTEM`: DESCRIPTION
"""
function coreTEM(selected_models, forcing, _, forcing_one_timestep, land_init, tem_helpers, _, ::DoNotSpinupTEM) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_time_series = timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_prec, tem_helpers, tem_helpers.run.debug_model)
    return land_time_series
end

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, tem_models, tem_spinup, ::DoSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `DoSpinupTEM`: DESCRIPTION
"""
function coreTEM(selected_models, forcing, spinup_forcing, forcing_one_timestep, land_init, tem_helpers, tem_spinup, ::DoSpinupTEM) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(selected_models, spinup_forcing, forcing_one_timestep, land_prec, tem_helpers, tem_spinup)

    land_time_series = timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_spin, tem_helpers, tem_helpers.run.debug_model)
    return land_time_series
end


"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, _, _, ::DoNotSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `_`: unused argument
- `::DoNotSpinupTEM`: DESCRIPTION
"""
function coreTEM(selected_models, forcing, _, forcing_one_timestep, land_time_series, land_init, tem_helpers, _, ::DoNotSpinupTEM) # without spinup
    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_prec, tem_helpers, tem_helpers.run.debug_model)
    return nothing
end

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, tem_models, tem_spinup, ::DoSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::DoSpinupTEM`: DESCRIPTION
"""
function coreTEM(selected_models, forcing, spinup_forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, tem_spinup, ::DoSpinupTEM) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(selected_models, spinup_forcing, forcing_one_timestep, land_prec, tem_helpers, tem_spinup)

    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_spin, tem_helpers, tem_helpers.run.debug_model)
    return nothing
end

"""
    runTEM(forcing::NamedTuple, info::NamedTuple)


"""
function runTEM(forcing::NamedTuple, info::NamedTuple)
    run_helpers = prepTEM(forcing, info)
    land_time_series = coreTEM(info.tem.models.forward, run_helpers.loc_forcings[1], run_helpers.loc_spinup_forcings[1], run_helpers.forcing_one_timestep, run_helpers.land_one, run_helpers.tem_with_types.helpers, run_helpers.tem_with_types.spinup, run_helpers.tem_with_types.helpers.run.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, forcing_one_timestep, land_init::NamedTuple, tem::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function runTEM(selected_models::Tuple, forcing::NamedTuple, spinup_forcing, forcing_one_timestep, land_init::NamedTuple, tem::NamedTuple)
    land_time_series = coreTEM(selected_models, forcing, spinup_forcing, forcing_one_timestep, land_init, tem.helpers, tem.spinup, tem.helpers.run.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, forcing_one_timestep, land_time_series, land_init::NamedTuple, tem::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function runTEM(selected_models::Tuple, forcing::NamedTuple, spinup_forcing, forcing_one_timestep, land_time_series, land_init::NamedTuple, tem::NamedTuple)
    coreTEM(selected_models, forcing, spinup_forcing, forcing_one_timestep, land_time_series, land_init, tem.helpers, tem.spinup, tem.helpers.run.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, ::DoNotDebugModel)

time loop of the model run where forcing for the time step is used to run model compute function, in which land has been preallocated as a vector

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: a flag indicating that the models should NOT be debugged and run for only ALL time steps
"""
function timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, ::DoNotDebugModel) # do not debug the models
    for ts ∈ 1:tem_helpers.n_timesteps
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_types)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        land_time_series[ts] = land
    end
    return nothing
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, ::DoDebugModel})

time loop of the model run where forcing for ONE time step is used to run model compute function, and display debugging information on allocations and time, in which land has been preallocated as a vector

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: a flag indicating that the models should be debugged and run for only one time step
"""
function timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, _, tem_helpers, ::DoDebugModel) # debug the models
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, DoDebugModel())
    return nothing
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, ::DoNotDebugModel)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: DESCRIPTION
"""
function timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, ::DoNotDebugModel) # do not debug the models
    land_time_series = map(1:tem_helpers.n_timesteps) do ts
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_types)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        land
    end
    return land_time_series
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, ::DoDebugModel)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: DESCRIPTION
"""
function timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, ::DoDebugModel) # debug the models
    @info "\nforc\n"
    @time f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, 1, tem_helpers.vals.forc_types)
    @info "\n-------------\n"
    @info "\neach model\n"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers, tem_helpers.run.debug_model)
    @info "\n-------------\n"
    @info "\nall models\n"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers)
    @info "\n-------------\n"
    return [land]
end
