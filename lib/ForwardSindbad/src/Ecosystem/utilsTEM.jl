export getLocData
export getLocForcing!
export getLocOutput!
export setOutputForTimeStep!

"""
    fillLocOutput!(ar, val, ts::Int64)

DOCSTRING

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
    getLocData(forcing, output_array, loc_space_map)

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `loc_space_map`: DESCRIPTION
"""
function getLocData(forcing, output_array, loc_space_map)
    loc_forcing = map(forcing) do a
        view(a; loc_space_map...)
    end
    # ar_inds = last.(loc_space_map)
    ar_inds = Tuple(last.(loc_space_map))

    loc_output = map(output_array) do a
        getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output
end

"""
    getLocForcing!(forcing, loc_forcing, s_locs, nothing::Val{forc_vars}, nothing::Val{s_names})

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing`: a forcing time series set for a single location
- `s_locs`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
@generated function getLocForcing!(
    forcing,
    loc_forcing,
    s_locs,
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
                        Expr(:call, :(=>), QuoteNode(s_name), Expr(:ref, :s_locs, s_ind))),
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

DOCSTRING

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
    getLocOutputView(ar, val::AbstractVector, ts::Int64)

DOCSTRING

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

DOCSTRING

# Arguments:
- `ar`: DESCRIPTION
- `val`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getLocOutputView(ar, val::Real, ts::Int64)
    return view(ar, ts)
end

"""
    setOutputForTimeStep!(outputs, land, ts, nothing::Val{output_vars})

DOCSTRING

# Arguments:
- `outputs`: DESCRIPTION
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `ts`: DESCRIPTION
- `nothing`: DESCRIPTION
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


"""
    viewCopyYax(xout, xin)

DOCSTRING

# Arguments:
- `xout`: DESCRIPTION
- `xin`: DESCRIPTION
"""
function viewCopyYax(xout, xin)
    if ndims(xout) == ndims(xin)
        for i ∈ eachindex(xin)
            xout[i] = xin[i][1]
        end
    else
        for i ∈ CartesianIndices(xin)
            xout[:, i] .= xin[i]
        end
    end
end