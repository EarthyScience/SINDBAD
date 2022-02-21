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
    data_dict = Dict()
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
            push!(dataAr, ds[srcVar][1, 1, :])
            # data_dict[tarVar]=ds[srcVar][1, 1, :]
        end
    end
    forcing = Table((; zip(varlist, dataAr)...))
    # forcing = Table((; zip(keys(data_dict), [v for v in values(data_dict)])...))
    return forcing
end


