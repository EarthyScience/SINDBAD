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
        n_repeat = n_repeat + _seq.n_repeat
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
    return land
end

"""
    debugModel(loc_land, DoDebugModel)


"""
function debugModel(loc_land, ::DoDebugModel) # print land when debug model is true/on
    Sindbad.eval(:(error_catcher = []))
    push!(Sindbad.error_catcher, loc_land)
    tcPrint(loc_land)
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
function getSpatialInfo(forcing)
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

    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)

    allNans = Bool[]
    for i ∈ eachindex(loc_space_maps)
        loc_ind = Tuple(last.(loc_space_maps[i]))
        loc_forcing = getLocForcingData(forcing_nt_array, loc_ind)
        push!(allNans, all(isnan, loc_forcing[1]))
    end
    loc_space_maps = loc_space_maps[allNans.==false]
    space_ind = Tuple([Tuple(last.(loc_space_map)) for loc_space_map ∈ loc_space_maps])

    return space_ind
end


function getSpinupTemLite(tem_spinup)
    newseqs = []
    for seq in tem_spinup.sequence
        ns = (; forcing=seq.forcing, n_repeat= seq.n_repeat, n_timesteps=seq.n_timesteps, spinup_mode=seq.spinup_mode, options=seq.options)
        # ns = SpinSequence(seq.forcing, seq.n_repeat, seq.n_timesteps, seq.spinup_mode, seq.options)
        push!(newseqs, ns)
    end
    sequence = [_s for _s in newseqs]
    return sequence

end

