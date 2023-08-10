export getForcingTimeSize
export getForcingForTimeStep
export getKeyedArray
export getKeyedArrayWithNames
export getNamedDimsArrayWithNames
export getNumberOfTimeSteps

"""
getKeyedArray(input::NamedTuple)
"""

"""
    getArray(input)

DOCSTRING
"""
function getArray(input)
    arrayData = map(input.data) do c
        Array(c.data)
    end
    return arrayData
end


"""
getNamedDimsArrayWithNames(input::NamedTuple)
"""

"""
    getNamedDimsArrayWithNames(input)

DOCSTRING
"""
function getNamedDimsArrayWithNames(input)
    ks = input.variables
    keyedData = map(input.data) do c
        t_dims = getSindbadDims(c)
        NamedDimsArray(Array(c.data); t_dims...)
    end
    return (; Pair.(ks, keyedData)...)
end


"""
getKeyedArrayWithNames(input::NamedTuple)
"""

"""
    getKeyedArrayWithNames(input)

DOCSTRING
"""
function getKeyedArrayWithNames(input)
    ks = input.variables
    keyedData = getKeyedArray(input)
    return (; Pair.(ks, keyedData)...)
end


"""
getKeyedArray(input::NamedTuple)
"""

"""
    getKeyedArray(input)

DOCSTRING
"""
function getKeyedArray(input)
    keyedData = map(input.data) do c
        t_dims = getSindbadDims(c)
        KeyedArray(Array(c.data); t_dims...)
    end
    return keyedData
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
getSindbadDims(c)
prepare the dimensions of data and name them appropriately for use in internal SINDBAD functions
"""

"""
    getSindbadDims(c)

DOCSTRING
"""
function getSindbadDims(c)
    dimnames = DimensionalData.name(dims(c))
    act_dimnames = []
    foreach(dimnames) do dimn
        td = dimn
        if dimn in (:Ti, :Time, :TIME, :t, :T, :TI)
            td = :time
        end
        push!(act_dimnames, td)
    end
    return [act_dimnames[k] => getproperty(c, dimnames[k]) |> Array for k ∈ eachindex(dimnames)]
end