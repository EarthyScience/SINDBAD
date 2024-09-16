export prepTEM


"""
    addErrorCatcher(loc_land, DoDebugModel)

add error catcher and show land when debug model is turned on

# Arguments:
- `loc_land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `::DoDebugModel`: a type dispatch to debug the model
"""
function addErrorCatcher(loc_land, ::DoDebugModel) # print land when debug model is true/on
    Sindbad.eval(:(error_catcher = []))
    push!(Sindbad.error_catcher, loc_land)
    tcPrint(loc_land)
    return nothing
end


"""
    addErrorCatcher(loc_land, DoDebugModel)

a fallback function to call when not to add error_catcher to land

# Arguments:
- `::DoDebugModel`: a type dispatch to debug the model
"""
function addErrorCatcher(_, ::DoNotDebugModel) # do nothing debug model is false/off
    return nothing
end


"""
    addSpinupLog(loc_land, sequence, ::DoStoreSpinup)

add preallocated holder for storing spinup log for each repeat of spinup

# Arguments:
- `loc_land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `sequence`: spinup sequence
- `::DoStoreSpinup`: a type dispatch to store the spinup history
"""
function addSpinupLog(loc_land, sequence, ::DoStoreSpinup) # when history is true
    n_repeat = 1
    for _seq in sequence
        n_repeat = n_repeat + _seq.n_repeat
    end
    spinuplog = Vector{typeof(loc_land.pools)}(undef, n_repeat)
    @pack_nt spinuplog ⇒ loc_land.states
    return loc_land
end

"""
    addSpinupLog(land, _, ::DoNotStoreSpinup)

a fallback function to call when not to add spinuplog to land

# Arguments:
- `loc_land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `::DoNotStoreSpinup`: a type dispatch not to store the spinup history
"""
function addSpinupLog(loc_land, _, ::DoNotStoreSpinup) # when history is false
    return loc_land
end


"""
    filterNanPixels(forcing, loc_space_maps, ::DoNotFilterNanPixels)

filter all the pixels where every timestep is a nan, i.e., masked out regions

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_space_maps`: local coordinates of all input points
- `::DoNotFilterNanPixels`: a type dispatch to not filter all nan only pixels
"""
function filterNanPixels(_, loc_space_maps, ::DoNotFilterNanPixels)
    return loc_space_maps
end


"""
    filterNanPixels(forcing, loc_space_maps, ::DoFilterNanPixels)

filter all the pixels where every timestep is a nan, i.e., masked out regions

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_space_maps`: local coordinates of all input points
- `::DoFilterNanPixels`: a type dispatch to filter all nan only pixels
"""
function filterNanPixels(forcing, loc_space_maps, ::DoFilterNanPixels)
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    allNans = Bool[]
    for i ∈ eachindex(loc_space_maps)
        loc_ind = Tuple(last.(loc_space_maps[i]))
        loc_forcing = getLocDataNT(forcing_nt_array, loc_ind)
        push!(allNans, all(isnan, loc_forcing[1]))
    end
    loc_space_maps = loc_space_maps[allNans.==false]
    return loc_space_maps
end


"""
    getRunTemInfo(info, forcing)

a helper to condense the useful info only for the inner model runs

# Arguments:
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
"""
function getRunTemInfo(info, forcing)
    tem_helpers=info.helpers
    output_vars = info.output.variables
    @debug "     preparing vals for generated functions"
    vals = (; forcing_types=Val(forcing.f_types), output_vars=Val(output_vars))
    upd_tem_helpers = (;)
    tem_dates = tem_helpers.dates
    tem_dates = (; timesteps_in_day=tem_dates.timesteps_in_day, timesteps_in_year=tem_dates.timesteps_in_year)
    # upd_tem_helpers = setTupleField(upd_tem_helpers, (:dates, tem_dates))
    time_size = getproperty(forcing.helpers.sizes, Symbol(forcing.helpers.dimensions.time))
    upd_tem_helpers = setTupleField(upd_tem_helpers, (:n_timesteps, time_size))
    tem_numbers = tem_helpers.numbers
    tem_numbers = (; tolerance=tem_numbers.tolerance)
    model_helpers = (;)
    model_helpers = setTupleField(model_helpers, (:dates, tem_dates))
    model_helpers = setTupleField(model_helpers, (:run, (; catch_model_errors=tem_helpers.run.catch_model_errors)))
    model_helpers = setTupleField(model_helpers, (:numbers, tem_numbers))
    model_helpers = setTupleField(model_helpers, (:pools, tem_helpers.pools))
    upd_tem_helpers = setTupleField(upd_tem_helpers, (:vals, vals))
    upd_tem_helpers = setTupleField(upd_tem_helpers, (:model_helpers, model_helpers))
    upd_tem_helpers = setTupleField(upd_tem_helpers, (:run, tem_helpers.run))
    upd_tem_helpers = setTupleField(upd_tem_helpers, (:spinup_sequence, getSpinupTemLite(info.spinup.sequence)))

    return upd_tem_helpers
