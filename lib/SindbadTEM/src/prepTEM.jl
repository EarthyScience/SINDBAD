export prepTEM

"""
    addSpinupLog(land, seq, ::DoStoreSpinup)



# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `seq`: DESCRIPTION
- `::DoStoreSpinup`: DESCRIPTION
"""
function addSpinupLog(land, seq, ::DoStoreSpinup) # when history is true
    n_repeat = 1
    for _seq in seq
        n_repeat = n_repeat + _seq["n_repeat"]
    end
    spinuplog = Vector{typeof(land.pools)}(undef, n_repeat)
    @pack_land spinuplog => land.states
    return land
end

"""
    addSpinupLog(land, _, ::DoNotStoreSpinup)



# Arguments:
- `land`: sindbad land
- `::DoNotStoreSpinup`: indicates not to store the spinup history
"""
function addSpinupLog(land, _, ::DoNotStoreSpinup) # when history is false
    spinuplog = nothing
    @pack_land spinuplog => land.states
    return land
end

"""
    debugModel(land_one, DoDebugModel)


"""
function debugModel(land_one, ::DoDebugModel) # print land when debug model is true/on
    Sindbad.eval(:(error_catcher = []))
    push!(Sindbad.error_catcher, land_one)
    tcPrint(land_one)
    return nothing
end


"""
    debugModel(_, ::DoNotDebugModel)


"""
function debugModel(_, ::DoNotDebugModel) # do nothing debug model is false/off
    return nothing
end

"""
"""
function getSpatialInfo(forcing, output)
    @info "     getting the space locations to run the model loop"
    forcing_sizes = forcing.helpers.sizes
    loopvars = collect(keys(forcing_sizes))
    additionaldims = setdiff(loopvars, [Symbol(forcing.helpers.dimensions.time)])::Vector{Symbol}
    spacesize = values(forcing_sizes[additionaldims])::Tuple
    loc_space_maps = vec(
        collect(Iterators.product(Base.OneTo.(spacesize)...))
    )::Vector{NTuple{length(forcing_sizes) -
                    1,
        Int}}

    loc_space_maps = map(loc_space_maps) do loc_names
        map(zip(loc_names, additionaldims)) do (loc_index, lv)
            lv => loc_index
        end
    end
    loc_space_maps = Tuple(loc_space_maps)

    forcing_nt_array = getForcingNamedTuple(forcing.data, forcing.variables)

    allNans = Bool[]
    for i ∈ eachindex(loc_space_maps)
        loc_forcing = getLocForcingData(forcing_nt_array, loc_space_maps[i])
        push!(allNans, all(isnan, loc_forcing[1]))
    end
    loc_space_maps = loc_space_maps[allNans.==false]
    loc_space_names = Tuple(first.(loc_space_maps[1]))
    loc_space_inds = Tuple([Tuple(last.(loc_space_map)) for loc_space_map ∈ loc_space_maps])

    return loc_space_inds, loc_space_maps, loc_space_names
end


"""
getTEMVals(forcing, output, loc_space_names, tem_helpers)
"""
function getTEMVals(forcing, output, loc_space_names, tem, tem_helpers)
    @info "     preparing vals for generated functions"
    vals = (; forc_vars=Val(forcing.variables), loc_space_names=Val(loc_space_names), output_vars=Val(output.variables))
    tem_dates = tem_helpers.dates
    tem_dates = (; timesteps_in_day=tem_dates.timesteps_in_day, timesteps_in_year=tem_dates.timesteps_in_year)
    tem_helpers = setTupleField(tem_helpers, (:dates, tem_dates))
    tem_numbers = tem_helpers.numbers
    tem_numbers = (; tolerance=tem_numbers.tolerance)
    tem_helpers = setTupleField(tem_helpers, (:vals, vals))
    tem_helpers = setTupleField(tem_helpers, (:numbers, tem_numbers))
    tem_with_types = setTupleField(tem, (:helpers, tem_helpers))
    return tem_with_types
end


