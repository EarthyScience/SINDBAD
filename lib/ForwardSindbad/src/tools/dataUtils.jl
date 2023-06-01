export getDataDims, getNumberOfTimeSteps, cleanInputData, getAbsDataPath
export AllNaN
export getForcingTimeSize
export getForcingForTimeStep
export filterVariables
export getKeyedArrayFromYaxArray
export getNamedDimsArrayFromYaxArray
export getDimArrayFromYaxArray

"""
    AllNaN <: YAXArrays.DAT.ProcFilter
Add skipping filter for pixels with all nans in YAXArrays 
"""
struct AllNaN <: YAXArrays.DAT.ProcFilter end
YAXArrays.DAT.checkskip(::AllNaN, x) = all(isnan, x)

function cleanInputData(datapoint, vinfo, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint, vinfo.source2sindbadUnit, vinfo.additiveUnitConversion)
    bounds = vinfo.bounds
    datapoint = clamp(datapoint, bounds[1], bounds[2])
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

function getAbsDataPath(info, dataPath)
    if !isabspath(dataPath)
        dataPath = joinpath(info.experiment_root, dataPath)
    end
    return dataPath
end

function getDataDims(c, mappinginfo)
    inax = String[]
    axnames = YAXArrays.Axes.axname.(caxes(c))
    inollt = findall(∉(mappinginfo), axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    length(getAxis(time_name, incubes[i1]).values)
end

function getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v in forcing
        if in(:time, AxisKeys.dimnames(v)) 
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

@generated function getForcingTimeSize(forcing, ::Val{forc_vars}) where forc_vars
    output = quote
        forcingTimeSize = 1
    end
    foreach(forc_vars) do forc
            push!(output.args,Expr(:(=),:v,Expr(:.,:forcing,QuoteNode(forc))))
            push!(output.args,quote
                forcingTimeSize = in(:time, AxisKeys.dimnames(v)) ? size(v, 1) : forcingTimeSize
            end)
    end
    push!(output.args,quote
        return forcingTimeSize
    end)
    output
end


@generated function getForcingForTimeStep(forcing, ::Val{forc_vars}, ts, f_t) where forc_vars
    output = quote
    end
    foreach(forc_vars) do forc
            push!(output.args,Expr(:(=),:v,Expr(:.,:forcing,QuoteNode(forc))))
            push!(output.args,quote
                    d = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
                end)
            push!(output.args, Expr(:(=), :f_t, Expr(:macrocall, Symbol("@set"), :(#= none:1 =#), Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d))))
    end
    output
end


function getForcingForTimeStep(forcing::NamedTuple, ts::Int64, forcing_t)
    for f=keys(forcing)
        v = forcing[f]
        forcing_t = @set forcing_t[f] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
    return forcing_t;
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
        fout=out
    else
        fout = (;)
        for k in keys(varsinfo)
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
    ks = input.variables;
    keyedData = map(input.data) do c
    namesCube = YAXArrayBase.dimnames(c)
        NamedDimsArray(Array(c.data); Tuple(k => getproperty(c, k) for k in namesCube)...)
    end
    return (; Pair.(ks, keyedData)...);
end

"""
getDimArrayFromYaxArray(input::NamedTuple)
"""
function getDimArrayFromYaxArray(input)
    ks = input.variables;
    keyedData = map(input.data) do c
    namesCube = YAXArrayBase.dimnames(c)
        YAXArrayBase.yaxconvert(DimArray, Array(c.data))
    end
    return (; Pair.(ks, keyedData)...);
end

"""
getKeyedArrayFromYaxArray(input::NamedTuple)
"""
function getKeyedArrayFromYaxArray(input)
    ks = input.variables;
    keyedData = map(input.data) do c
    namesCube = YAXArrayBase.dimnames(c)
        KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k in namesCube)...)
    end
    return (; Pair.(ks, keyedData)...);
end
