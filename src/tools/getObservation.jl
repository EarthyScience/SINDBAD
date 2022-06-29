export getObservation, cleanObsData

function cleanObsData(datapoint, vinfo, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint, vinfo.data.source2sindbadUnit, vinfo.data.additiveUnitConversion)
    @show vinfo.data.source2sindbadUnit, vinfo.data.additiveUnitConversion
    bounds = vinfo.bounds
    datapoint = applyObservationBounds(datapoint, bounds)
    # datapoint = applyQualityFlag(datapoint, bounds[1], bounds[2])
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

function applyObservationBounds(data, bounds)
    if !isempty(bounds)
        data[data < bounds[1]] = NaN
        data[data > bounds[2]] = NaN
    end
    return data
end

function applyQualityFlag(data, qdata, qbounds)
    if !isempty(qbounds)
        data[qdata < qbounds[1]] = NaN
        data[qdata > qbounds[2]] = NaN
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
function getObservation(info, ::Val{:yaxarray})
    doOnePath = false
    dataPath = info.opti.constraints.oneDataPath
    nc = Any
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        nc = NetCDF.open(dataPath)
    end
    varnames = Symbol.(info.opti.variables2constrain)
    varnames_unc = []
    for v in varnames
        push!(varnames_unc, v)
        push!(varnames_unc, Symbol(string(v)*"_σ"))
    end
    incubes = map(varnames_unc) do k_unc
        is_unc = false
        if occursin("_σ",  string(k_unc))
            k = Symbol(split(string(k_unc), "_σ")[1])
            is_unc=true
        else
            k = k_unc
        end
        v = Any
        vinfo = getproperty(info.opti.constraints.variables, k)
        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.opti.useUncertainty to false
        # if is_unc
        #     if hasproperty(vinfo, :unc) && info.opti.useUncertainty
        #         uncvar = vinfo.unc.sourceVariableName
        #         @info "Using $(uncvar) as uncertainty in optimization for $(v) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
        #         var2get = uncvar
        #     else
        #         data_unc = ones(info.tem.helpers.numbers.numType, size(data_obs))
        #         @info "Using ones as uncertainty in optimization for $(v) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
        #     end
        #     idxs = isnan.(data_obs)
        #     data_unc[idxs] .= info.tem.helpers.numbers.sNT(NaN)
        # end
        if !doOnePath
            dataPath = getAbsDataPath(info, v.dataPath)
            v = getDataFromPath(dataPath, vinfo.data.sourceVariableName)
        else
            v = nc[vinfo.data.sourceVariableName]
        end
        atts = v.atts
        if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
            v = CFDiskArray(v, atts)
        end
        ax = map(v.dim) do d
            dn = d.name
            dv = nc[dn][:]
            RangeAxis(dn, dv)
        end
        yax = YAXArray(ax, v)
        numtype = Val{info.tem.helpers.numbers.numType}()

        yax
        # map(v -> cleanObsData(v, vinfo, numtype), yax)
    end
    indims = getInDims.(incubes, Ref(info.optim.mapping.yaxarray))
    nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    return (; data=incubes, dims=indims, n_timesteps=nts, variables = varnames_unc)
end

"""
getObservation(info)
"""
function getObservation(info)
    doOnePath = true
    if !isnothing(info.opti.constraints.oneDataPath)
        doOnePath = true
        if isabspath(info.opti.constraints.oneDataPath)
            dataPath = info.opti.constraints.oneDataPath
        else
            dataPath = joinpath(info.experiment_root, info.opti.constraints.oneDataPath)
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
            if !isnothing(vinfo.qflag.dataPath)
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

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.opti.useUncertainty to false
        uncTarVar = Symbol(v*"_σ")
        push!(varlist, uncTarVar)
        if hasproperty(vinfo, :unc) && info.opti.useUncertainty
            uncvar = vinfo.unc.sourceVariableName
            @info "Using $(uncvar) as uncertainty in optimization for $(v) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
            if !isnothing(vinfo.unc.dataPath)
                data_unc = getDataFromPath(vinfo.unc.dataPath, uncvar)
            else
                data_unc = getDataFromPath(dataPath, uncvar)
            end
            data_unc[ismissing.(data_unc)] .= info.tem.helpers.numbers.sNT(NaN)
            data_unc = applyUnitConversion(data_unc, vinfo.unc.source2sindbadUnit, vinfo.unc.additiveUnitConversion)
            data_unc = applyObservationBounds(data_unc, vinfo.unc.bounds)
        else
            data_unc = ones(info.tem.helpers.numbers.numType, size(data_obs))
            @info "Using ones as uncertainty in optimization for $(v) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
        end
        idxs = isnan.(data_obs)
        data_unc[idxs] .= info.tem.helpers.numbers.sNT(NaN)
        push!(dataAr, info.tem.helpers.numbers.numType.(data_unc))
    end
    observation = Table((; Pair.(varlist, dataAr)...))
    return observation
end