"""
getRunTemInfo(forcing, output_vars, tem_helpers)
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
    upd_tem_helpers = setTupleField(upd_tem_helpers, (:spinup_sequence, getSpinupTemLite(info.spinup)))

    return upd_tem_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutArray)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutArray`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, observations::NamedTuple, output::NamedTuple, tem_helpers::NamedTuple, ::LandOutArrayFD)

    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);


    ## run the model for one time step
    @info "     model run for one location and time step"
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    output_array = output.data
    loc_forcing = getLocForcingData(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)

    debugModel(loc_land, tem_helpers.run.debug_model)

    ovars = output.variables;
    i = 1
    output_array = map(output_array) do od
        ov = ovars[i]
        mod_field = first(ov)
        mod_subfield = last(ov)
        lvar = getproperty(getproperty(loc_land, mod_field), mod_subfield)
        if lvar isa AbstractArray
            eltype(lvar).(od)
        else
            typeof(lvar).(od)
        end
    end

    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    space_forcing = map([space_ind...]) do lsi
        getLocForcingData(forcing_nt_array, lsi)
    end
    
    observations_nt_array = makeNamedTuple(observations.data, observations.variables)
    loc_observations = map([space_ind...]) do lsi
        getLocForcingData(observations_nt_array, lsi)
    end

    space_spinup_forcing = map(space_forcing) do loc_forcing
        getAllSpinupForcing(loc_forcing, tem_info.spinup_sequence, tem_info.model_helpers);
    end

    space_output = map([space_ind...]) do lsi
        getLocOutputData(output_array, lsi)
    end

    forcing_nt_array = nothing

    run_helpers = (; space_forcing, loc_observations, space_ind, space_spinup_forcing, loc_forcing_t, space_output, loc_land, output_vars=output.variables, tem_info)

    return run_helpers
end

function getAllLandVars(land)
    av=[]
    for f in propertynames(land)
        lf = getproperty(land,f)
        for sf in propertynames(lf)
            pv = getproperty(lf, sf)
            if (isa(pv, AbstractArray) && ndims(pv) < 2)  || isa(pv, Number)
                push!(av, (f, sf))
            end
        end
    end
    return Tuple(av)
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutArrayAll)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutArrayAll`: a dispatch for preparing TEM for using preallocated array to output ALL LAND VARIABLES
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem_helpers::NamedTuple, ::LandOutArrayAll)

    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);

    ## run the model for one time step
    @info "     model run for one location and time step"
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    loc_forcing = getLocForcingData(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)

    debugModel(loc_land, tem_helpers.run.debug_model)

    info = setAllLandOutput(info, loc_land)

    tem_info = @set tem_info.vals.output_vars = Val(info.output.variables)
    output_dims, output_array = getOutDimsArrays(info, forcing.helpers)

    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    space_forcing = map([space_ind...]) do lsi
        getLocForcingData(forcing_nt_array, lsi)
    end
    space_spinup_forcing = map(space_forcing) do loc_forcing
        getAllSpinupForcing(loc_forcing, info.spinup.sequence, tem_info);
    end

    space_output = map([space_ind...]) do lsi
        getLocOutputData(output_array, lsi)
    end

    space_land = Tuple([deepcopy(loc_land) for _ ∈ 1:length(space_ind)])

    forcing_nt_array = nothing

    run_helpers = (; space_forcing, space_ind, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, loc_land, output_dims, output_vars=info.output.variables, tem_info)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutArray)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutArray`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem_helpers::NamedTuple, ::LandOutArray)

    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);


    ## run the model for one time step
    @info "     model run for one location and time step"
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    land_init = output.land_init
    loc_forcing = getLocForcingData(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)

    debugModel(loc_land, tem_helpers.run.debug_model)

    output_array = output.data
    output_vars = output.variables
    output_dims = output.dims

    # collect local data and create copies
    @info "     preallocating local, threaded, and spatial data"
    space_forcing = map([space_ind...]) do lsi
        getLocForcingData(forcing_nt_array, lsi)
    end
    space_spinup_forcing = map(space_forcing) do loc_forcing
        getAllSpinupForcing(loc_forcing, info.spinup.sequence, tem_info);
    end

    space_output = map([space_ind...]) do lsi
        getLocOutputData(output_array, lsi)
    end

    space_land = Tuple([deepcopy(loc_land) for _ ∈ 1:length(space_ind)])

    forcing_nt_array = nothing

    run_helpers = (; space_forcing, space_ind, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, loc_land, output_dims, output_vars, tem_info)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutStacked)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutStacked`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem_helpers::NamedTuple, ::LandOutStacked)
    
    # get the output things
    @info "     preparing spatial and tem helpers"
    space_ind = getSpatialInfo(forcing)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);

    ## run the model for one time step
    @info "     model run for one location and time step"
    land_init = output.land_init
    forcing_nt_array = makeNamedTuple(forcing.data, forcing.variables)
    loc_forcing = getLocForcingData(forcing_nt_array, space_ind[1])
    loc_forcing_t, loc_land = runTEMOne(selected_models, loc_forcing, land_init, tem_info)
    debugModel(loc_land, tem_helpers.run.debug_model)

    output_vars = output.variables
    output_dims = output.dims

    run_helpers = (; loc_forcing, loc_forcing_t, loc_land, space_ind, output_dims, output_vars, tem_info)
    return run_helpers
end


"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutTimeseries)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutTimeseries`: a dispatch for preparing TEM for using preallocated array
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem_helpers::NamedTuple, ::LandOutTimeseries)
    run_helpers = helpPrepTEM(selected_models, info, forcing, output, tem_helpers, LandOutStacked())
    land_timeseries = Vector{typeof(run_helpers.loc_land)}(undef, tem_helpers.dates.size)
    run_helpers = setTupleField(run_helpers, (:land_timeseries, land_timeseries))
    return run_helpers
end



"""
    helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple, ::LandOutYAXArray)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::LandOutYAXArray`: a dispatch for preparing TEM for using yax array for model output
"""
function helpPrepTEM(selected_models, info, forcing::NamedTuple, output::NamedTuple, tem_helpers::NamedTuple, ::LandOutYAXArray)

    # generate vals for dispatch of forcing and output
    tem_info = getRunTemInfo(info, forcing);

    loc_land = output.land_init
    output_vars = output.variables
    output_dims = output.dims

    run_helpers = (; loc_land, output_vars, output_dims, tem_info)
    return run_helpers
end

"""
    prepTEM(forcing::NamedTuple, info::NamedTuple)



- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
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
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
function prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run terrestrial ecosystem model (TEM)"
    tem_helpers = info.helpers
    output = prepTEMOut(info, forcing.helpers)
    @info "  helpPrepTEM: preparing helpers for running model experiment"
    run_helpers = helpPrepTEM(selected_models, info, forcing, output, tem_helpers, tem_helpers.run.land_output_type)
    @info "\n----------------------------------------------\n"
    return run_helpers
end

"""
    prepTEM(selected_models, forcing::NamedTuple, observations, info::NamedTuple)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
function prepTEM(selected_models, forcing::NamedTuple, observations::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run terrestrial ecosystem model (TEM)"
    tem_helpers = info.helpers
    output = prepTEMOut(info, forcing.helpers)
    run_helpers = helpPrepTEM(selected_models, info, forcing, observations, output, tem_helpers, tem_helpers.run.land_output_type)
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
    loc_land = computeTEM(selected_models, loc_forcing_t, loc_land, tem.model_helpers)
    loc_land = removeEmptyTupleFields(loc_land)
    loc_land = addSpinupLog(loc_land, tem.spinup_sequence, tem.run.store_spinup)
    # loc_land = definePrecomputeTEM(selected_models, loc_forcing_t, loc_land,
        # tem.model_helpers)
    loc_land = precomputeTEM(selected_models, loc_forcing_t, loc_land,
        tem.model_helpers)
    loc_land = computeTEM(selected_models, loc_forcing_t, loc_land, tem.model_helpers)
    return loc_forcing_t, loc_land
end

function setAllLandOutput(info, land)
    output_vars = getAllLandVars(land)
    depth_info = map(output_vars) do v_full_pair
        v_index = findfirst(x -> first(x) === first(v_full_pair) && last(x) === last(v_full_pair), info.output.variables)
        dim_name = nothing
        dim_size = nothing
        if ~isnothing(v_index)
            dim_name = last(info.output.depth_info[v_index])
            dim_size = first(info.output.depth_info[v_index])
        else
            field_name = first(v_full_pair)
            v_name = last(v_full_pair)
            dim_name = string(v_name) * "_idx"
            land_field = getproperty(land, field_name)
            if hasproperty(land_field, v_name)
                land_subfield = getproperty(land_field, v_name)
                if isa(land_subfield, AbstractArray)
                    dim_size = length(land_subfield)
                elseif isa(land_subfield, Number)
                    dim_size = 1
                else
                    dim_size = 0
                end
            end
        end
        dim_size, dim_name
    end
    info = @set info.output.variables = output_vars
    info = @set info.output.depth_info = depth_info
    return info
end