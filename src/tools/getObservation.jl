export getObservation, cleanObsData

function cleanObsData(datapoint, vinfo, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint, vinfo.data.source2sindbadUnit, vinfo.data.additiveUnitConversion)
    #TODO: when bounds are activated the data is not instantiated and the yaxarray fails when printing observation.data. Fix the observation bounds and quality flag
    # bounds = vinfo.bounds
    # if !isempty(bounds)
    #     datapoint = applyObservationBounds(datapoint, bounds)
    # end
    # datapoint = applyQualityFlag(datapoint, bounds[1], bounds[2])
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

function applyObservationBounds(data, bounds)
    if data < bounds[1] || data > bounds[2]
        return NaN
    else
        return data
    end
end

function applyQualityFlag(data, qdata, qbounds)
    if !isempty(qbounds)
        if qdata < qbounds[1] || qdata > qbounds[2]
            data = NaN
        end
    end
    return data
end

function getDataFromPath(dataPath, srcVar)
    ds = NetCDF.ncread(dataPath, srcVar)
    data_tmp = ds[1, 1, :] # TODO multidimensional input
    return data_tmp
end


function getNCFromPath(dataPath, ::Val{:yaxarray})
    nc_data = NetCDF.open(dataPath)
    return nc_data
end

function getDataFromPath(dataPath, srcVar, ::Val{:yaxarray})
    nc_data = NetCDF.open(dataPath)
    return nc_data[srcVar]
end


function getNCForMask(mask_path)
    nc_mask = NetCDF.open(mask_path)
    return nc_mask
end

function get_obs_sel_mask(mask_path)
    mask = NetCDF.open(mask_path)
    mask_data = mask["mask"]
    return mask_data
end


function get_yax_data(v, nc)
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
    #todo: make another yaxarray so that the fileID is shared across workers in multiprocessor. Similar to what is done in the getForcing
    # yax = YAXArray(ax, Sindbad.YAXArrayBase.NetCDFVariable{eltype(v),ndims(v)}(dataPath,vinfo.sourceVariableName,size(v)))
    return yax
end

"""
getObservation(info)
"""
function getObservation(info, ::Val{:yaxarray})
    doOnePath = false
    dataPath = info.opti.constraints.oneDataPath
    nc = Any
    nc_qc = Any
    nc_unc = Any
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        nc = NetCDF.open(dataPath)
    end
    varnames = Symbol.(info.opti.variables2constrain)
    nc_mask = nothing
    mask_path = nothing
    if :one_sel_mask ∈ keys(info.opti.constraints)
        if !isnothing(info.opti.constraints.one_sel_mask)
            mask_path = getAbsDataPath(info, info.opti.constraints.one_sel_mask)
            nc_mask = getNCForMask(mask_path)
        end
    end
    incubes = []
    @info "getObservation: getting observation variables..."
    map(varnames) do k
        v = Any
        vinfo = getproperty(info.opti.constraints.variables, k)
        src_var = vinfo.data.sourceVariableName

        if !doOnePath
            dataPath = getAbsDataPath(info, v.dataPath)
            nc = getNCFromPath(dataPath, Val(:yaxarray))
        end
        @info "     $(k): Data: source_var: $(src_var), source_file: $(dataPath)"
        v = nc[src_var]

        # get the quality flag data
        dataPath_qc = nothing
        v_qc = nothing
        nc_qc = nc
        if hasproperty(vinfo, :qflag)
            qcvar = vinfo.qflag.sourceVariableName
            dataPath_qc = dataPath
            if !isnothing(vinfo.qflag.dataPath)
                dataPath_qc = getAbsDataPath(info, vinfo.qflag.dataPath)
                nc_qc = getNCFromPath(dataPath_qc, Val(:yaxarray))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qcvar]
            @info "          QFlag: source_var: $(qcvar), source_file: $(dataPath_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            v_qc = v #todo: make ones with the same characteristics as v
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.opti.useUncertainty to false
        dataPath_unc = nothing
        v_unc = Any
        nc_unc = nc
        if hasproperty(vinfo, :unc) && info.opti.useUncertainty
            uncvar = vinfo.unc.sourceVariableName
            # @info "UNCERTAINTY: Using $(uncvar) as uncertainty in optimization for $(k) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
            dataPath_unc = dataPath
            if !isnothing(vinfo.unc.dataPath)
                dataPath_unc = getAbsDataPath(info, vinfo.unc.dataPath)
                nc_unc = getNCFromPath(dataPath_unc, Val(:yaxarray))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[uncvar]
            @info "          Unc: source_var: $(uncvar), source_file: $(dataPath_unc)"
        else
            v_unc = v #todo: make ones with the same characteristics as v
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
        end

        # get the mask to apply to data and save to observation cube
        # get the mask for selecting the data
        has_mask = true
        v_mask_path=mask_path
        if hasproperty(vinfo, :sel_mask)
            v_mask_path = vinfo.sel_mask
            if !isnothing(v_mask_path)
                nc_mask = getNCForMask(v_mask_path)
            else
                has_mask = false
                nc_mask = nc
            end
        end

        v_mask = nothing
        maskvar = "mask"
        if has_mask
            @info "          Mask: using mask from $(v_mask_path)"
            v_mask = nc_mask[maskvar]
        else
            v_mask = v #todo: make ones with the same characteristics as v
            @info "          Mask: selecting locations of all available data points as the mask for $(k) => one_sel_mask and sel_mask are both set as null in json [$(info.opti.constraints.one_sel_mask)]"
        end

        yax = get_yax_data(v, nc)
        yax_unc = get_yax_data(v_unc, nc_unc)
        yax_mask = get_yax_data(v_mask, nc_mask)

        numtype = Val{info.tem.helpers.numbers.numType}()
        
        # clean the data by applying bounds
        #todo: pass qc data to cleanObsData and apply consistently over variable and uncertainty data
        cyax = map(da -> Sindbad.cleanObsData(da, vinfo, numtype), yax)
        cyax_unc = map(da -> Sindbad.cleanObsData(da, vinfo, numtype), yax_unc)
        push!(incubes, cyax)
        push!(incubes, cyax_unc)
        push!(incubes, yax_mask)
    end
    @info "getObservation: getting observation dimensions..."
    indims = getInDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getObservation: getting number of time steps..."
    nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getObservation: getting variable names..."
    varnames_all = []
    for v in varnames
        push!(varnames_all, v)
        push!(varnames_all, Symbol(string(v) * "_σ"))
        push!(varnames_all, Symbol(string(v) * "_mask"))
    end
    println("----------------------------------------------")
    return (; data=incubes, dims=indims, n_timesteps=nts, variables=varnames_all)
end


"""
getObservation(info)
"""
function getObservation(info, ::Val{:table})
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
        uncTarVar = Symbol(v * "_σ")
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



