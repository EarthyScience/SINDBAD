export getObservation, cleanObsData


function cleanObsData(datapoint, datapoint_qc, vinfo, bounds, bounds_qc, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint,
        vinfo.data.source2sindbadUnit,
        vinfo.data.additiveUnitConversion)
    if !isnothing(bounds)
        if datapoint < first(bounds) || datapoint > last(bounds)
            datapoint = T(NaN)
        end
    end
    if !isnothing(bounds_qc)
        if datapoint_qc < first(bounds_qc) || datapoint_qc > last(bounds_qc)
            datapoint = T(NaN)
        end
    end
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

function getDataFromPath(dataPath::String, srcVar::String)
    ds = NetCDF.ncread(dataPath, srcVar)
    data_tmp = ds[1, 1, :] # TODO multidimensional input
    return data_tmp
end

function getNCFromPath(dataPath::String, ::Val{:yaxarray})
    nc_data = NetCDF.open(dataPath)
    return nc_data
end

function getDataFromPath(dataPath::String, srcVar::String, ::Val{:yaxarray})
    nc_data = NetCDF.open(dataPath)
    return nc_data[srcVar]
end

function getNCForMask(mask_path::String)
    nc_mask = NetCDF.open(mask_path)
    return nc_mask
end

function getSelObsMask(mask_path::String)
    mask = NetCDF.open(mask_path)
    mask_data = mask["mask"]
    return mask_data
end

function getObsZarr(v)
    @show v.name
    return YAXArrayBase.yaxconvert(YAXArray, v)
end

function getObsYax(v, nc, info::NamedTuple, variable_name::String, data_path::String)
    atts = v.atts
    if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
        v = CFDiskArray(v, atts)
    end
    ax = map(v.dim) do d
        dn = d.name
        if dn in keys(nc)
            dv = nc[dn][:]
        else
            # @show v, size(v)
            dv = 1:size(v, 2)
        end
        rax = RangeAxis(dn, dv)
        if dn == info.tem.forcing.dimensions.time
            t = nc[info.tem.forcing.dimensions.time]
            dt_str = Dates.DateTime(join(split(t.atts["units"], " ")[3:end], "T"))
            rax = RangeAxis(dn, collect(dt_str:Day(1):(dt_str+Day(length(t) - 1))))
        end
        return rax
    end
    # yax = YAXArray(ax, v)
    yax = YAXArray(ax,
        YAXArrayBase.NetCDFVariable{eltype(v),ndims(v)}(data_path, variable_name,
            size(v)))
    return yax
end

function time_slice_yax_cubes(cyax, cyax_unc, yax_mask, info, forcing_info)
    if hasproperty(cyax, Symbol(forcing_info.dimensions.time))
        cyax = cyax[time=(Date(info.tem.helpers.dates.sDate),
            Date(info.tem.helpers.dates.eDate) + info.tem.helpers.dates.time_step)]
    end
    if hasproperty(cyax_unc, Symbol(forcing_info.dimensions.time))
        cyax_unc = cyax_unc[time=(Date(info.tem.helpers.dates.sDate),
            Date(info.tem.helpers.dates.eDate) +
            info.tem.helpers.dates.time_step)]
    end
    if hasproperty(yax_mask, Symbol(forcing_info.dimensions.time))
        yax_mask = yax_mask[time=(Date(info.tem.helpers.dates.sDate),
            Date(info.tem.helpers.dates.eDate) +
            info.tem.helpers.dates.time_step)]
    end
    return cyax, cyax_unc, yax_mask
end

