export getDataDims, getNumberOfTimeSteps, cleanInputData, getAbsDataPath
export AllNaN
export getForcingTimeSize
export getForcingForTimeStep
export filterVariables
export getKeyedArrayFromYaxArray
export getNamedDimsArrayFromYaxArray
export getDimArrayFromYaxArray
export getObsKeyedArrayFromYaxArray

"""
    AllNaN <: YAXArrays.DAT.ProcFilter

Add skipping filter for pixels with all nans in YAXArrays
"""
struct AllNaN <: YAXArrays.DAT.ProcFilter end
YAXArrays.DAT.checkskip(::AllNaN, x) = all(isnan, x)



function mapCleanInputData(yax, dfill, vinfo, ::Val{T}) where {T}
    yax = map(x -> ismissing(x) ? dfill : x, yax)
    yax = map(x -> isnan(x) ? dfill : x, yax)
    yax = map(x -> applyUnitConversion(x, vinfo.source_to_sindbad_unit,
    vinfo.additive_unit_conversion), yax)
    bounds = vinfo.bounds
    if !isnothing(bounds)
        yax = map(x -> clamp(x, first(bounds), last(bounds)), yax)
    end
    return T.(yax)
end


function getAbsDataPath(info, data_path)
    if !isabspath(data_path)
        data_path = joinpath(info.experiment_root, data_path)
    end
    return data_path
end

function getDataDims(c, mappinginfo)
    inax = [] # String[]
    axnames = DimensionalData.name(dims(c)) #YAXArrays.Axes.axname.(caxes(c))
    inollt = findall(∉(mappinginfo), axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    return InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    return length(getAxis(time_name, incubes[i1]).values)
end

function getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v ∈ forcing
        if in(:time, AxisKeys.dimnames(v))
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

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

@generated function getForcingForTimeStep(forcing, ::Val{forc_vars}, ts, f_t) where {forc_vars}
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

function getForcingForTimeStep(forcing::NamedTuple, ts::Int64, forcing_t)
    for f ∈ keys(forcing)
        v = forcing[f]
        forcing_t = @set forcing_t[f] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
    return forcing_t
end

function getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

"""
filterVariables(out::NamedTuple, varsinfo; filter_variables=true)
"""
function filterVariables(out::NamedTuple, varsinfo::NamedTuple; filter_variables=true)
    if !filter_variables
        fout = out
    else
        fout = (;)
        for k ∈ keys(varsinfo)
            v = getfield(varsinfo, k)
            # fout = setTupleField(fout, (k, v, getfield(out, k)))
            fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
        end
    end
    return fout
end

"""
getNamedDimsArrayFromYaxArray(input::NamedTuple)
"""
function getNamedDimsArrayFromYaxArray(input)
    ks = input.variables
    keyedData = map(input.data) do c
        namesCube = YAXArrayBase.dimnames(c)
        NamedDimsArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
    end
    return (; Pair.(ks, keyedData)...)
end

"""
getDimArrayFromYaxArray(input::NamedTuple)
"""
function getDimArrayFromYaxArray(input)
    ks = input.variables
    keyedData = map(input.data) do c
        YAXArrayBase.yaxconvert(DimArray, Array(c.data))
    end
    return (; Pair.(ks, keyedData)...)
end

"""
getKeyedArrayFromYaxArray(input::NamedTuple)
"""
function getKeyedArrayFromYaxArray(input)
    ks = input.variables
    in_cubes = input.data
    keyedData = map(in_cubes) do c
        namesCube = DimensionalData.name(dims(c)) #YAXArrays.Axes.axname.(caxes(c))
        KeyedArray(c.data; Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
    end
    return (; Pair.(ks, keyedData)...)
end


"""
getObsKeyedArrayFromYaxArray(input::NamedTuple)
"""
function getObsKeyedArrayFromYaxArray(input)
    ks = input.variables
    keyedData = map(input.data) do c
        namesCube = YAXArrayBase.dimnames(c)
        KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
    end
    return keyedData
end
