export getForcingForTimeStep
export getLocData
export getLocForcingData
export getLocOutputData
export getLocForcing!
export getLocOutput!
export getNumberOfTimeSteps
export setOutputForTimeStep!

"""
    fillLocOutput!(ar, val, ts::Int64)



# Arguments:
- `ar`: DESCRIPTION
- `val`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function fillLocOutput!(ar, val, ts::Int64)
    data_ts = getLocOutputView(ar, val, ts)
    return data_ts .= val
end


"""
    getForcingForTimeStep(forcing, forcing_t, ts, Val{forc_with_type})



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_t`: a forcing NT for a single timestep to be reused in every time step
- `ts`: time step to get the forcing for
- `::Val{forc_with_type`: a val dispatch with forcing names and types to generate the code for getting forcing
"""

function getForcingForTimeStep(forcing, forcing_t, ts, ::Val{forc_with_type}) where {forc_with_type}
    if @generated
        output = quote end
        foreach(forc_with_type) do forc_pair
            forc = first(forc_pair)
            forc_type=last(forc_pair)
            push!(output.args, Expr(:(=), :d, Expr(:call, :getForcingV, Expr(:., :forcing, QuoteNode(forc)), :ts, forc_type)))
            push!(output.args,
                Expr(:(=),
                    :forcing_t,
                    Expr(:macrocall,
                        Symbol("@set"),
                        :(),
                        Expr(:(=), Expr(:., :forcing_t, QuoteNode(forc)), :d)))) #= none:1 =#
        end
        return output
    else
        map(forc_with_type) do forc_pair
            forc = first(forc_pair)
            forc_type=last(forc_pair)
            getForcingV(forcing[forc], ts, forc_type)
        end
    end
end


function getForcingV(v, ts, ::ForcingWithTime)
    v[ts]
end

function getForcingV(v, _, ::ForcingWithoutTime)
    v
end

"""
    getLocData(forcing, output_array, loc_space_ind)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `loc_space_ind`: a tuple with the spatial indices of the data for a gievn location
"""
function getLocData(forcing, output_array, loc_space_ind)
    loc_forcing = getLocForcingData(forcing, loc_space_ind)
    loc_output = getLocOutputData(output_array, loc_space_ind)
    return loc_forcing, loc_output
end

"""
    getLocForcingData(forcing, output_array, loc_space_ind)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_space_ind`: a tuple with the spatial indices of the data for a gievn location
"""
function getLocForcingData(forcing, loc_space_ind)
    loc_forcing = map(forcing) do a
        getArrayView(Array(a), loc_space_ind)
    end
    return loc_forcing
end

"""
    getLocOutputData(forcing, output_array, loc_space_ind)



# Arguments:
- `output_array`: an output array/view for ALL locations
- `loc_space_ind`: a tuple with the spatial indices of the data for a gievn location
"""
function getLocOutputData(output_array, loc_space_ind)
    loc_output = map(output_array) do a
        getArrayView(a, loc_space_ind)
    end
    return loc_output
end

"""
    getLocOutput!(output_array, loc_output, ar_inds)



# Arguments:
- `output_array`: an output array/view for ALL locations
- `loc_output`: an output array/view for a single location
- `ar_inds`: DESCRIPTION
"""
function getLocOutput!(output_array, loc_output, ar_inds)
    for i ∈ eachindex(output_array)
        loc_output[i] = getArrayView(output_array[i], ar_inds)
    end
    return nothing
end

"""
    getLocOutput!(output_array, loc_output, ar_inds)



# Arguments:
- `output_array`: an output array/view for ALL locations
- `ar_inds`: DESCRIPTION
"""
function getLocOutput!(output_array, ar_inds)
    loc_output = map(output_array) do a
        getArrayView(a, ar_inds)
    end
    return loc_output
end



"""
    getLocOutputView(ar, val::AbstractVector, ts::Int64)



# Arguments:
- `ar`: DESCRIPTION
- `val`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getLocOutputView(ar, val::AbstractVector, ts::Int64)
    return view(ar, ts, 1:length(val))
end

"""
    getLocOutputView(ar, val::Real, ts::Int64)



# Arguments:
- `ar`: DESCRIPTION
- `val`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getLocOutputView(ar, val::Real, ts::Int64)
    return view(ar, ts)
end


"""
    getNumberOfTimeSteps(incubes, time_name)


"""
function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    return length(getAxis(time_name, incubes[i1]).values)
end


"""
    setOutputForTimeStep!(outputs, land, ts, Val{output_vars})



# Arguments:
- `outputs`: vector of model output vectors
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `ts`: time step
- `::Val{output_vars}`: a dispatch for vals of the output variables to generate the function
"""
function setOutputForTimeStep!(outputs, land, ts, ::Val{output_vars}) where {output_vars}
    if @generated
        output = quote end
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            push!(output.args,
                Expr(:(=), :data_l, Expr(:., Expr(:., :land, QuoteNode(field)), QuoteNode(subfield))))
            push!(output.args, quote
                data_o = outputs[$i]
                fillLocOutput!(data_o, data_l, ts)
            end)
        end
        return output
    else
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            data_l = getfield(getfield(land, field), subfield)
            data_o = outputs[i]
            fillLocOutput!(data_o, data_l, ts)
        end
    end
end