"""
getObservation(info)
"""
function getObservation(info::NamedTuple, ::Val{:zarr})
    forcing_info = info.tem.forcing
    permutes = forcing_info.permutes
    subset = forcing_info.subset
    doOnePath = false
    dataPath = info.opti.constraints.oneDataPath
    nc = nothing
    nc_qc = nothing
    nc_unc = nothing
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        nc = YAXArrays.open_dataset(zopen(dataPath))
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
    obscubes = []
    @info "getObservation: getting observation variables..."
    map(varnames) do k
        v = nothing
        vinfo = getproperty(info.opti.constraints.variables, k)
        src_var = vinfo.data.sourceVariableName

        if !doOnePath
            dataPath = getAbsDataPath(info, v.dataPath)
            nc = YAXArrays.open_dataset(zopen(dataPath))
        end
        @info "     $(k): Data: source_var: $(src_var), source_file: $(dataPath)"
        ov = nc[src_var]
        v = YAXArrayBase.yaxconvert(DimArray, ov)
        # site, lon, lat should be options to consider here
        # v = v[site=1:forcing_info.size.site, time = 1:forcing_info.size.time]

        # get the quality flag data
        dataPath_qc = nothing
        v_qc = nothing
        nc_qc = nc
        qc_var = nothing
        one_qc = false
        bounds_qc = nothing
        if hasproperty(vinfo, :qflag)
            qc_var = vinfo.qflag.sourceVariableName
            dataPath_qc = dataPath
            if !isnothing(vinfo.qflag.dataPath)
                dataPath_qc = getAbsDataPath(info, vinfo.qflag.dataPath)
                nc_qc = getNCFromPath(dataPath_qc, Val(:yaxarray))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qc_var]
            bounds_qc = vinfo.qflag.bounds
            @info "          QFlag: source_var: $(qc_var), source_file: $(dataPath_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            one_qc = true
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.opti.useUncertainty to false
        dataPath_unc = nothing
        v_unc = nothing
        nc_unc = nc
        unc_var = nothing
        one_unc = false
        bounds_unc = nothing
        if hasproperty(vinfo, :unc) && info.opti.useUncertainty
            unc_var = vinfo.unc.sourceVariableName
            # @info "UNCERTAINTY: Using $(unc_var) as uncertainty in optimization for $(k) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
            dataPath_unc = dataPath
            if !isnothing(vinfo.unc.dataPath)
                dataPath_unc = getAbsDataPath(info, vinfo.unc.dataPath)
                nc_unc = YAXArrays.open_dataset(zopen(dataPath_unc))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[unc_var]
            bounds_unc = vinfo.unc.bounds
            @info "          Unc: source_var: $(unc_var), source_file: $(dataPath_unc)"
        else
            dataPath_unc = dataPath
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
            one_unc = true
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        dataPath_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            dataPath_mask = vinfo.sel_mask
            if !isnothing(dataPath_mask)
                nc_mask = YAXArrays.open_dataset(zopen(dataPath_mask))
                has_mask = true
            else
                dataPath_mask = dataPath
                nc_mask = nc
            end
        else
            dataPath_mask = dataPath
            nc_mask = nc
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        if has_mask
            @info "          Mask: using mask from $(dataPath_mask)"
            v_mask = nc_mask[maskvar]
        else
            @info "          Mask: selecting locations of all available data points as the mask for $(k) => one_sel_mask and sel_mask are either non-existent or set as null in json"
            no_mask = true
        end
        unc_tar_name = string(unc_var)
        qc_tar_name = string(qc_var)
        mask_tar_name = string(src_var)
        if !isnothing(subset)
            v = subset_space_in_data(subset, v)
        end

        yax = getObsZarr(v)

        yax_qc = nothing
        if one_qc
            yax_qc = map(x -> one(x), yax)
        else
            yax_qc = getObsZarr(v_qc)
        end

        yax_unc = nothing
        if one_unc
            yax_unc = map(x -> one(x), yax)
        else
            yax_unc = getObsZarr(v_unc)
        end

        yax_mask = nothing
        if no_mask
            yax_mask = map(x -> one(x), yax)
        else
            yax_mask = getObsZarr(v_mask)
        end

        numtype = Val{info.tem.helpers.numbers.num_type}()

        # clean the data by applying bounds
        #todo: pass qc data to cleanObsData and apply consistently over variable and uncertainty data
        cyax = map((da, dq) -> cleanObsData(da, dq, vinfo, vinfo.data.bounds, bounds_qc, numtype), yax, yax_qc)
        # cyax = map(da -> cleanObsData(da, vinfo, vinfo.data.bounds, numtype), yax)

        cyax_unc = yax_unc
        if !one_unc
            cyax_unc = map((da, dq) -> cleanObsData(da, dq, vinfo, bounds_unc, bounds_qc, numtype), yax_unc, yax_qc)
            # cyax_unc = map(da -> cleanObsData(da, vinfo, vinfo.unc.bounds, numtype), yax_unc)
        end
        if !isnothing(permutes)
            @info "permuting dimensions to $(tar_dims)..."
            cyax = permutedims(cyax, permutes)
            cyax_unc = permutedims(cyax_unc, permutes)
            yax_mask = permutedims(yax_mask, permutes)
        end

        cyax, cyax_unc, yax_mask = time_slice_yax_cubes(cyax, cyax_unc, yax_mask, info,
            forcing_info)

        push!(obscubes, cyax)
        push!(obscubes, cyax_unc)
        return push!(obscubes, yax_mask)
    end
    @info "getObservation: getting observation dimensions..."
    indims = getDataDims.(obscubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getObservation: getting number of time steps..."
    nts = getNumberOfTimeSteps(obscubes, forcing_info.dimensions.time)
    @info "getObservation: getting variable name..."
    varnames_all = []
    for v ∈ varnames
        push!(varnames_all, v)
        push!(varnames_all, Symbol(string(v) * "_σ"))
        push!(varnames_all, Symbol(string(v) * "_mask"))
    end
    println("----------------------------------------------")
    return (; data=obscubes, dims=indims, n_timesteps=nts, variables=varnames_all)
end

"""
getObservation(info)
"""
function getObservation(info::NamedTuple, ::Val{:yaxarray})
    forcing_info = info.tem.forcing
    permutes = forcing_info.permutes
    doOnePath = false
    dataPath = info.opti.constraints.oneDataPath
    nc = nothing
    nc_qc = nothing
    nc_unc = nothing
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
    obscubes = []
    @info "getObservation: getting observation variables..."
    map(varnames) do k
        v = nothing
        vinfo = getproperty(info.opti.constraints.variables, k)
        src_var = vinfo.data.sourceVariableName

        if !doOnePath
            dataPath = getAbsDataPath(info, vinfo.data.dataPath)
            nc = getNCFromPath(dataPath, Val(:yaxarray))
        end
        @info "     $(k): Data: source_var: $(src_var), source_file: $(dataPath)"
        v = nc[src_var]

        # get the quality flag data
        dataPath_qc = nothing
        v_qc = nothing
        nc_qc = nc
        qc_var = nothing
        one_qc = false
        bounds_qc = nothing
        if hasproperty(vinfo, :qflag)
            qc_var = vinfo.qflag.sourceVariableName
            dataPath_qc = dataPath
            if !isnothing(vinfo.qflag.dataPath)
                dataPath_qc = getAbsDataPath(info, vinfo.qflag.dataPath)
                nc_qc = getNCFromPath(dataPath_qc, Val(:yaxarray))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qc_var]
            bounds_qc = vinfo.qflag.bounds
            @info "          QFlag: source_var: $(qc_var), source_file: $(dataPath_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            one_qc = true
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.opti.useUncertainty to false
        dataPath_unc = nothing
        v_unc = nothing
        nc_unc = nc
        unc_var = nothing
        one_unc = false
        bounds_unc = nothing
        if hasproperty(vinfo, :unc) && info.opti.useUncertainty
            unc_var = vinfo.unc.sourceVariableName
            # @info "UNCERTAINTY: Using $(unc_var) as uncertainty in optimization for $(k) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
            dataPath_unc = dataPath
            if !isnothing(vinfo.unc.dataPath)
                dataPath_unc = getAbsDataPath(info, vinfo.unc.dataPath)
                nc_unc = getNCFromPath(dataPath_unc, Val(:yaxarray))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[unc_var]
            bounds_unc = vinfo.unc.bounds
            @info "          Unc: source_var: $(unc_var), source_file: $(dataPath_unc)"
        else
            dataPath_unc = dataPath
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.opti.useUncertainty is set as $(info.opti.useUncertainty)"
            one_unc = true
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        dataPath_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            dataPath_mask = vinfo.sel_mask
            if !isnothing(dataPath_mask)
                nc_mask = getNCForMask(dataPath_mask)
                has_mask = true
            else
                dataPath_mask = dataPath
                nc_mask = nc
            end
        else
            dataPath_mask = dataPath
            nc_mask = nc
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        if has_mask
            @info "          Mask: using mask from $(dataPath_mask)"
            v_mask = nc_mask[maskvar]
        else
            @info "          Mask: selecting locations of all available data points as the mask for $(k) => one_sel_mask and sel_mask are either non-existent or set as null in json"
            no_mask = true
        end
        unc_tar_name = string(unc_var)
        qc_tar_name = string(qc_var)
        mask_tar_name = string(src_var)

        yax = getObsYax(v, nc, info, src_var, dataPath)

        yax_qc = nothing
        if one_qc
            yax_qc = map(x -> one(x), yax)
        else
            yax_qc = getObsYax(v_qc, nc_qc, info, qc_tar_name, dataPath_qc)
        end

        yax_unc = nothing
        if one_unc
            yax_unc = map(x -> one(x), yax)
        else
            yax_unc = getObsYax(v_unc, nc_unc, info, unc_tar_name, dataPath_unc)
        end

        yax_mask = nothing
        if no_mask
            yax_mask = map(x -> one(x), yax)
        else
            yax_mask = getObsYax(v_mask, nc_mask, info, mask_tar_name, dataPath_mask)
        end

        numtype = Val{info.tem.helpers.numbers.num_type}()

        # clean the data by applying bounds
        #todo: pass qc data to cleanObsData and apply consistently over variable and uncertainty data
        cyax = map((da, dq) -> cleanObsData(da, dq, vinfo, vinfo.data.bounds, bounds_qc, numtype), yax, yax_qc)
        # cyax = map(da -> cleanObsData(da, vinfo, vinfo.data.bounds, numtype), yax)

        cyax_unc = yax_unc
        if !one_unc
            cyax_unc = map((da, dq) -> cleanObsData(da, dq, vinfo, bounds_unc, bounds_qc, numtype), yax_unc, yax_qc)
            # cyax_unc = map(da -> cleanObsData(da, vinfo, bounds_unc, numtype), yax_unc)
        end
        if !isnothing(permutes)
            @info "         permuting dimensions ..."
            cyax = permutedims(cyax, permutes)
            cyax_unc = permutedims(cyax_unc, permutes)
            yax_mask = permutedims(yax_mask, permutes)
        end

        cyax, cyax_unc, yax_mask = time_slice_yax_cubes(cyax, cyax_unc, yax_mask, info,
            forcing_info)

        push!(obscubes, cyax)
        push!(obscubes, cyax_unc)
        return push!(obscubes, yax_mask)
    end
    @info "getObservation: getting observation dimensions..."
    indims = getDataDims.(obscubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getObservation: getting number of time steps..."
    nts = forcing_info.sizes
    @info "getObservation: getting variable name..."
    varnames_all = []
    for v ∈ varnames
        push!(varnames_all, v)
        push!(varnames_all, Symbol(string(v) * "_σ"))
        push!(varnames_all, Symbol(string(v) * "_mask"))
    end
    println("----------------------------------------------")
    return (; data=obscubes, dims=indims, n_timesteps=nts, variables=varnames_all)
end
