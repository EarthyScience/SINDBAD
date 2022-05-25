export getObservation

function applyObservationBounds(data, bounds)
    if !isempty(bounds)
        data[data .< bounds[1]] .= NaN
        data[data .> bounds[2]] .= NaN
    end
    return data
end

function applyQualityFlag(data, qdata, qbounds)
    if !isempty(qbounds)
        data[qdata .< qbounds[1]] .= NaN
        data[qdata .> qbounds[2]] .= NaN
    end
    return data
end

function getDataFromPath(dataPath, srcVar)
    ds = NetCDF.ncread(dataPath, srcVar)
    data_tmp = ds[1, 1, :] # TODO multidimensional input
    return data_tmp
end

"""
getObservation(info)
"""
function getObservation(info)
    doOnePath = true
    if isempty(info.opti.constraints.oneDataPath) == false
        doOnePath = true
        if isabspath(info.opti.constraints.oneDataPath)
            dataPath = info.opti.constraints.oneDataPath
        else
            dataPath = joinpath(info.sinbad_root, info.opti.constraints.oneDataPath)
        end
    end
    varnames = info.opti.variables2constrain
    varlist = []
    dataAr = []

    for v in varnames
        vinfo = getproperty(info.opti.constraints.variables, Symbol(v))
        if doOnePath == false
            dataPath = v.dataPath
        end
        data_tmp = getDataFromPath(dataPath, vinfo.data.sourceVariableName)

        # apply quality flag to the data        
        if hasproperty(vinfo, :qflag)
            qcvar = vinfo.qflag.sourceVariableName
            if !isempty(vinfo.qflag.dataPath)
                data_q_flag = getDataFromPath(vinfo.qflag.dataPath, qcvar)
            else
                data_q_flag = getDataFromPath(dataPath, qcvar)
            end
            data_q_flag[ismissing.(data_q_flag)] .= info.tem.helpers.numbers.sNT(NaN)
            data_tmp = applyQualityFlag(data_tmp, data_q_flag, vinfo.qflag.bounds)
        end
        tarVar = Symbol(v)
        push!(varlist, tarVar)
        data_tmp[ismissing.(data_tmp)] .= info.tem.helpers.numbers.sNT(NaN)
        data_obs = applyUnitConversion(data_tmp, vinfo.data.source2sindbadUnit, vinfo.data.additiveUnitConversion)
        data_obs = applyObservationBounds(data_obs, vinfo.data.bounds)
        push!(dataAr, info.tem.helpers.numbers.numType.(data_obs))

        # get uncertainty data and add to data
        if hasproperty(vinfo, :unc)
            uncvar = vinfo.unc.sourceVariableName
            if !isempty(vinfo.unc.dataPath)
                data_unc = getDataFromPath(vinfo.unc.dataPath, uncvar)
            else
                data_unc = getDataFromPath(dataPath, uncvar)
            end
            uncTarVar = Symbol(v*"_σ")
            push!(varlist, uncTarVar)
            data_unc[ismissing.(data_unc)] .= info.tem.helpers.numbers.sNT(NaN)
            data_unc = applyUnitConversion(data_unc, vinfo.unc.source2sindbadUnit, vinfo.unc.additiveUnitConversion)
            data_unc = applyObservationBounds(data_unc, vinfo.unc.bounds)
        else
            data_unc = ones(info.tem.helpers.numbers.numType, size(data_obs))
        end
        idxs = isnan.(data_obs)
        data_unc[idxs] .= info.tem.helpers.numbers.sNT(NaN)
        push!(dataAr, info.tem.helpers.numbers.numType.(data_unc))
    end
    observation = Table((; Pair.(varlist, dataAr)...))
    return observation
end
