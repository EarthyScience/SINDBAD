# data with NCDatasets
using NCDatasets, TypedTables

function checkObservationBounds(forcingVariable, bounds)
    println("Not done")
end

function getObservation(info)
    if isempty(info.opti.constraints.oneDataPath) == false
        doOnePath = true
        if isabspath(info.opti.constraints.oneDataPath)
            dataPath = info.opti.constraints.oneDataPath
        else
            dataPath = joinpath(pwd(), info.opti.constraints.oneDataPath)
        end
    end
    varnames = info.opti.variables2constrain;
    varlist = []
    dataAr=[]
    
    for v in varnames
        # @show v, info.opti.constraints.variables
        vinfo = getproperty(info.opti.constraints.variables, Symbol(v))
        if doOnePath == false
            dataPath = v.dataPath
        end
        ds = NCDatasets.Dataset(dataPath)
        srcVar = vinfo.data.sourceVariableName
        tarVar = Symbol(v)
        push!(varlist, tarVar)
        data_tmp = ds[srcVar][1, 1, :]
        # data_tmp_masked = data_tmp < 0.0 ? 0.0 : data_tmp
        push!(dataAr,  eval(Meta.parse("$data_tmp" * vinfo.data.source2sindbadUnit)))
    end
    observation = Table((; zip(varlist, dataAr)...))
    return observation
end
