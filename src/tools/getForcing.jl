export getForcing

"""
checkForcingBounds(forcingVariable, bounds)
check if the forcing data have values outside the provided bounds
"""
function checkForcingBounds(forcingVariable, bounds)
    println("Not done")
end

"""
getForcing(info)
"""
function getForcing(info)
    if isempty(info.forcing.oneDataPath) == false
        doOnePath = true
        if isabspath(info.forcing.oneDataPath)
            dataPath = info.forcing.oneDataPath
        else
            dataPath = joinpath(pwd(), info.forcing.oneDataPath)
        end
    end
    varnames = propertynames(info.forcing.variables)
    varlist = []
    dataAr = []
    # forcing = (;)
    for v in varnames
        vinfo = getproperty(info.forcing.variables, v)
        if doOnePath == false
            dataPath = v.dataPath
        end
        srcVar = vinfo.sourceVariableName
        tarVar = Symbol(v)
        @show srcVar
        ds = Dataset(dataPath)
        ds_dat = ds[srcVar][:, :, :]
        data_tmp = eval(Meta.parse("$ds_dat" * vinfo.source2sindbadUnit))
        bounds = vinfo.bounds
        data_tmp = clamp.(data_tmp, bounds[1], bounds[2])
        data_tmp[ismissing.(data_tmp)] .= info.tem.helpers.numbers.sNT(NaN)
        data_to_push = info.tem.helpers.numbers.numType.(data_tmp[1, 1, :])
        if vinfo.spaceTimeType == "normal"
            push!(varlist, tarVar)
            push!(dataAr, data_to_push)
        else
            push!(varlist, tarVar)
            push!(dataAr, fill(data_to_push, 14245))
        end
        @show tarVar, length(data_tmp), vinfo.spaceTimeType, size(dataAr)
    end
    forcing = Table((; zip(varlist, dataAr)...))
    return forcing
end

