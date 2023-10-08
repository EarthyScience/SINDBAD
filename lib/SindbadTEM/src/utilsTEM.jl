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
function fillLocOutput!(ar::T, val::T1, ts::T2) where {T, T1, T2<:Int}
    data_ts = getLocOutputView(ar, val, ts)
    return data_ts .= val
end


"""
    getForcingForTimeStep(forcing, loc_forcing_t, ts, Val{forc_with_type})



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single timestep to be reused in every time step
- `ts`: time step to get the forcing for
- `::Val{forc_with_type`: a val dispatch with forcing names and types to generate the code for getting forcing
"""

function getForcingForTimeStep(forcing, loc_forcing_t, ts, ::Val{forc_with_type}) where {forc_with_type}
    if @generated
        gen_output = quote end
        foreach(forc_with_type) do forc_pair
            forc = first(forc_pair)
            forc_type=last(forc_pair)
            push!(gen_output.args, Expr(:(=), :d, Expr(:call, :getForcingV, Expr(:., :forcing, QuoteNode(forc)), :ts, forc_type)))
            push!(gen_output.args,
                Expr(:(=),
                    :loc_forcing_t,
                    Expr(:macrocall,
                        Symbol("@set"),
                        :(),
                        Expr(:(=), Expr(:., :loc_forcing_t, QuoteNode(forc)), :d)))) #= none:1 =#
        end
        return gen_output
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
    getLocData(forcing, output_array, loc_ind)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `loc_ind`: a tuple with the spatial indices of the data for a given location
"""
function getLocData(forcing, output_array, loc_ind)
    loc_forcing = getLocForcingData(forcing, loc_ind)
    loc_output = getLocOutputData(output_array, loc_ind)
    return loc_forcing, loc_output
end

"""
    getLocForcingData(forcing, output_array, loc_ind)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_ind`: a tuple with the spatial indices of the data for a given location
"""
function getLocForcingData(forcing, loc_ind)
    loc_forcing = map(forcing) do a
        getArrayView(Array(a), loc_ind)
    end
    return loc_forcing
end

"""
    getLocOutputData(forcing, output_array, loc_ind)



# Arguments:
- `output_array`: an output array/view for ALL locations
- `loc_ind`: a tuple with the spatial indices of the data for a given location
"""
function getLocOutputData(output_array, loc_ind)
    loc_output = map(output_array) do a
        getArrayView(a, loc_ind)
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
function getLocOutputView(ar::T, val::T1, ts::T2) where {T, T1<:AbstractVector, T2<:Int}
    return view(ar, ts, 1:size(val,1))
end

"""
    getLocOutputView(ar, val::Real, ts::Int64)



# Arguments:
- `ar`: DESCRIPTION
- `val`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getLocOutputView(ar::T, val::T1, ts::T2) where {T, T1<:Real, T2<:Int}
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
        gen_output = quote end
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            push!(gen_output.args,
                Expr(:(=), :data_l, Expr(:., Expr(:., :land, QuoteNode(field)), QuoteNode(subfield))))
            push!(gen_output.args, quote
                data_o = outputs[$i]
                fillLocOutput!(data_o, data_l, ts)
            end)
        end
        return gen_output
    else
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            data_l = getfield(getfield(land, field), subfield)
            data_o = outputs[i]
            fillLocOutput!(data_o, data_l, ts)
        end
        return nothing
    end
end
