export getForcingForTimeStep
export getForcingNamedTuple
# export getForcingTimeSize
export getLocData
export getLocForcingData
export getLocOutputData
export getLocForcing!
export getLocOutput!
export getNumberOfTimeSteps

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
    getForcingForTimeStep(forcing, forcing_t, ts, Val{forc_vars})



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_t`: DESCRIPTION
- `ts`: DESCRIPTION
- `nothing`: DESCRIPTION
"""

@generated function getForcingForTimeStep(forcing, forcing_t, ts, ::Val{forc_with_type}) where {forc_with_type}
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
end

"""
    getForcingForTimeStep(forcing::NamedTuple, forcing_t, ts::Int64)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_t`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getForcingForTimeStep(forcing::NamedTuple, forcing_t, ts::Int64)
    for f ∈ keys(forcing)
        v = forcing[f]
        # forcing_t = @set forcing_t[f] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
        dv = v[ts]
        forcing_t = @set forcing_t[f] = dv
    end
    return forcing_t
end

"""
    getForcingForTimeStep(forcing::NamedTuple, ts::Int64)


"""
function getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        v[ts]
    end
end

function getForcingV(v,ts,::ForcingWithTime)
    v[ts]
end

function getForcingV(v,_,::ForcingWithoutTime)
    v[1]
end

"""
    getForcingNamedTuple(input_data, forcing_names)


"""
function getForcingNamedTuple(input_data, forcing_names)
    return (; Pair.(forcing_names, input_data)...)
end



# """
#     getForcingTimeSize(forcing::NamedTuple)


# """
# function getForcingTimeSize(forcing::NamedTuple)
#     forcingTimeSize = 1
#     for v ∈ forcing
#         if in(:time, AxisKeys.dimnames(v))
#             forcingTimeSize = size(v, 1)
#         end
#     end
#     return forcingTimeSize
# end

# """
#     getForcingTimeSize(forcing, Val{forc_vars})


# """
# @generated function getForcingTimeSize(forcing, ::Val{forc_vars}) where {forc_vars}
#     output = quote
#         forcingTimeSize = 1
#     end
#     foreach(forc_vars) do forc
#         push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
#         push!(output.args,
#             quote
#                 forcingTimeSize = in(:time, AxisKeys.dimnames(v)) ? size(v, 1) :
#                                   forcingTimeSize
#             end)
#     end
#     push!(output.args, quote
#         forcingTimeSize
#     end)
#     return output
# end


"""
    getForcingV(v::keyedArray, ts::Int64)


"""
function getForcingV(v::KeyedArray, ts::Int64)
    in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : Array(v)
end


"""
    getForcingV(v::Array, ts::Int64)


"""
function getForcingV(v::Array, ts::Int64)
    v[ts]
end

"""
    getLocData(forcing, output_array, loc_space_map)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `loc_space_map`: DESCRIPTION
"""
function getLocData(forcing, output_array, loc_space_map)
    loc_forcing = getLocForcingData(forcing, loc_space_map)
    loc_output = getLocOutputData(output_array, loc_space_map)
    return loc_forcing, loc_output
end


"""
    getLocForcingData(forcing, output_array, loc_space_map)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_space_map`: DESCRIPTION
"""
function getLocForcingData(forcing, loc_space_map)
    loc_forcing = map(forcing) do a
        d_o = view(a; loc_space_map...)
        if :time ∉ dimnames(d_o)
            d_o = Array(d_o)
        end
        d_o
    end
    return loc_forcing
end


"""
    getLocForcingData(forcing, output_array, loc_space_map)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_space_ind`: DESCRIPTION
"""
function getLocForcingData(forcing, loc_space_ind, num_timesteps)
    loc_forcing = map(forcing) do a
        d_o_a = getArrayView(Array(a), loc_space_ind)
        if :time ∉ dimnames(a)
            d_o_a = fill(d_o_a, num_timesteps)
        end
        d_o_a
    end
    return loc_forcing
end
"""
    getLocOutputData(forcing, output_array, loc_space_map)



# Arguments:
- `output_array`: an output array/view for ALL locations
- `loc_space_map`: DESCRIPTION
"""
function getLocOutputData(output_array, loc_space_map)
    ar_inds = Tuple(last.(loc_space_map))
    loc_output = map(output_array) do a
        getArrayView(a, ar_inds)
    end
    return loc_output
end

"""
    getLocForcing!(forcing, loc_forcing, loc_space_ind, Val{forc_vars}, Val{s_names})



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing`: a forcing time series set for a single location
- `loc_space_ind`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
@generated function getLocForcing!(
    forcing,
    loc_forcing,
    loc_space_ind,
    ::Val{forc_vars},
    ::Val{s_names}) where {forc_vars,s_names}
    output = quote end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :d, Expr(:., :forcing, QuoteNode(forc))))
        s_ind = 1
        foreach(s_names) do s_name
            expr = Expr(:(=),
                :d,
                Expr(:call,
                    :view,
                    Expr(:parameters,
                        Expr(:call, :(=>), QuoteNode(s_name), Expr(:ref, :loc_space_ind, s_ind))),
                    :d))
            push!(output.args, expr)
            s_ind += 1
        end
        push!(output.args,
            Expr(:(=),
                :loc_forcing,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :loc_forcing, QuoteNode(forc)), :d)))) #= none:1 =#
    end
    return output
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
