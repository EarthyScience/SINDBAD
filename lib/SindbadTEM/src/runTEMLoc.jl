export coreTEM
export runTEM

"""
    coreTEM(selected_models, loc_forcing, loc_forcing_t, loc_land, tem_info, _, _, DoNotSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for a location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `_`: unused argument
- `DoNotSpinupTEM`: DESCRIPTION
"""
function coreTEM(selected_models, loc_forcing, _, loc_forcing_t, loc_land, tem_info, ::DoNotSpinupTEM) # without spinup

    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers)

    land_time_series = timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_prec, tem_info, tem_info.run.debug_model)
    return land_time_series
end

"""
    coreTEM(selected_models, loc_forcing, loc_forcing_t, loc_land, tem_info, tem_models, tem_spinup, ::DoSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for a location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `DoSpinupTEM`: DESCRIPTION
"""
function coreTEM(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_land, tem_info, ::DoSpinupTEM) # with spinup

    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers)

    land_spin = spinupTEM(selected_models, loc_spinup_forcing, loc_forcing_t, land_prec, tem_info)

    land_time_series = timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_spin, tem_info, tem_info.run.debug_model)
    return land_time_series
end


"""
    coreTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, loc_land, tem_info, _, _, ::DoNotSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for a locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `_`: unused argument
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoNotSpinupTEM`: a type dispatch to indicate that spinup is excluded
"""
function coreTEM(selected_models, loc_forcing, _, loc_forcing_t, land_time_series, loc_land, tem_info, ::DoNotSpinupTEM) # without spinup
    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers)
    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land_prec, tem_info, tem_info.run.debug_model)
    return nothing
end

"""
    coreTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, loc_land, tem_info, tem_models, tem_spinup, ::DoSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for a locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::DoSpinupTEM`: a type dispatch to indicate that spinup is included
"""
function coreTEM(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, land_time_series, loc_land, tem_info, ::DoSpinupTEM) # with spinup

    land_prec = precomputeTEM(selected_models, loc_forcing_t, loc_land, tem_info.model_helpers)

    land_spin = spinupTEM(selected_models, loc_spinup_forcing, loc_forcing_t, land_prec, tem_info)

    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land_spin, tem_info, tem_info.run.debug_model)
    return nothing
end

"""
    runTEM(forcing::NamedTuple, info::NamedTuple)


"""
function runTEM(forcing::NamedTuple, info::NamedTuple)
    run_helpers = prepTEM(forcing, info)
    land_time_series = coreTEM(info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, run_helpers.loc_land, run_helpers.tem_info.model_helpers, run_helpers.tem_info.spinup_sequence, run_helpers.tem_info.run.spinup_TEM)
    return LandWrapper(land_time_series)
end

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, loc_forcing_t, loc_land::NamedTuple, tem_info::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function runTEM(selected_models::Tuple, forcing::NamedTuple, loc_spinup_forcing, loc_forcing_t, loc_land::NamedTuple, tem_info::NamedTuple)
    land_time_series = coreTEM(selected_models, forcing, loc_spinup_forcing, loc_forcing_t, loc_land, tem_info, tem_info.run.spinup_TEM)
    return LandWrapper(land_time_series)
end

"""
    runTEM(selected_models::Tuple, loc_forcing::NamedTuple, loc_forcing_t, land_time_series, loc_land::NamedTuple, tem_info::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function runTEM(selected_models::Tuple, loc_forcing::NamedTuple, loc_spinup_forcing, loc_forcing_t, land_time_series, loc_land::NamedTuple, tem_info::NamedTuple)
    coreTEM(selected_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, land_time_series, loc_land, tem_info, tem_info.run.spinup_TEM)
    return LandWrapper(land_time_series)
end

"""
    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land, tem_info, ::DoNotDebugModel)

time loop of the model run where forcing for the time step is used to run model compute function, in which land has been preallocated as a vector

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: a type dispatch to indicate that the models should NOT be debugged and run for only ALL time steps
"""
function timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land, tem_info, ::DoNotDebugModel) # do not debug the models
    for ts ∈ 1:tem_info.n_timesteps
        f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, ts, tem_info.vals.forcing_types)
        land = computeTEM(selected_models, f_ts, land, tem_info.model_helpers)
        land_time_series[ts] = land
    end
    return nothing
end

"""
    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_time_series, land, tem_info, ::DoDebugModel})

time loop of the model run where forcing for ONE time step is used to run model compute function, and display debugging information on allocations and time, in which land has been preallocated as a vector

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: a type dispatch to indicate that the models should be debugged and run for only one time step
"""
function timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, _, tem_info, ::DoDebugModel) # debug the models
    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, tem_info, DoDebugModel())
    return nothing
end

"""
    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, tem_info, ::DoNotDebugModel)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: DESCRIPTION
"""
function timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, tem_info, ::DoNotDebugModel) # do not debug the models
    land_time_series = map(1:tem_info.n_timesteps) do ts
        f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, ts, tem_info.vals.forcing_types)
        land = computeTEM(selected_models, f_ts, land, tem_info.model_helpers)
        land
    end
    return land_time_series
end

"""
    timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, tem_info, ::DoDebugModel)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_info`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: DESCRIPTION
"""
function timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land, tem_info, ::DoDebugModel) # debug the models
    @info "\nforc\n"
    @time f_ts = getForcingForTimeStep(loc_forcing, loc_forcing_t, 1, tem_info.vals.forcing_types)
    @info "\n-------------\n"
    @info "\neach model\n"
    @time land = computeTEM(selected_models, f_ts, land, tem_info.model_helpers, tem_info.run.debug_model)
    @info "\n-------------\n"
    @info "\nall models\n"
    @time land = computeTEM(selected_models, f_ts, land, tem_info.model_helpers)
    @info "\n-------------\n"
    return [land]
end
