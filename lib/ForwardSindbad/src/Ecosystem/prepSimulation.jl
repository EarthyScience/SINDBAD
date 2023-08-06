export prepSimulation

function addSpinupLog(land, seq, ::Val{true}) # when history is true
    n_repeat = 1
    for _seq in seq
        n_repeat = n_repeat + _seq["n_repeat"]
    end
    spinuplog = Vector{typeof(land.pools)}(undef, n_repeat)
    @pack_land spinuplog => land.states
    return land
end

function addSpinupLog(land, _, ::Val{false}) # when history is false
    spinuplog = nothing
    @pack_land spinuplog => land.states
    return land
end

function debugModel(land_one, ::Val{:true}) # print land when debug model is true/on
    Sindbad.eval(:(error_catcher = []))
    push!(Sindbad.error_catcher, land_one)
    tcPrint(land_one)
    return nothing
end


function debugModel(_, ::Val{:false}) # do nothing debug model is false/off
    return nothing
end

function simulateOneLocation(output_array::AbstractArray, land_init, selected_models, forcing, tem, loc_space_map)
    loc_forcing, loc_output = getLocData(output_array, forcing, loc_space_map)
    land_prec = runDefinePrecompute(land_init, getForcingForTimeStep(loc_forcing, 1), selected_models,
        tem.helpers)
    f_one = getForcingForTimeStep(loc_forcing, 1)
    land_one = runCompute(land_prec, f_one, selected_models, tem.helpers)
    setOutputForTimeStep!(loc_output, land_one, tem.helpers.vals.output_vars, 1)
    debugModel(land_one, tem.helpers.run.debug_model)
    return land_one, f_one
end

"""
prepSimulation(output, forcing::NamedTuple, tem::NamedTuple)
"""
function prepSimulation(forcing::NamedTuple, info::NamedTuple)
    @info "prepSimulation: preparing to run ecosystem"
    selected_models = info.tem.models.forward
    tem_helpers = info.tem.helpers
    # get the output named tuple
    output = setupOutput(info, forcing.helpers)
    return helpPrepSimulation(selected_models, forcing, output, info.tem, tem_helpers)
end

"""
prepSimulation(output, selected_models, forcing::NamedTuple, tem::NamedTuple)
"""
function prepSimulation(selected_models, forcing::NamedTuple, info::NamedTuple)
    @info "prepSimulation: preparing to run ecosystem"
    tem_helpers = info.tem.helpers
    output = setupOutput(info, forcing.helpers)
    return helpPrepSimulation(selected_models, forcing, output, info.tem, tem_helpers)
end

"""
helpPrepSimulation(output, forcing::NamedTuple, tem::NamedTuple)
"""
function helpPrepSimulation(selected_models, forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, tem_helpers::NamedTuple)
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
        loc_forcing, _ = getLocData(output_array, forcing_nt_array, loc_space_maps[i]) #312
        push!(allNans, all(isnan, loc_forcing[1]))
    end

    @info "     producing model output with one location and one time step for preallocating local, threaded, and spatial data"
    loc_forcing, loc_output = getLocData(output_array, forcing_nt_array, loc_space_maps[1]) #312
    loc_space_maps = loc_space_maps[allNans.==false]
    land_one, f_one = simulateOneLocation(output_array, land_init, selected_models, forcing_nt_array, new_tem,
        loc_space_maps[1])
    land_one = addSpinupLog(land_one, new_tem.spinup.sequence, new_tem.helpers.run.spinup.store_spinup_history)

    loc_forcings = Tuple([loc_forcing for _ ∈ 1:Threads.nthreads()])
    loc_outputs = Tuple([loc_output for _ ∈ 1:Threads.nthreads()])
    land_one = removeEmptyTupleFields(land_one)
    land_init_space = Tuple([deepcopy(land_one) for _ ∈ 1:length(loc_space_maps)])
    println("----------------------------------------------")

    return forcing_nt_array,
    output_array,
    loc_space_maps,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    new_tem,
    f_one
end
