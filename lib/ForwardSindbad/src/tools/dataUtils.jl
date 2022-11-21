export getDataDims, getNumberOfTimeSteps, cleanInputData, getAbsDataPath
export AllNaN
export getForcingTimeSize
export getForcingForTimeStep
export filterVariables
export getKeyedArrayFromYaxArray

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
getKeyedArrayFromYaxArray(input::NamedTuple)
"""
function getKeyedArrayFromYaxArray(input::NamedTuple)
    ks = input.variables;
    keyedData = map(input.data) do c
    namesCube = YAXArrayBase.dimnames(c)
        KeyedArray(Array(c.data); Tuple(k => getproperty(c, k) for k in namesCube)...)
    end
    return (; Pair.(ks, keyedData)...);
end
