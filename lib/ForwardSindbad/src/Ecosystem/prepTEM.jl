export prepTEM

"""
    addSpinupLog(land, seq, nothing::Val{true})

DOCSTRING

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `seq`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function addSpinupLog(land, seq, ::Val{true}) # when history is true
    n_repeat = 1
    for _seq in seq
        n_repeat = n_repeat + _seq["n_repeat"]
    end
    spinuplog = Vector{typeof(land.pools)}(undef, n_repeat)
    @pack_land spinuplog => land.states
    return land
end

"""
    addSpinupLog(land, _, nothing::Val{false})

DOCSTRING

# Arguments:
- `land`: sindbad land
- `::Val{false}`: indicates not to store the spinup history
"""
function addSpinupLog(land, _, ::Val{false}) # when history is false
    spinuplog = nothing
    @pack_land spinuplog => land.states
    return land
end

"""
    debugModel(land_one, nothing::Val{:(true)})

DOCSTRING
"""
function debugModel(land_one, ::Val{:true}) # print land when debug model is true/on
    Sindbad.eval(:(error_catcher = []))
    push!(Sindbad.error_catcher, land_one)
    tcPrint(land_one)
    return nothing
end


"""
    debugModel(_, nothing::Val{:(false)})

DOCSTRING
"""
function debugModel(_, ::Val{:false}) # do nothing debug model is false/off
    return nothing
end

"""
    runOneLocation(selected_models, forcing, output_array::AbstractArray, land_init, loc_space_map, tem)

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `land_init`: initial SINDBAD land with all fields and subfields
- `loc_space_map`: DESCRIPTION
- `tem`: DESCRIPTION
"""
function runOneLocation(selected_models, forcing, output_array::AbstractArray, land_init, loc_space_map, tem)
    loc_forcing, loc_output = getLocData(forcing, output_array, loc_space_map)
    forcing_one_timestep = getForcingForTimeStep(loc_forcing, 1)
    land_prec = definePrecomputeTEM(selected_models, forcing_one_timestep, land_init,
        tem.helpers)
    land_one = computeTEM(selected_models, forcing_one_timestep, land_prec, tem.helpers)
    setOutputForTimeStep!(loc_output, land_one, 1, tem.helpers.vals.output_vars)
    debugModel(land_one, tem.helpers.run.debug_model)
    return forcing_one_timestep, land_one
end

"""
prepTEM(output, forcing::NamedTuple, tem::NamedTuple)
"""

"""
    prepTEM(forcing::NamedTuple, info::NamedTuple)

DOCSTRING
"""
function prepTEM(forcing::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run terrestrial ecosystem model (TEM)"
    selected_models = info.tem.models.forward
    tem_helpers = info.tem.helpers
    # get the output named tuple
    output = setupOutput(info, forcing.helpers)
    return helpPrepTEM(selected_models, forcing, output, info.tem, tem_helpers)
end

"""
prepTEM(output, selected_models, forcing::NamedTuple, tem::NamedTuple)
"""

"""
    prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
function prepTEM(selected_models, forcing::NamedTuple, info::NamedTuple)
    @info "prepTEM: preparing to run ecosystem"
    tem_helpers = info.tem.helpers
    output = setupOutput(info, forcing.helpers)
    return helpPrepTEM(selected_models, forcing, output, info.tem, tem_helpers)
end

"""
helpPrepTEM(output, forcing::NamedTuple, tem::NamedTuple)
"""

"""
    helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple)

DOCSTRING

# Arguments:
- `selected_models`: a tuple of models selected for the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: DESCRIPTION
- `tem`: DESCRIPTION
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function helpPrepTEM(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple)
    # generate vals for dispatch of forcing and output
    @info "     getting the space locations to loop"
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
    loc_space_names = Tuple(first.(loc_space_maps[1]))
    loc_space_inds = Tuple([Tuple(last.(loc_space_map)) for loc_space_map ∈ loc_space_maps])

    forcing_nt_array = getKeyedArrayWithNames(forcing)

    # get the output things
    variables = output.variables
    land_init = output.land_init
    output_array = output.data

    @info "     preparing vals for dispatch"
    vals = (; forc_vars=Val(keys(forcing_nt_array)), loc_space_names=Val(loc_space_names), output_vars=Val(variables))
    tem_dates = tem_helpers.dates
    tem_dates = (; timesteps_in_day=tem_dates.timesteps_in_day, timesteps_in_year=tem_dates.timesteps_in_year)
    tem_helpers = setTupleField(tem_helpers, (:dates, tem_dates))
    tem_numbers = tem_helpers.numbers
    tem_numbers = (; tolerance=tem_numbers.tolerance)
    # tem_numbers = (; 𝟘=tem_numbers.𝟘, 𝟙=tem_numbers.𝟙, tolerance=tem_numbers.tolerance)
    tem_helpers = setTupleField(tem_helpers, (:vals, vals))
    tem_helpers = setTupleField(tem_helpers, (:numbers, tem_numbers))
    new_tem = setTupleField(tem, (:helpers, tem_helpers))

    #@show loc_space_maps
    allNans = Bool[]
    for i ∈ eachindex(loc_space_maps)
        loc_forcing, _ = getLocData(forcing_nt_array, output_array, loc_space_maps[i]) #312
        push!(allNans, all(isnan, loc_forcing[1]))
    end

    @info "     producing model output with one location and one time step for preallocating local, threaded, and spatial data"
    loc_forcing, loc_output = getLocData(forcing_nt_array, output_array, loc_space_maps[1]) #312
    loc_space_maps = loc_space_maps[allNans.==false]
    forcing_one_timestep, land_one = runOneLocation(selected_models, forcing_nt_array, output_array, land_init,
        loc_space_maps[1], new_tem)
    land_one = addSpinupLog(land_one, new_tem.spinup.sequence, new_tem.helpers.run.spinup.store_spinup)

    loc_forcings = Tuple([loc_forcing for _ ∈ 1:Threads.nthreads()])
    loc_outputs = Tuple([loc_output for _ ∈ 1:Threads.nthreads()])
    land_one = removeEmptyTupleFields(land_one)
    land_init_space = Tuple([deepcopy(land_one) for _ ∈ 1:length(loc_space_maps)])
    println("----------------------------------------------")

    return forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    loc_space_maps,
    loc_space_names,
    new_tem
end