end


"""
    getSpatialInfo(forcing, filterNanPixels)

get the information of the indices of the data to run the model for

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
"""
function getSpatialInfo(forcing, filter_nan_pixels)
    @debug "     getting the space locations to run the model loop"
    forcing_sizes = forcing.helpers.sizes
    loopvars = collect(keys(forcing_sizes))
    additionaldims = setdiff(loopvars, [Symbol(forcing.helpers.dimensions.time)])
    spacesize = values(forcing_sizes[additionaldims])
    loc_space_maps = vec(collect(Iterators.product(Base.OneTo.(spacesize)...)))
    loc_space_maps = map(loc_space_maps) do loc_names
        map(zip(loc_names, additionaldims)) do (loc_index, lv)
            lv => loc_index
        end
    end
    loc_space_maps = Tuple(loc_space_maps)
    loc_space_maps = filterNanPixels(forcing, loc_space_maps, filter_nan_pixels)
    space_ind = Tuple([Tuple(last.(loc_space_map)) for loc_space_map ∈ loc_space_maps])
    return space_ind
end



"""
    getSpinupTemLite(tem_spinup)

a helper to just get the spinup sequence to pass to inner functions

# Arguments:
- `tem_spinup_sequence`: a NT with all spinup information
"""
function getSpinupTemLite(tem_spinup_sequence)
    newseqs = []
    for seq in tem_spinup_sequence
        ns = (; forcing=seq.forcing, n_repeat= seq.n_repeat, n_timesteps=seq.n_timesteps, spinup_mode=seq.spinup_mode, options=seq.options)
        push!(newseqs, ns)
    end
    sequence = [_s for _s in newseqs]
    return sequence

end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutArray)


prepare the information and objects needed to run TEM

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::LandOutArray`: a type dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutArray)

    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing, info.helpers.run.filter_nan_pixels)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);


    ## run the model for one time step
    @info "     model run for one location and time step"
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    loc_forcing = getLocDataNT(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)

    addErrorCatcher(loc_land, info.helpers.run.debug_model)

    output_array = output.data
    output_vars = output.variables
    output_dims = output.dims

    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    space_forcing = map([space_ind...]) do lsi
        getLocDataNT(forcing_nt_array, lsi)
    end
    space_spinup_forcing = map(space_forcing) do loc_forcing
        getAllSpinupForcing(loc_forcing, info.spinup.sequence, tem_info);
    end

    space_output = map([space_ind...]) do lsi
        getLocDataArray(output_array, lsi)
    end

    space_land = Tuple([deepcopy(loc_land) for _ ∈ 1:length(space_ind)])

    forcing_nt_array = nothing

    run_helpers = (; space_forcing, space_ind, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, loc_land, output_dims, output_vars, tem_info)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutArrayAll)

prepare the information and objects needed to run TEM

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::LandOutArrayAll`: a type dispatch for preparing TEM for using preallocated array to output ALL LAND VARIABLES
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutArrayAll)

    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing, info.helpers.run.filter_nan_pixels)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);

    ## run the model for one time step
    @info "     model run for one location and time step"
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    loc_forcing = getLocDataNT(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)

    addErrorCatcher(loc_land, info.helpers.run.debug_model)

    info = setModelOutputLandAll(info, loc_land)

    tem_info = @set tem_info.vals.output_vars = Val(info.output.variables)
    output_dims, output_array = getOutDimsArrays(info, forcing.helpers)

    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    space_forcing = map([space_ind...]) do lsi
        getLocDataNT(forcing_nt_array, lsi)
    end
    space_spinup_forcing = map(space_forcing) do loc_forcing
        getAllSpinupForcing(loc_forcing, info.spinup.sequence, tem_info);
    end

    space_output = map([space_ind...]) do lsi
        getLocDataArray(output_array, lsi)
    end

    space_land = Tuple([deepcopy(loc_land) for _ ∈ 1:length(space_ind)])

    forcing_nt_array = nothing

    run_helpers = (; space_forcing, space_ind, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, loc_land, output_dims, output_vars=info.output.variables, tem_info)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, observations::NamedTuple, output::NamedTuple, ::LandOutArrayFD)

