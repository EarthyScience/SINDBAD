# data with NCDatasets
using NCDatasets, TypedTables

function checkForcingBounds(forcingVariable, bounds)
    println("Not done")
end

function getForcing(info)

    if isempty(info.forcing.oneDataPath) == false
        doOnePath = true
        if isabspath(info.forcing.oneDataPath)
            dataPath = info.forcing.oneDataPath
        else
            dataPath = joinpath(pwd(), info.forcing.oneDataPath)
        end
    end
    varnames = propertynames(info.forcing.variables);
    varlist = []
    dataAr=[]
    for v in varnames
        vinfo = getproperty(info.forcing.variables, v)
        if doOnePath == false
            dataPath = v.dataPath
        end
        if vinfo.spaceTimeType == "normal"
            ds = NCDatasets.Dataset(dataPath)
            srcVar = vinfo.sourceVariableName
            tarVar = Symbol(v)
            push!(varlist, tarVar)
            data_tmp = ds[srcVar][1, 1, :]
            push!(dataAr,  eval(Meta.parse("$data_tmp" * vinfo.source2sindbadUnit)))
        end
    end
    forcing = Table((; zip(varlist, dataAr)...))
    return forcing
end