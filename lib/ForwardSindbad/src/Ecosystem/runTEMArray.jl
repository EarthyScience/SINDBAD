export coreTEM!
export runTEM!
export TEM!

"""
    coreTEM!(selected_models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem_helpers, _, _, nothing::Val{:(false)})

A core function of SINDBAD TEM that includes the precompute, spinup, and time loop of the model run


# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `_`: unused argument
- `_`: unused argument
- `::Val{:true}`: a flag to indicate that spinup is NOT included
"""
function coreTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    timeLoopTEM!(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

"""
    coreTEM!(selected_models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem_helpers, tem_models, tem_spinup, nothing::Val{:(true)})

A core function of SINDBAD TEM that includes the precompute, spinup, and time loop of the model run

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::Val{:true}`: a flag to indicate that spinup is included
"""
function coreTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    timeLoopTEM!(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

"""
    parallelizeTEM!(selected_models, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem_helpers, tem_models, tem_spinup, nothing::Val{:threads})

parallelize SINDBAD TEM using threads as backend

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing_nt_array`: a forcing NT that contain the forcing time series set for ALL locations, with each variable as an instantiated array in memory
- `loc_forcings`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_outputs`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `land_init_space`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `loc_space_inds`: a collection of spatial indices/pairs of indices used to loop through space in parallelization
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::Val{:threads}`: dispatch for threads
"""
function parallelizeTEM!(
    selected_models,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:threads})
    Threads.@threads for space_index ∈ eachindex(loc_space_inds)
        thread_id = Threads.threadid()
        TEM!(
            selected_models,
            forcing_nt_array,
            loc_forcings[thread_id],
            forcing_one_timestep,
            output_array,
            loc_outputs[thread_id],
            land_init_space[space_index],
            loc_space_inds[space_index],
            tem_helpers,
            tem_models,
            tem_spinup)
    end
    return nothing
end

"""
    parallelizeTEM!(selected_models, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem_helpers, tem_models, tem_spinup, nothing::Val{:qbmap})

parallelize SINDBAD TEM using qbmap as backend

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing_nt_array`: a forcing NT that contain the forcing time series set for ALL locations, with each variable as an instantiated array in memory
- `loc_forcings`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_outputs`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `land_init_space`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `loc_space_inds`: a collection of spatial indices/pairs of indices used to loop through space in parallelization
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
- `::Val{:qbmap}`: dispatch for qbmap
"""
function parallelizeTEM!(
    selected_models,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:qbmap})
    space_index = 1
    qbmap(loc_space_inds) do loc_space_ind
        thread_id = Threads.threadid()
        TEM!(
            selected_models,
            forcing_nt_array,
            loc_forcings[thread_id],
            forcing_one_timestep,
            output_array,
            loc_outputs[thread_id],
            land_init_space[space_index],
            loc_space_inds[space_index],
            tem_helpers,
            tem_models,
            tem_spinup)
        space_index += 1
    end
    return nothing
end

"""
    runTEM!(forcing::NamedTuple, info::NamedTuple)

The main SINDBAD Terrestrial Ecosystem Model function that runs the simulation for all pixels and time using preallocated array as model data backend, with only info and forcing as input, and model simulation output as arrays 

# Arguments:
- `forcing`: a tuple of models selected for the given model structure
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment    
"""
function runTEM!(forcing::NamedTuple, info::NamedTuple)
    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, _, _, tem_with_vals = prepTEM(forcing, info)
    runTEM!(tem_with_vals.models.forward, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem_with_vals)
    return output_array
end

"""
    runTEM!(selected_models, forcing_nt_array::NamedTuple, loc_forcings, forcing_one_timestep, output_array::AbstractArray, loc_outputs, land_init_space, loc_space_inds, tem_with_vals::NamedTuple)

The main SINDBAD Terrestrial Ecosystem Model function that runs the simulation for all pixels and time using preallocated array as model data backend, with precomputed helper objects for efficient runs during optimization.

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing_nt_array`: a forcing NT that contain the forcing time series set for ALL locations, with each variable as an instantiated array in memory
- `loc_forcings`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_outputs`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `land_init_space`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `loc_space_inds`: a collection of spatial indices/pairs of indices used to loop through space in parallelization
- `tem_with_vals`: DESCRIPTION
"""
function runTEM!(
    selected_models,
    forcing_nt_array::NamedTuple,
    loc_forcings,
    forcing_one_timestep,
    output_array::AbstractArray,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals::NamedTuple)
    parallelizeTEM!(
        selected_models,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem_with_vals.helpers,
        tem_with_vals.models,
        tem_with_vals.spinup,
        tem_with_vals.helpers.run.parallelization)
    return nothing
end

"""
    TEM!(selected_models, forcing, loc_forcing, forcing_one_timestep, output_array, loc_output, land_init, loc_space_ind, tem_helpers, tem_models, tem_spinup)

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contain the forcing time series set for ALL locations
- `loc_forcing`: a forcing time series set for a single location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_output`: an output array/view for a single location
- `land_init`: initial SINDBAD land with all fields and subfields
- `loc_space_ind`: an index/pair of indices to spatially map the location of the current location/pixel being run
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
"""
function TEM!(
    selected_models,
    forcing,
    loc_forcing,
    forcing_one_timestep,
    output_array,
    loc_output,
    land_init,
    loc_space_ind,
    tem_helpers,
    tem_models,
    tem_spinup)
    getLocForcing!(forcing, loc_forcing, loc_space_ind, tem_helpers.vals.forc_vars, tem_helpers.vals.loc_space_names)
    getLocOutput!(output_array, loc_output, loc_space_ind)
    coreTEM!(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem_helpers,
        tem_models,
        tem_spinup,
        tem_helpers.run.spinup.spinup_TEM)
    return nothing
end


"""
    timeLoopTEM!(selected_models, loc_forcing, forcing_one_timestep, loc_output, land, tem_helpers, nothing::Val{:(false)})

Time loop of the model run where forcing for the time step is used to run model compute function and save the output into preallocated output array

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::Val{:false}`: a flag indicating that the models should NOT be debugged and run for only ALL time steps
"""
function timeLoopTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(loc_forcing, tem_helpers.vals.forc_vars)
    for ts ∈ 1:num_timesteps
        f_ts = getForcingForTimeStep(loc_forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        setOutputForTimeStep!(loc_output, land, ts, tem_helpers.vals.output_vars)
    end
    return nothing
end


"""
    timeLoopTEM!(selected_models, loc_forcing, forcing_one_timestep, loc_output, land, tem_helpers, nothing::Val{:(true)})

Time loop of the model run where forcing for ONE time step is used to run model compute function and save the output with debugging information on allocations and time


# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `loc_forcing`: a forcing time series set for a single location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `loc_output`: an output array/view for a single location
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::Val{:true}`: a flag indicating that the models should be debugged and run for only one time step
"""
function timeLoopTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    @show "forc"
    @time f_ts = getForcingForTimeStep(loc_forcing, forcing_one_timestep, 1, tem_helpers.vals.forc_vars)
    println("-------------")
    @show "each model"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers)
    println("-------------")
    @show "set output"
    @time setOutputForTimeStep!(loc_output, land, 1, tem_helpers.vals.output_vars)
    println("-------------")
    return nothing
end
