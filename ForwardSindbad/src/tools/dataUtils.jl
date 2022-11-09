export getDataDims, getNumberOfTimeSteps, cleanInputData, getAbsDataPath
export AllNaN

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
