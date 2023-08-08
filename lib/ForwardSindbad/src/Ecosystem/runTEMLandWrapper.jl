export coreTEM
export runTEM

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, _, _, Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `_`: unused argument
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_time_series = timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return land_time_series
end

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, tem_models, tem_spinup, Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    land_time_series = timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return land_time_series
end


"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, _, _, Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `_`: unused argument
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_time_series,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, tem_models, tem_spinup, Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_time_series,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

"""
    runTEM(forcing::NamedTuple, info::NamedTuple)

DOCSTRING
"""
function runTEM(forcing::NamedTuple, info::NamedTuple)
    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem = prepTEM(forcing, info)
    land_time_series = coreTEM(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem.helpers, tem.models, tem.spinup, tem.helpers.run.spinup.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, forcing_one_timestep, land_init::NamedTuple, tem::NamedTuple)

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function runTEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    forcing_one_timestep,
    land_init::NamedTuple,
    tem::NamedTuple)
    land_time_series = coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem.helpers, tem.models, tem.spinup, tem.helpers.run.spinup.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, forcing_one_timestep, land_time_series, land_init::NamedTuple, tem::NamedTuple)

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function runTEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    forcing_one_timestep,
    land_time_series,
    land_init::NamedTuple,
    tem::NamedTuple)
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem.helpers, tem.models, tem.spinup, tem.helpers.run.spinup.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, Val{:(false)})

time loop of the model run where forcing for the time step is used to run model compute function, in which land has been preallocated as a vector

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `Val{:false}`: a flag indicating that the models should NOT be debugged and run for only ALL time steps
"""
function timeLoopTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    for ts = 1:num_timesteps
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        land_time_series[ts] = land
    end
    return nothing
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, Val{:(true)})

time loop of the model run where forcing for ONE time step is used to run model compute function, and display debugging information on allocations and time, in which land has been preallocated as a vector

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_time_series`: a vector (=length of time dimension) of SINDBAD land after the model define, precompute, and compute have been run for a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `Val{:true}`: a flag indicating that the models should be debugged and run for only one time step
"""
function timeLoopTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `nothing`: DESCRIPTION
"""
function timeLoopTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    land_time_series = map(1:num_timesteps) do ts
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        land
    end
    return land_time_series
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `nothing`: DESCRIPTION
"""
function timeLoopTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    @info "\nforc\n"
    @time f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, 1, tem_helpers.vals.forc_vars)
    @info "\n-------------\n"
    @info "\neach model\n"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers, tem_helpers.run.debug_model)
    @info "\n-------------\n"
    @info "\nall models\n"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers)
    @info "\n-------------\n"
    return [land]
end
