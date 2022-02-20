# data with NCDatasets
using NCDatasets, TypedTables

function checkForcingBounds(forcingVariable, bounds)
    println("Not done")
end

function getForcing(info)
    if isempty(info.forcing.oneDataPath) === false
        doOnePath = true
        if isabspath(info.forcing.oneDataPath)
            dataPath = info.forcing.oneDataPath
        else
            dataPath = joinpath(pwd(), info.forcing.oneDataPath)
        end
    end
    varnames = propertynames(info.forcing.variables)
    # varnames = [Symbol(_v) for _v in propertynames(info.forcing.variables)]
    data_dict = Dict()
    for v in varnames
        vinfo = getproperty(info.forcing.variables, v)
        if doOnePath === false
            dataPath = v.dataPath
        end
        ds = NCDatasets.Dataset(dataPath)
        srcVar = vinfo.sourceVariableName
        tarVar = Symbol(v)
        data_dict[tarVar]=ds[srcVar][1, 1, :]
    end
    # forcing = Table((; zip([Symbol(_k) for _k in keys(data_dict)], values(data_dict))...))
    # return forcing
    return data_dict
end