prepare the information and objects needed to run TEM

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: an observation NT including the observation data and variables
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::LandOutArrayFD`: a type dispatch for preparing TEM for using preallocated array while doing FD hybrid experiment
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, observations::NamedTuple, output::NamedTuple, ::LandOutArrayFD)

    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing, info.helpers.run.filter_nan_pixels)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);


    ## run the model for one time step
    @info "     model run for one location and time step"
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    output_array = output.data
    loc_forcing = getLocDataNT(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)

    addErrorCatcher(loc_land, info.helpers.run.debug_model)

    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    space_forcing = map([space_ind...]) do lsi
        getLocDataNT(forcing_nt_array, lsi)
    end
    
    observations_nt_array = makeNamedTuple(observations.data, observations.variables)
    space_observation = map([space_ind...]) do lsi
        getLocDataNT(observations_nt_array, lsi)
    end
    observations_nt_array = nothing

    space_spinup_forcing = map(space_forcing) do loc_forcing
        getAllSpinupForcing(loc_forcing, info.spinup.sequence, tem_info);
    end

    space_output = map([space_ind...]) do lsi
        getLocDataArray(output_array, lsi)
    end

    forcing_nt_array = nothing

    run_helpers = (; space_forcing, space_observation, space_ind, space_spinup_forcing, loc_forcing_t, space_output, loc_land, output_vars=output.variables, tem_info)

    return run_helpers
end



"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutStacked)


prepare the information and objects needed to run TEM

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::LandOutStacked`: a type dispatch for preparing TEM for running model and saving output as stacked land vector
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutStacked)
    
    # get the output things
    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing, info.helpers.run.filter_nan_pixels)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);

    ## run the model for one time step
    @info "     model run for one location and time step"
    land_init = output.land_init
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    loc_forcing = getLocDataNT(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)
    addErrorCatcher(loc_land, info.helpers.run.debug_model)

    output_vars = output.variables
    output_dims = output.dims

    run_helpers = (; loc_forcing, loc_forcing_t, loc_land, space_ind, output_dims, output_vars, tem_info)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutTimeseries)


prepare the information and objects needed to run TEM

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::LandOutTimeseries`: a type dispatch for preparing TEM for running model and saving output of land as a preallocated time series
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutTimeseries)
    run_helpers = helpPrepTEM(selected_models, info, forcing, output, LandOutStacked())
    land_timeseries = Vector{typeof(run_helpers.loc_land)}(undef, tem_helpers.dates.size)
    run_helpers = setTupleField(run_helpers, (:land_timeseries, land_timeseries))
    return run_helpers
end



"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutYAXArray)


prepare the information and objects needed to run TEM

# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::LandOutYAXArray`: a type dispatch for preparing TEM for using yax array for model output
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, ::LandOutYAXArray)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);
    # tem_info = @set tem_info.spinup = info.spinup.sequence

    loc_land = output.land_init
    output_vars = output.variables
    output_dims = output.dims

    run_helpers = (; loc_land, output_vars, output_dims, tem_info)
    return run_helpers
end

"""
    prepTEM(forcing::NamedTuple, info::NamedTuple)



- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function prepTEM(forcing::NamedTuple, info::NamedTuple)
    selected_models = info.models.forward
    return prepTEM(selected_models, forcing, info)
end

"""
    prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run terrestrial ecosystem model (TEM)"
    output = prepTEMOut(info, forcing.helpers)
    @info "  helpPrepTEM: preparing helpers for running model experiment"
    run_helpers = helpPrepTEM(selected_models, info, forcing, output, info.helpers.run.land_output_type)
    @info "\n----------------------------------------------\n"
    return run_helpers
end

"""
    prepTEM(selected_models, forcing::NamedTuple, observations, info::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
"""
function prepTEM(selected_models, forcing::NamedTuple, observations::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run terrestrial ecosystem model (TEM)"
    output = prepTEMOut(info, forcing.helpers)
    run_helpers = helpPrepTEM(selected_models, info, forcing, observations, output, info.helpers.run.land_output_type)
    @info "\n----------------------------------------------\n"
    return run_helpers
end


"""
    runTEMOne(selected_models, forcing, output_array::AbstractArray, land_init, loc_ind, tem)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `land_init`: initial SINDBAD land with all fields and subfields
- `loc_ind`: DESCRIPTION
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `::LandOutArray`: a dispatch for running model with preallocated array
"""
function runTEMOne(selected_models, loc_forcing, land_init, tem)
    loc_forcing_t = getForcingForTimeStep(loc_forcing, loc_forcing, 1, tem.vals.forcing_types)
    loc_land = definePrecomputeTEM(selected_models, loc_forcing_t, land_init,
        tem.model_helpers)
    # loc_land = computeTEM(selected_models, loc_forcing_t, loc_land, tem.model_helpers)
    # loc_land = removeEmptyTupleFields(loc_land)
    loc_land = addSpinupLog(loc_land, tem.spinup_sequence, tem.run.store_spinup)
    # loc_land = definePrecomputeTEM(selected_models, loc_forcing_t, loc_land,
        # tem.model_helpers)
    # loc_land = precomputeTEM(selected_models, loc_forcing_t, loc_land,
        # tem.model_helpers)
    # loc_land = computeTEM(selected_models, loc_forcing_t, loc_land, tem.model_helpers)
    return loc_forcing_t, loc_land
end
