export getForcingTimeSize
export getForcingForTimeStep
export getLocData
export getLocForcing!
export getLocOutput!
export getNumberOfTimeSteps
export landWrapper
export setOutputForTimeStep!
export viewCopyYax

"""
    landWrapper{S}

Wrap the nested fields of namedtuple output of sindbad land into a nested structure of views that can be easily accessed with a dot notation
"""
struct landWrapper{S}
    s::S
end
struct GroupView{S}
    groupname::Symbol
    s::S
end
struct ArrayView{T,N,S<:AbstractArray{<:Any,N}} <: AbstractArray{T,N}
    s::S
    groupname::Symbol
    arrayname::Symbol
end
Base.getproperty(s::landWrapper, aggr_func::Symbol) = GroupView(aggr_func, getfield(s, :s))
"""
    Base.getproperty(g::GroupView, aggr_func::Symbol)

DOCSTRING
"""
function Base.getproperty(g::GroupView, aggr_func::Symbol)
    allarrays = getfield(g, :s)
    groupname = getfield(g, :groupname)
    T = typeof(first(allarrays)[groupname][aggr_func])
    return ArrayView{T,ndims(allarrays),typeof(allarrays)}(allarrays, groupname, aggr_func)
end
Base.size(a::ArrayView) = size(a.s)
Base.IndexStyle(a::Type{<:ArrayView}) = IndexLinear()
Base.getindex(a::ArrayView, i::Int) = a.s[i][a.groupname][a.arrayname]
Base.propertynames(o::landWrapper) = propertynames(first(getfield(o, :s)))
Base.keys(o::landWrapper) = propertynames(o)
Base.getindex(o::landWrapper, s::Symbol) = getproperty(o, s)

"""
    Base.propertynames(o::GroupView)

DOCSTRING
"""
function Base.propertynames(o::GroupView)
    return propertynames(first(getfield(o, :s))[getfield(o, :groupname)])
end
Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView, i::Symbol) = getproperty(o, i)




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
    getForcingTimeSize(forcing::NamedTuple)

DOCSTRING
"""
function getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v ∈ forcing
        if in(:time, AxisKeys.dimnames(v))
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

"""
    getForcingTimeSize(forcing, Val{forc_vars})

DOCSTRING
"""
@generated function getForcingTimeSize(forcing, ::Val{forc_vars}) where {forc_vars}
    output = quote
        forcingTimeSize = 1
    end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
        push!(output.args,
            quote
                forcingTimeSize = in(:time, AxisKeys.dimnames(v)) ? size(v, 1) :
                                  forcingTimeSize
            end)
    end
    push!(output.args, quote
        forcingTimeSize
    end)
    return output
end

"""
    getForcingForTimeStep(forcing, f_t, ts, Val{forc_vars})

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `f_t`: DESCRIPTION
- `ts`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
@generated function getForcingForTimeStep(forcing, f_t, ts, ::Val{forc_vars}) where {forc_vars}
    output = quote end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
        push!(output.args, quote
            d = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
        end)
        push!(output.args,
            Expr(:(=),
                :f_t,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))) #= none:1 =#
    end
    return output
end

"""
    getForcingForTimeStep(forcing::NamedTuple, forcing_t, ts::Int64)

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_t`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getForcingForTimeStep(forcing::NamedTuple, forcing_t, ts::Int64)
    for f ∈ keys(forcing)
        v = forcing[f]
        forcing_t = @set forcing_t[f] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
    return forcing_t
end

"""
    getForcingForTimeStep(forcing::NamedTuple, ts::Int64)

DOCSTRING
"""
function getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
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
    getLocForcing!(forcing, loc_forcing, s_locs, Val{forc_vars}, Val{s_names})

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
    getNumberOfTimeSteps(incubes, time_name)

DOCSTRING
"""
function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    return length(getAxis(time_name, incubes[i1]).values)
end


"""
    setOutputForTimeStep!(outputs, land, ts, Val{output_vars})

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