"""
    helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutArray)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutArray`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutArray)

    
    # get the output things
    loc_space_inds, loc_space_maps, loc_space_names = getSpatialInfo(forcing, output)

    # generate vals for dispatch of forcing and output
    tem_with_types = getTEMVals(forcing, output, loc_space_names, tem, tem_helpers);


    ## run the model for one time step
    @info "     producing model output with one location and one time step"
    forcing_nt_array = getForcingNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    output_array = output.data
    forcing_one_timestep, loc_forcing, loc_output, land_one = runTEMOneLocation(selected_models, forcing_nt_array, output_array, land_init,
        loc_space_maps[1], tem_with_types, LandOutArray())
    debugModel(land_one, tem.helpers.run.debug_model)

    # loc_forcing = getLocForcingData(forcing, loc_space_map)
    # loc_output = getLocOutputData(output_array, loc_space_map)
    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    loc_forcings = map([loc_space_maps...]) do lsm
        getLocForcingData(forcing_nt_array, lsm)
    end
    loc_outputs = map([loc_space_maps...]) do lsm
        getLocOutputData(output_array, lsm)
    end

    # loc_forcings = Tuple([loc_forcing for _ ∈ 1:Threads.nthreads()])
    # loc_outputs = Tuple([loc_output for _ ∈ 1:Threads.nthreads()])
    land_init_space = Tuple([deepcopy(land_one) for _ ∈ 1:length(loc_space_maps)])

    run_helpers = (; loc_forcings=loc_forcings, forcing_one_timestep=forcing_one_timestep, output_array=output_array, loc_outputs=loc_outputs, land_init_space=land_init_space, land_one=land_one, out_dims=output.dims, out_vars=output.variables, tem_with_types=tem_with_types)
    # run_helpers = (; forcing_nt_array=forcing_nt_array, loc_forcing=loc_forcing, loc_forcings=loc_forcings, forcing_one_timestep=forcing_one_timestep, output_array=output_array, loc_outputs=loc_outputs, land_init_space=land_init_space, land_one=land_one, loc_space_inds=loc_space_inds, loc_space_maps=loc_space_maps, loc_space_names=loc_space_names, out_dims=output.dims, out_vars=output.variables, tem_with_types=tem_with_types)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutStacked)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutStacked`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutStacked)
    
    # get the output things
    loc_space_inds, loc_space_maps, loc_space_names = getSpatialInfo(forcing, output)

    # generate vals for dispatch of forcing and output
    tem_with_types = getTEMVals(forcing, output, loc_space_names, tem, tem_helpers);

    ## run the model for one time step
    @info "     producing model output with one location and one time step"
    land_init = output.land_init
    forcing_nt_array = getForcingNamedTuple(forcing.data, forcing.variables)
    loc_forcing = getLocForcingData(forcing_nt_array, loc_space_maps[1])
    forcing_one_timestep, land_one = runTEMOneLocationCore(selected_models, loc_forcing, land_init, tem_with_types)
    debugModel(land_one, tem.helpers.run.debug_model)

    run_helpers = (; loc_forcing=loc_forcing, forcing_one_timestep=forcing_one_timestep, land_one=land_one, loc_space_inds=loc_space_inds, loc_space_maps=loc_space_maps, loc_space_names=loc_space_names, out_dims=output.dims, out_vars=output.variables, tem_with_types=tem_with_types)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutTimeseries)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutTimeseries`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutTimeseries)
    run_helpers = helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, LandOutStacked())
    land_timeseries = Vector{typeof(run_helpers.land_one)}(undef, tem.helpers.dates.size)
    run_helpers = setTupleField(run_helpers, (:land_timeseries, land_timeseries))
    return run_helpers
end


"""
    prepTEM(forcing::NamedTuple, info::NamedTuple)



- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
function prepTEM(forcing::NamedTuple, info::NamedTuple)
    selected_models = info.tem.models.forward
    return prepTEM(selected_models, forcing, info)
end

"""
    prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
function prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run terrestrial ecosystem model (TEM)"
    tem_helpers = info.tem.helpers
    output = prepTEMOut(info, forcing.helpers)
    run_helpers = helpPrepTEM(selected_models, forcing, output, info.tem, tem_helpers, tem_helpers.run.land_output_type)
    @info "\n----------------------------------------------\n"
    return run_helpers
end


"""
    runTEMOneLocation(selected_models, forcing, output_array::AbstractArray, land_init, loc_space_map, tem)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `land_init`: initial SINDBAD land with all fields and subfields
- `loc_space_map`: DESCRIPTION
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `::LandOutArray`: a dispatch for running model with preallocated array
"""
function runTEMOneLocation(selected_models, forcing, output_array::AbstractArray, land_init, loc_space_map, tem, ::LandOutArray)
    loc_forcing, loc_output = getLocData(forcing, output_array, loc_space_map)
    forcing_one_timestep, land_one = runTEMOneLocationCore(selected_models, loc_forcing, land_init, tem)
    setOutputForTimeStep!(loc_output, land_one, 1, tem.helpers.vals.output_vars)
    return forcing_one_timestep, loc_forcing, loc_output, land_one
end

function runTEMOneLocationCore(selected_models, loc_forcing, land_init, tem)
    forcing_one_timestep = getForcingForTimeStep(loc_forcing, 1)
    land_prec = definePrecomputeTEM(selected_models, forcing_one_timestep, land_init,
        tem.helpers)
    land_one = computeTEM(selected_models, forcing_one_timestep, land_prec, tem.helpers)
    land_one = removeEmptyTupleFields(land_one)
    land_one = addSpinupLog(land_one, tem.spinup.sequence, tem.helpers.run.spinup.store_spinup)
    return forcing_one_timestep, land_one
end
