export getForcing

"""
getForcing(info)
"""
function getForcing(info)
    doOnePath = false
    if !isempty(info.forcing.oneDataPath)
        doOnePath = true
        if isabspath(info.forcing.oneDataPath)
            dataPath = info.forcing.oneDataPath
        else
            dataPath = joinpath(info.sinbad_root, info.forcing.oneDataPath)
        end
    end
    varnames = propertynames(info.forcing.variables)
    varlist = []
    dataAr = []
    # forcing = (;)
    if doOnePath
        ds = Dataset(dataPath)
    end
    for v in varnames
        vinfo = getproperty(info.forcing.variables, v)
        if !doOnePath
            dataPath = vinfo.dataPath
            ds = Dataset(dataPath)
        end
        srcVar = vinfo.sourceVariableName
        tarVar = Symbol(v)
        ds_dat = ds[srcVar][:, :, :]
        data_tmp = applyUnitConversion(ds_dat, vinfo.source2sindbadUnit, vinfo.additiveUnitConversion)
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
    end
    println("forcing is still replicating the static variables 14245 times. Needs refinement and automation.")
    forcing = Table((; zip(varlist, dataAr)...))
    return forcing
end

